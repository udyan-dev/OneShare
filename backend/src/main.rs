use axum::extract::ws::Message;
use axum::{
    extract::{ConnectInfo, State, WebSocketUpgrade},
    http::HeaderMap,
    response::IntoResponse,
    routing::get,
    Router,
};
use bytes::Bytes;
use dotenvy::dotenv;
use fred::prelude::*;
use mimalloc::MiMalloc;
use models::{RedisPayload, WsMessage};
use state::AppState;
use std::env;
use std::net::SocketAddr;
use std::sync::Arc;

mod models;
mod state;
mod ws;

#[global_allocator]
static GLOBAL: MiMalloc = MiMalloc;

#[tokio::main(flavor = "multi_thread")]
async fn main() {
    tracing_subscriber::fmt()
        .with_max_level(tracing_subscriber::filter::LevelFilter::ERROR)
        .init();

    dotenv().ok();

    let redis_url = env::var("REDIS_URL").unwrap_or_else(|_| "redis://127.0.0.1:6379".to_string());
    let app_state = AppState::new(&redis_url).await;

    spawn_redis_router(app_state.clone());

    let app = Router::new()
        .route("/health", get(|| async { "OK" }))
        .route("/ws", get(ws_handler))
        .with_state(app_state);

    let port = env::var("PORT").unwrap_or_else(|_| "3000".to_string());
    let addr = format!("0.0.0.0:{}", port);
    let listener = tokio::net::TcpListener::bind(&addr).await.unwrap();

    axum::serve(listener, app.into_make_service_with_connect_info::<SocketAddr>())
        .with_graceful_shutdown(shutdown_signal())
        .await
        .unwrap();
}

async fn ws_handler(
    ws: WebSocketUpgrade,
    State(state): State<Arc<AppState>>,
    headers: HeaderMap,
    ConnectInfo(addr): ConnectInfo<SocketAddr>,
) -> impl IntoResponse {
    let public_ip = headers
        .get("x-forwarded-for")
        .and_then(|val| val.to_str().ok())
        .and_then(|s| s.split(',').next())
        .map(|s| s.trim().to_string())
        .unwrap_or_else(|| addr.ip().to_string());

    ws.on_upgrade(move |socket| ws::handle_socket(socket, state, public_ip))
}

fn spawn_redis_router(state: Arc<AppState>) {
    let (message_tx, mut message_rx) = tokio::sync::mpsc::channel::<fred::types::Message>(10000);

    state.redis_subscriber.on_message({
        let tx = message_tx.clone();
        move |msg: fred::types::Message| {
            let tx_clone = tx.clone();
            async move {
                let _ = tx_clone.try_send(msg);
                Ok(())
            }
        }
    });

    tokio::spawn(async move {
        while let Some(msg) = message_rx.recv().await {
            if let Some(bytes) = msg.value.as_bytes() {
                if let Ok(payload) = rmp_serde::from_slice::<RedisPayload>(bytes) {
                    match payload {
                        RedisPayload::PeerJoined { room_id, peer_id, device_name, device_type } => {
                            if let Some(local_peers) = state.local_rooms.get(&room_id) {
                                if let Ok(bin) = rmp_serde::to_vec(&WsMessage::PeerJoined {
                                    peer_id: peer_id.clone(),
                                    device_name,
                                    device_type,
                                }) {
                                    let ws_msg = Message::Binary(Bytes::from(bin));
                                    for local_peer_id in local_peers.iter() {
                                        if *local_peer_id != peer_id {
                                            if let Some(tx) = state.local_clients.get(&*local_peer_id) {
                                                let _ = tx.try_send(ws_msg.clone());
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        RedisPayload::EndpointsExchanged { target_id, sender_id, endpoints, cert_hash, .. } => {
                            if let Some(tx) = state.local_clients.get(&target_id) {
                                if let Ok(bin) = rmp_serde::to_vec(&WsMessage::EndpointsReceived {
                                    sender_id,
                                    endpoints,
                                    cert_hash,
                                }) {
                                    let _ = tx.try_send(Message::Binary(Bytes::from(bin)));
                                }
                            }
                        }
                        RedisPayload::RoomClosed { room_id } => {
                            if let Some(local_peers) = state.local_rooms.get(&room_id) {
                                if let Ok(bin) = rmp_serde::to_vec(&WsMessage::RoomClosed) {
                                    let ws_msg = Message::Binary(Bytes::from(bin));
                                    for peer_id in local_peers.iter() {
                                        if let Some(tx) = state.local_clients.get(&*peer_id) {
                                            let _ = tx.try_send(ws_msg.clone());
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    });
}

async fn shutdown_signal() {
    let ctrl_c = async {
        tokio::signal::ctrl_c().await.expect("failed");
    };

    #[cfg(unix)]
    let terminate = async {
        tokio::signal::unix::signal(tokio::signal::unix::SignalKind::terminate())
            .expect("failed")
            .recv()
            .await;
    };

    #[cfg(not(unix))]
    let terminate = std::future::pending::<()>();

    tokio::select! {
        _ = ctrl_c => {},
        _ = terminate => {},
    }
}
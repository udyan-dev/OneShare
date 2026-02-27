mod models;
mod state;
mod ws;

use axum::{
    extract::{State, WebSocketUpgrade},
    response::IntoResponse,
    routing::get,
    Router,
};
use axum::extract::ws::Message;
use bytes::Bytes;
use dotenvy::dotenv;
use fred::prelude::*;
use mimalloc::MiMalloc;
use models::{RedisPayload, WsMessage};
use state::AppState;
use std::env;
use std::sync::Arc;
use tracing::info;
use tracing_subscriber::FmtSubscriber;

#[global_allocator]
static GLOBAL: MiMalloc = MiMalloc;

#[tokio::main(flavor = "multi_thread")]
async fn main() {
    tracing::subscriber::set_global_default(
        FmtSubscriber::builder()
            .with_max_level(tracing::Level::INFO)
            .finish(),
    )
    .unwrap();

    dotenv().ok();
    let redis_url = env::var("REDIS_URL").unwrap_or_else(|_| "redis://127.0.0.1:6379".to_string());
    let app_state = AppState::new(&redis_url).await;

    spawn_redis_router(app_state.clone());

    let app = Router::new()
        .route("/health", get(|| async { "OK" }))
        .route("/ws", get(ws_handler))
        .with_state(app_state);

    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    info!("⚡ OneShare Mesh active on 0.0.0.0:3000");

    axum::serve(listener, app).await.unwrap();
}

async fn ws_handler(ws: WebSocketUpgrade, State(state): State<Arc<AppState>>) -> impl IntoResponse {
    ws.on_upgrade(move |socket| ws::handle_socket(socket, state))
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
                        RedisPayload::EndpointsExchanged {
                            target_id,
                            sender_id,
                            endpoints,
                            cert_hash,
                            ..
                        } => {
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
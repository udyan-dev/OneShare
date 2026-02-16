mod models;
mod state;
mod ws;

use axum::{
    extract::{State, WebSocketUpgrade},
    response::IntoResponse,
    routing::get,
    Router,
};
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
    info!("⚡ Distributed Signaling Server running on 0.0.0.0:3000");

    axum::serve(listener, app).await.unwrap();
}

async fn ws_handler(ws: WebSocketUpgrade, State(state): State<Arc<AppState>>) -> impl IntoResponse {
    ws.on_upgrade(move |socket| ws::handle_socket(socket, state))
}

fn spawn_redis_router(state: Arc<AppState>) {
    let (message_tx, mut message_rx) = tokio::sync::mpsc::unbounded_channel();

    state.redis_subscriber.on_message({
        let message_tx = message_tx.clone();
        move |msg: fred::types::Message| {
            let tx = message_tx.clone();
            async move {
                let _ = tx.send(msg);
                Ok(())
            }
        }
    });

    tokio::spawn(async move {
        while let Some(msg) = message_rx.recv().await {
            if let Some(bytes) = msg.value.as_bytes() {
                if let Ok(payload) = rmp_serde::from_slice::<RedisPayload>(bytes) {
                    match payload {
                        RedisPayload::PeerJoined { room_id, peer_id } => {
                            if let Some(local_peers) = state.local_rooms.get(&room_id) {
                                for local_peer_id in local_peers.iter() {
                                    if *local_peer_id != peer_id {
                                        if let Some(tx) = state.local_clients.get(&*local_peer_id) {
                                            ws::send_ws(
                                                &tx,
                                                WsMessage::PeerJoined {
                                                    peer_id: peer_id.clone(),
                                                },
                                            );
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
                                ws::send_ws(
                                    &tx,
                                    WsMessage::EndpointsReceived {
                                        sender_id,
                                        endpoints,
                                        cert_hash,
                                    },
                                );
                            }
                        }
                        RedisPayload::RoomClosed { room_id } => {
                            if let Some(local_peers) = state.local_rooms.get(&room_id) {
                                for peer_id in local_peers.iter() {
                                    if let Some(tx) = state.local_clients.get(&*peer_id) {
                                        ws::send_ws(&tx, WsMessage::RoomClosed);
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

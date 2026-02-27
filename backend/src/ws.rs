use crate::models::{RedisPayload, RoomMetadata, WsMessage};
use crate::state::{AppState, WsSender};
use axum::extract::ws::{Message, WebSocket};
use bytes::Bytes;
use dashmap::DashSet;
use fred::prelude::*;
use futures_util::{sink::SinkExt, stream::StreamExt};
use nanoid::nanoid;
use std::sync::Arc;
use tokio::sync::mpsc;

pub async fn handle_socket(socket: WebSocket, state: Arc<AppState>) {
    let client_id: Arc<str> = Arc::from(nanoid!(8).into_boxed_str());
    let (mut ws_sender, mut ws_receiver) = socket.split();
    let (tx, mut rx) = mpsc::channel::<Message>(256);

    state.local_clients.insert(client_id.to_string(), tx.clone());

    let mut send_task = tokio::spawn(async move {
        while let Some(msg) = rx.recv().await {
            if ws_sender.send(msg).await.is_err() {
                break;
            }
        }
    });

    let state_clone = state.clone();
    let client_id_clone = client_id.clone();

    let mut recv_task = tokio::spawn(async move {
        while let Some(Ok(msg)) = ws_receiver.next().await {
            if let Message::Binary(bin) = msg {
                if !bin.is_empty() {
                    if let Ok(ws_msg) = rmp_serde::from_slice::<WsMessage>(&bin) {
                        process_client_message(ws_msg, &state_clone, &client_id_clone, &tx).await;
                    }
                }
            }
        }
    });

    tokio::select! {
        _ = &mut send_task => recv_task.abort(),
        _ = &mut recv_task => send_task.abort(),
    }

    cleanup_client(&state, &client_id).await;
}

async fn process_client_message(
    msg: WsMessage,
    state: &Arc<AppState>,
    client_id: &str,
    tx: &WsSender,
) {
    match msg {
        WsMessage::CreateRoom { device_name, device_type, total_files, total_size } => {
            let share_id = nanoid!(6);
            let room_key = format!("room:{}", share_id);

            let metadata = RoomMetadata {
                owner_id: client_id.to_string(),
                device_name,
                device_type,
                total_files,
                total_size,
            };

            if let Ok(meta_bin) = rmp_serde::to_vec(&metadata) {
                if state.redis.set::<(), _, _>(&room_key, Bytes::from(meta_bin), Some(Expiration::EX(900)), None, false).await.is_ok() {
                    let _ = state.redis_subscriber.subscribe(&room_key).await;
                    state.local_rooms.entry(share_id.clone()).or_insert_with(DashSet::new).insert(client_id.to_string());
                    state.client_to_room.insert(client_id.to_string(), share_id.clone());
                    send_ws(tx, &WsMessage::RoomCreated { share_id, client_id: client_id.to_string() });
                }
            }
        }
        WsMessage::JoinRoom { share_id, device_name, device_type } => {
            let room_key = format!("room:{}", share_id);

            if let Ok(meta_bytes) = state.redis.get::<Bytes, _>(&room_key).await {
                if let Ok(metadata) = rmp_serde::from_slice::<RoomMetadata>(&meta_bytes) {
                    let _ = state.redis_subscriber.subscribe(&room_key).await;
                    state.local_rooms.entry(share_id.clone()).or_insert_with(DashSet::new).insert(client_id.to_string());
                    state.client_to_room.insert(client_id.to_string(), share_id.clone());

                    send_ws(tx, &WsMessage::RoomInfo {
                        owner_id: metadata.owner_id,
                        device_name: metadata.device_name,
                        device_type: metadata.device_type,
                        total_files: metadata.total_files,
                        total_size: metadata.total_size,
                    });

                    if let Ok(bin) = rmp_serde::to_vec(&RedisPayload::PeerJoined {
                        room_id: share_id.clone(),
                        peer_id: client_id.to_string(),
                        device_name,
                        device_type,
                    }) {
                        let _ = state.redis.publish::<i64, _, _>(&room_key, bin).await;
                    }
                    return;
                }
            }
            send_ws(tx, &WsMessage::Error { message: "Room Error".into() });
        }
        WsMessage::ExchangeEndpoints { target_id, endpoints, cert_hash } => {
            if let Some(share_id) = state.client_to_room.get(client_id).map(|r| r.value().clone()) {
                let room_key = format!("room:{}", share_id);
                if let Ok(bin) = rmp_serde::to_vec(&RedisPayload::EndpointsExchanged {
                    room_id: share_id,
                    sender_id: client_id.to_string(),
                    target_id,
                    endpoints,
                    cert_hash,
                }) {
                    let _ = state.redis.publish::<i64, _, _>(&room_key, bin).await;
                }
            }
        }
        WsMessage::RoomClosed => {
            if let Some(share_id) = state.client_to_room.get(client_id).map(|r| r.value().clone()) {
                let room_key = format!("room:{}", share_id);
                if let Ok(meta_bytes) = state.redis.get::<Bytes, _>(&room_key).await {
                    if let Ok(metadata) = rmp_serde::from_slice::<RoomMetadata>(&meta_bytes) {
                        if metadata.owner_id == client_id {
                            if let Ok(bin) = rmp_serde::to_vec(&RedisPayload::RoomClosed { room_id: share_id.clone() }) {
                                let _ = state.redis.publish::<i64, _, _>(&room_key, bin).await;
                            }
                            let _ = state.redis.del::<(), _>(&room_key).await;
                            state.local_rooms.remove(&share_id);
                            let _ = state.redis_subscriber.unsubscribe(&room_key).await;
                        }
                    }
                }
            }
        }
        _ => {}
    }
}

async fn cleanup_client(state: &Arc<AppState>, client_id: &str) {
    state.local_clients.remove(client_id);
    if let Some((_, share_id)) = state.client_to_room.remove(client_id) {
        let mut is_empty = false;
        if let Some(local_peers) = state.local_rooms.get(&share_id) {
            local_peers.remove(client_id);
            is_empty = local_peers.is_empty();
        }
        if is_empty {
            state.local_rooms.remove_if(&share_id, |_, peers| peers.is_empty());
            let _ = state.redis_subscriber.unsubscribe(format!("room:{}", share_id)).await;
        }
    }
}

pub fn send_ws(tx: &WsSender, msg: &WsMessage) {
    if let Ok(bin) = rmp_serde::to_vec(msg) {
        let _ = tx.try_send(Message::Binary(Bytes::from(bin)));
    }
}
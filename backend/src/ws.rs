use crate::models::{RedisPayload, WsMessage};
use crate::state::AppState;
use axum::extract::ws::{Message, WebSocket};
use bytes::Bytes;
use dashmap::DashSet;
use fred::prelude::*;
use futures_util::{sink::SinkExt, stream::StreamExt};
use nanoid::nanoid;
use std::sync::Arc;
use tokio::sync::mpsc;

pub async fn handle_socket(socket: WebSocket, state: Arc<AppState>) {
    let client_id = nanoid!(8);
    let (mut ws_sender, mut ws_receiver) = socket.split();
    let (tx, mut rx) = mpsc::unbounded_channel::<Message>();

    state.local_clients.insert(client_id.clone(), tx.clone());

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
        while let Some(Ok(Message::Binary(bin))) = ws_receiver.next().await {
            if let Ok(msg) = rmp_serde::from_slice::<WsMessage>(&bin) {
                process_client_message(msg, &state_clone, &client_id_clone, &tx).await;
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
    tx: &mpsc::UnboundedSender<Message>,
) {
    match msg {
        WsMessage::CreateRoom => {
            let share_id = nanoid!(6);
            let room_key = format!("room:{}", share_id);
            let _ = state.redis.set::<(), _, _>(&room_key, client_id, Some(Expiration::EX(900)), None, false).await;
            let _ = state.redis_subscriber.subscribe(&room_key).await;
            state.local_rooms.entry(share_id.clone()).or_insert_with(DashSet::new).insert(client_id.to_string());
            state.client_to_room.insert(client_id.to_string(), share_id.clone());
            send_ws(tx, WsMessage::RoomCreated { share_id, client_id: client_id.to_string() });
        }
        WsMessage::JoinRoom { share_id } => {
            let room_key = format!("room:{}", share_id);
            if state.redis.exists::<i64, _>(&room_key).await.unwrap_or(0) > 0 {
                let _ = state.redis_subscriber.subscribe(&room_key).await;
                state.local_rooms.entry(share_id.clone()).or_insert_with(DashSet::new).insert(client_id.to_string());
                state.client_to_room.insert(client_id.to_string(), share_id.clone());
                let bin = rmp_serde::to_vec(&RedisPayload::PeerJoined { room_id: share_id.clone(), peer_id: client_id.to_string() }).unwrap();
                let _ = state.redis.publish::<i64, _, _>(&room_key, bin).await;
            } else {
                send_ws(tx, WsMessage::Error { message: "Room not found".into() });
            }
        }
        WsMessage::ExchangeEndpoints { target_id, endpoints, cert_hash } => {
            if let Some(room) = state.client_to_room.get(client_id) {
                let room_key = format!("room:{}", room.value());
                let bin = rmp_serde::to_vec(&RedisPayload::EndpointsExchanged {
                    room_id: room.value().to_string(),
                    sender_id: client_id.to_string(),
                    target_id,
                    endpoints,
                    cert_hash,
                }).unwrap();
                let _ = state.redis.publish::<i64, _, _>(&room_key, bin).await;
            }
        }
        _ => {}
    }
}

async fn cleanup_client(state: &Arc<AppState>, client_id: &str) {
    state.local_clients.remove(client_id);
    if let Some((_, share_id)) = state.client_to_room.remove(client_id) {
        if let Some(local_peers) = state.local_rooms.get(&share_id) {
            local_peers.remove(client_id);
            if local_peers.is_empty() {
                drop(local_peers);
                state.local_rooms.remove(&share_id);
                let _ = state.redis_subscriber.unsubscribe(format!("room:{}", share_id)).await;
            }
        }
    }
}

pub fn send_ws(tx: &mpsc::UnboundedSender<Message>, msg: WsMessage) {
    if let Ok(bin) = rmp_serde::to_vec(&msg) {
        let _ = tx.send(Message::Binary(Bytes::from(bin)));
    }
}
use serde::{Deserialize, Serialize};

#[derive(Debug, Deserialize, Serialize, Clone)]
#[serde(tag = "type")]
pub enum WsMessage {
    CreateRoom,
    JoinRoom { share_id: String },
    ExchangeEndpoints { target_id: String, endpoints: Vec<String>, cert_hash: String },
    RoomCreated { share_id: String, client_id: String },
    PeerJoined { peer_id: String },
    EndpointsReceived { sender_id: String, endpoints: Vec<String>, cert_hash: String },
    RoomClosed,
    Error { message: String },
}

#[derive(Debug, Deserialize, Serialize, Clone)]
#[serde(tag = "type")]
pub enum RedisPayload {
    PeerJoined { room_id: String, peer_id: String },
    EndpointsExchanged { room_id: String, sender_id: String, target_id: String, endpoints: Vec<String>, cert_hash: String },
    RoomClosed { room_id: String },
}
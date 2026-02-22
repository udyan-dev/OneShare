use serde::{Deserialize, Serialize};

#[derive(Debug, Deserialize, Serialize, Clone)]
#[serde(tag = "type")]
pub enum WsMessage {
    CreateRoom {
        #[serde(rename = "deviceName")]
        device_name: String,
        #[serde(rename = "deviceType")]
        device_type: String,
        #[serde(rename = "totalFiles")]
        total_files: i32,
        #[serde(rename = "totalSize")]
        total_size: i64,
    },
    JoinRoom {
        #[serde(rename = "shareId")]
        share_id: String,
        #[serde(rename = "deviceName")]
        device_name: String,
        #[serde(rename = "deviceType")]
        device_type: String,
    },
    RoomCreated {
        #[serde(rename = "shareId")]
        share_id: String,
        #[serde(rename = "clientId")]
        client_id: String,
    },
    RoomInfo {
        #[serde(rename = "ownerId")]
        owner_id: String,
        #[serde(rename = "deviceName")]
        device_name: String,
        #[serde(rename = "deviceType")]
        device_type: String,
        #[serde(rename = "totalFiles")]
        total_files: i32,
        #[serde(rename = "totalSize")]
        total_size: i64,
    },
    PeerJoined {
        #[serde(rename = "peerId")]
        peer_id: String,
        #[serde(rename = "deviceName")]
        device_name: String,
        #[serde(rename = "deviceType")]
        device_type: String,
    },
    ExchangeEndpoints {
        #[serde(rename = "targetId")]
        target_id: String,
        endpoints: Vec<String>,
        #[serde(rename = "certHash")]
        cert_hash: String,
    },
    EndpointsReceived {
        #[serde(rename = "senderId")]
        sender_id: String,
        endpoints: Vec<String>,
        #[serde(rename = "certHash")]
        cert_hash: String,
    },
    RoomClosed,
    Error {
        message: String
    },
}

#[derive(Debug, Deserialize, Serialize, Clone)]
pub enum RedisPayload {
    PeerJoined {
        room_id: String,
        peer_id: String,
        device_name: String,
        device_type: String,
    },
    EndpointsExchanged {
        room_id: String,
        sender_id: String,
        target_id: String,
        endpoints: Vec<String>,
        cert_hash: String,
    },
    RoomClosed { room_id: String },
}

#[derive(Debug, Deserialize, Serialize)]
pub struct RoomMetadata {
    pub owner_id: String,
    pub device_name: String,
    pub device_type: String,
    pub total_files: i32,
    pub total_size: i64,
}
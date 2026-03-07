use serde::de::{SeqAccess, Visitor};
use serde::ser::SerializeTuple;
use serde::{Deserialize, Deserializer, Serialize, Serializer};
use std::fmt;

#[derive(Debug, Clone)]
pub enum WsMessage {
    CreateRoom { device_name: String, device_type: String, total_files: i32, total_size: i64 },
    JoinRoom { share_id: String, device_name: String, device_type: String },
    RoomCreated { share_id: String, client_id: String },
    RoomInfo { owner_id: String, device_name: String, device_type: String, total_files: i32, total_size: i64 },
    PeerJoined { peer_id: String, device_name: String, device_type: String },
    ExchangeEndpoints { target_id: String, endpoints: Vec<String>, cert_hash: String },
    EndpointsReceived { sender_id: String, endpoints: Vec<String>, cert_hash: String },
    RoomClosed,
    Error { message: String },
}

impl Serialize for WsMessage {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: Serializer,
    {
        match self {
            WsMessage::CreateRoom { device_name, device_type, total_files, total_size } => {
                let mut seq = serializer.serialize_tuple(5)?;
                seq.serialize_element(&0u8)?;
                seq.serialize_element(device_name)?;
                seq.serialize_element(device_type)?;
                seq.serialize_element(total_files)?;
                seq.serialize_element(total_size)?;
                seq.end()
            }
            WsMessage::JoinRoom { share_id, device_name, device_type } => {
                let mut seq = serializer.serialize_tuple(4)?;
                seq.serialize_element(&1u8)?;
                seq.serialize_element(share_id)?;
                seq.serialize_element(device_name)?;
                seq.serialize_element(device_type)?;
                seq.end()
            }
            WsMessage::RoomCreated { share_id, client_id } => {
                let mut seq = serializer.serialize_tuple(3)?;
                seq.serialize_element(&2u8)?;
                seq.serialize_element(share_id)?;
                seq.serialize_element(client_id)?;
                seq.end()
            }
            WsMessage::RoomInfo { owner_id, device_name, device_type, total_files, total_size } => {
                let mut seq = serializer.serialize_tuple(6)?;
                seq.serialize_element(&3u8)?;
                seq.serialize_element(owner_id)?;
                seq.serialize_element(device_name)?;
                seq.serialize_element(device_type)?;
                seq.serialize_element(total_files)?;
                seq.serialize_element(total_size)?;
                seq.end()
            }
            WsMessage::PeerJoined { peer_id, device_name, device_type } => {
                let mut seq = serializer.serialize_tuple(4)?;
                seq.serialize_element(&4u8)?;
                seq.serialize_element(peer_id)?;
                seq.serialize_element(device_name)?;
                seq.serialize_element(device_type)?;
                seq.end()
            }
            WsMessage::ExchangeEndpoints { target_id, endpoints, cert_hash } => {
                let mut seq = serializer.serialize_tuple(4)?;
                seq.serialize_element(&5u8)?;
                seq.serialize_element(target_id)?;
                seq.serialize_element(endpoints)?;
                seq.serialize_element(cert_hash)?;
                seq.end()
            }
            WsMessage::EndpointsReceived { sender_id, endpoints, cert_hash } => {
                let mut seq = serializer.serialize_tuple(4)?;
                seq.serialize_element(&6u8)?;
                seq.serialize_element(sender_id)?;
                seq.serialize_element(endpoints)?;
                seq.serialize_element(cert_hash)?;
                seq.end()
            }
            WsMessage::RoomClosed => {
                let mut seq = serializer.serialize_tuple(1)?;
                seq.serialize_element(&7u8)?;
                seq.end()
            }
            WsMessage::Error { message } => {
                let mut seq = serializer.serialize_tuple(2)?;
                seq.serialize_element(&8u8)?;
                seq.serialize_element(message)?;
                seq.end()
            }
        }
    }
}

struct WsMessageVisitor;

impl<'de> Visitor<'de> for WsMessageVisitor {
    type Value = WsMessage;

    fn expecting(&self, formatter: &mut fmt::Formatter) -> fmt::Result {
        formatter.write_str("array")
    }

    fn visit_seq<A>(self, mut seq: A) -> Result<Self::Value, A::Error>
    where
        A: SeqAccess<'de>,
    {
        let id: u8 = seq.next_element()?.ok_or_else(|| serde::de::Error::custom("err"))?;
        match id {
            0 => Ok(WsMessage::CreateRoom {
                device_name: seq.next_element()?.unwrap_or_default(),
                device_type: seq.next_element()?.unwrap_or_default(),
                total_files: seq.next_element()?.unwrap_or_default(),
                total_size: seq.next_element()?.unwrap_or_default(),
            }),
            1 => Ok(WsMessage::JoinRoom {
                share_id: seq.next_element()?.unwrap_or_default(),
                device_name: seq.next_element()?.unwrap_or_default(),
                device_type: seq.next_element()?.unwrap_or_default(),
            }),
            2 => Ok(WsMessage::RoomCreated {
                share_id: seq.next_element()?.unwrap_or_default(),
                client_id: seq.next_element()?.unwrap_or_default(),
            }),
            3 => Ok(WsMessage::RoomInfo {
                owner_id: seq.next_element()?.unwrap_or_default(),
                device_name: seq.next_element()?.unwrap_or_default(),
                device_type: seq.next_element()?.unwrap_or_default(),
                total_files: seq.next_element()?.unwrap_or_default(),
                total_size: seq.next_element()?.unwrap_or_default(),
            }),
            4 => Ok(WsMessage::PeerJoined {
                peer_id: seq.next_element()?.unwrap_or_default(),
                device_name: seq.next_element()?.unwrap_or_default(),
                device_type: seq.next_element()?.unwrap_or_default(),
            }),
            5 => Ok(WsMessage::ExchangeEndpoints {
                target_id: seq.next_element()?.unwrap_or_default(),
                endpoints: seq.next_element()?.unwrap_or_default(),
                cert_hash: seq.next_element()?.unwrap_or_default(),
            }),
            6 => Ok(WsMessage::EndpointsReceived {
                sender_id: seq.next_element()?.unwrap_or_default(),
                endpoints: seq.next_element()?.unwrap_or_default(),
                cert_hash: seq.next_element()?.unwrap_or_default(),
            }),
            7 => Ok(WsMessage::RoomClosed),
            8 => Ok(WsMessage::Error {
                message: seq.next_element()?.unwrap_or_default(),
            }),
            _ => Err(serde::de::Error::custom("err")),
        }
    }
}

impl<'de> Deserialize<'de> for WsMessage {
    fn deserialize<D>(deserializer: D) -> Result<Self, D::Error>
    where
        D: Deserializer<'de>,
    {
        deserializer.deserialize_seq(WsMessageVisitor)
    }
}

#[derive(Debug, Deserialize, Serialize, Clone)]
pub enum RedisPayload {
    PeerJoined { room_id: String, peer_id: String, device_name: String, device_type: String },
    EndpointsExchanged { room_id: String, sender_id: String, target_id: String, endpoints: Vec<String>, cert_hash: String },
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
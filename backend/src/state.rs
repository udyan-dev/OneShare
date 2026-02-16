use axum::extract::ws::Message;
use dashmap::{DashMap, DashSet};
use fred::prelude::*;
use std::sync::Arc;
use tokio::sync::mpsc;

pub type WsSender = mpsc::UnboundedSender<Message>;

pub struct AppState {
    pub redis: Client,
    pub redis_subscriber: Client,
    pub local_clients: DashMap<String, WsSender>,
    pub local_rooms: DashMap<String, DashSet<String>>,
    pub client_to_room: DashMap<String, String>,
}

impl AppState {
    pub async fn new(redis_url: &str) -> Arc<Self> {
        let config = Config::from_url(redis_url).expect("Invalid Redis URL");
        let redis = Builder::from_config(config.clone()).build().expect("Failed to build Redis pool");
        redis.init().await.expect("Failed to connect to Redis");
        let redis_subscriber = Builder::from_config(config).build().expect("Failed to build Redis sub");
        redis_subscriber.init().await.expect("Failed to connect to Redis Sub");
        Arc::new(Self { redis, redis_subscriber, local_clients: DashMap::new(), local_rooms: DashMap::new(), client_to_room: DashMap::new() })
    }
}
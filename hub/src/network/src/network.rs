use std::collections::HashMap;

use candid::{CandidType, Deserialize};
use ic_stable_memory::derive::{CandidAsDynSizeBytes, StableType};
use lazy_static::lazy_static;

const hardhat_deployed_contracts: &str = include_str!("../../../../contracts/deployments/hardhat.json");

#[derive(
    CandidType,
    Debug,
    Clone,
    PartialEq,
    PartialOrd,
    Deserialize,
    StableType,
    CandidAsDynSizeBytes,
    Default,
    Eq,
    Hash,
    Copy,
)]
pub enum SupportedNetwork {
    Mainnet,
    Ropsten,
    Rinkeby,
    Kovan,
    Goerli,
    #[default]
    Local,
}
#[derive(
    CandidType,
    Debug,
    Clone,
    PartialEq,
    PartialOrd,
    Deserialize,
    StableType,
    CandidAsDynSizeBytes,
    Default,
    Eq,
    Hash,
)]
pub struct NetworkInfo {
    pub name: String,
    pub chain_id: u32,
    pub network: SupportedNetwork,
    pub rpc_url: String,
    pub key_name: String,
}

impl NetworkInfo {
    pub fn get_network_info(network: SupportedNetwork) -> NetworkInfo {
        NETWORKS.get(&network).unwrap().clone()
    }
}
lazy_static! {
    pub static ref NETWORKS: HashMap<SupportedNetwork, NetworkInfo> = {
        let mut map = HashMap::new();
        map.insert(
            SupportedNetwork::Mainnet,
            NetworkInfo {
                name: "Mainnet".to_string(),
                chain_id: 1,
                network: SupportedNetwork::Mainnet,
                rpc_url: "https://mainnet.infura.io/v3/".to_string(),
                key_name: "TODO".to_string(),
            },
        );
        map.insert(
            SupportedNetwork::Ropsten,
            NetworkInfo {
                name: "Ropsten".to_string(),
                chain_id: 3,
                network: SupportedNetwork::Ropsten,
                rpc_url: "https://ropsten.infura.io/v3/".to_string(),
                key_name: "TODO".to_string(),
            },
        );
        map.insert(
            SupportedNetwork::Rinkeby,
            NetworkInfo {
                name: "Rinkeby".to_string(),
                chain_id: 4,
                network: SupportedNetwork::Rinkeby,
                rpc_url: "https://rinkeby.infura.io/v3/".to_string(),
                key_name: "TODO".to_string(),
            },
        );
        map.insert(
            SupportedNetwork::Kovan,
            NetworkInfo {
                name: "Kovan".to_string(),
                chain_id: 42,
                network: SupportedNetwork::Kovan,
                rpc_url: "https://kovan.infura.io/v3/".to_string(),
                key_name: "TODO".to_string(),
            },
        );
        map.insert(
            SupportedNetwork::Goerli,
            NetworkInfo {
                name: "Goerli".to_string(),
                chain_id: 5,
                network: SupportedNetwork::Goerli,
                rpc_url: "https://goerli.infura.io/v3/".to_string(),
                key_name: "TODO".to_string(),
            },
        );
        map.insert(
            SupportedNetwork::Local,
            NetworkInfo {
                name: "Local".to_string(),
                chain_id: 1337,
                network: SupportedNetwork::Local,
                rpc_url: "http://localhost:8545".to_string(),
                key_name: "TODO".to_string(),
            },
        );
        map
    };
}

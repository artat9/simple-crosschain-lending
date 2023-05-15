use std::str::FromStr;

use ic_web3::{ethabi::Address, types::U256};
use network::{
    contract::{ctx, ICSAdapter, ILendingPool},
    network::SupportedNetwork,
};

const HF_BASE: u128 = 1_000_000_000_000_000_000;

//use network::{contract::{lending_pool, cs_adapter}, network::SupportedNetwork};
pub struct LiquidateParam {
    pub network: SupportedNetwork,
    pub user: String,
    pub collateral: String,
    pub debt: String,
    pub debt_to_cover: U256,
}

async fn liquidate(param: LiquidateParam) {
    let context = ctx(param.network).unwrap();
    let adapter = ICSAdapter::new(Address::from_low_u64_le(1), &context);
    let hf = adapter
        .health_factor_of(Address::from_str(&param.user).unwrap())
        .await
        .unwrap();
    if hf.gt(&U256::from(HF_BASE)) {
        println!("health factor is greater than 1");
        return;
    }
    let result = adapter
        .liquidation_call_on_behalf_of(
            param.collateral,
            param.debt,
            Address::from_str(&param.user).unwrap(),
            // TODO: on behalf of
            Address::from_str(&param.user).unwrap(),
            param.debt_to_cover.clone(),
            false,
        )
        .await
        .unwrap();
    // TODO: get covered amount
    let covered = U256::from(100);
    if covered.gt(&param.debt_to_cover) {
        return;
    }
    // liquidate @another network
}

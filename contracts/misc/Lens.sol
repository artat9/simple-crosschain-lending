// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "contracts/misc/DataTypes.sol";

contract Lens {
    using DataTypes for DataTypes.ReserveData;
    address public priceOracle;
    address public lendingPool;

    struct AccountAssetData {
        AssetData assetData;
        DataTypes.UserConfigurationMap userConfiguration;
        DataTypes.ReserveData reserveData; 
    }

    struct AssetData {
        uint256 price;
        uint256 amountInEth;
    }

    struct UserData {
        uint256 totalCollateralInEth;
        uint256 totalDebtInEth;
        uint256 avgLiquidationThreshold;
    }

    constructor(address _priceOracle, address _lendingPool) {
        priceOracle = _priceOracle;
        lendingPool = _lendingPool;
    }
}
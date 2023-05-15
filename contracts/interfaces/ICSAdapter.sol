// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface ICSAdapter {
    // lock withdraw of asset.
    function lockAssetOf(
        address user,
        string memory symbol
    ) external view returns (address);

    // unlock withdraw of asset.
    function unlockAssetOf(
        address user,
        string memory symbol
    ) external view returns (address);

    // health factor of an user.
    function healthFactorOf(address user) external view returns (uint256);

    // call liquidation on behalf of an user.
    function liquidationCallOnBehalfOf(
        string calldata collateralAsset,
        string calldata debtAsset,
        address user,
        address onBehalfOf,
        uint256 debtToCover,
        bool receiveLiquidity
    ) external returns (uint256);

    function csLiquidatable(
        string calldata collateralAsset,
        address user,
        uint256 debtToCover
    ) external view returns (bool);

    function csLiquidate(
        string calldata collateralAsset,
        address user,
        address onBehalfOf,
        uint256 debtToCover
    ) external returns (uint256);
}

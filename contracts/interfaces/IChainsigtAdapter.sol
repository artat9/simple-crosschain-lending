// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IChainsigtAdapter {
    // lock withdraw of asset.
    function lockAssetOf(
        address user,
        string memory symbol,
        uint256 amount,
        uint256 dstChainId
    ) external;

    // unlock withdraw of asset.
    function unlockAssetOf(
        address user,
        string memory symbol,
        uint256 amount,
        uint256 srcChainId
    ) external;

    // health factor of an user.
    function healthFactorOf(address user) external view returns (uint256);

    // call liquidation on behalf of an user.
    function liquidationCallOnBehalfOf(
        string calldata collateralAsset,
        string calldata debtAsset,
        address user,
        address onBehalfOf,
        uint256 debtToCover
    ) external returns (uint256);
}

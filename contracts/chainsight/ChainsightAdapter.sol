// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "../interfaces/IChainsigtAdapter.sol";
import "../interfaces/ILendingPool.sol";
import "../interfaces/ICreditToken.sol";

contract ChainsightAdapter is IChainsigtAdapter {

    address public lendingPool;

    constructor(address _lendingPool) {
        lendingPool = _lendingPool;
    }

    function symbolToAddress(string memory symbol) internal returns (address) {
        return ILendingPool(lendingPool).assetAddresses(symbol);
    }
    
    // lock withdraw of asset.
    function lockAssetOf(
        address user,
        string memory symbol,
        uint256 amount,
        uint256 dstChainId
    ) external override {
        address asset = symbolToAddress(symbol);
        require(asset != address(0), "invalid asset");
        address creditTokenAddress = ILendingPool(lendingPool).creditTokenAddress(asset);
        ICreditToken(creditTokenAddress).lockFor(user, amount, dstChainId);
    }

    function unlockAssetOf(
        address user,
        string memory symbol,
        uint256 amount,
        uint256 srcChainId
    ) external override {
        address asset = symbolToAddress(symbol);
        require(asset != address(0), "invalid asset");
        address creditTokenAddress = ILendingPool(lendingPool).creditTokenAddress(asset);
        ICreditToken(creditTokenAddress).onLockCreated(user, amount, srcChainId);
    }


    // health factor of an user.
    function healthFactorOf(address user) external view returns (uint256) {
        return _healthFactorOf(user);
    }

    function _healthFactorOf(address user) internal view returns (uint256) {
        return ILendingPool(lendingPool).healthFactorOf(user);
    }

    // call liquidation on behalf of an user.
    function liquidationCallOnBehalfOf(
        string calldata collateralAsset,
        string calldata debtAsset,
        address user,
        address onBehalfOf,
        uint256 debtToCover
    ) external override returns (uint256) {
        require(_healthFactorOf(user) < 1e18, "user is healthy");
        address col = symbolToAddress(collateralAsset);
        address debt = symbolToAddress(debtAsset);
        require(col != address(0) && debt != address(0), "invalid asset");
        return ILendingPool(lendingPool).liquidationCallByChainsight(col, debt, user, debtToCover, onBehalfOf);
    }
}
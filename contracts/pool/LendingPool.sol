// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "contracts/interfaces/ILendingPool.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "contracts/interfaces/ICreditToken.sol";
import "contracts/interfaces/IDebtToken.sol";
import "contracts/interfaces/IRiskModel.sol";
import "contracts/interfaces/IPriceOracle.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "contracts/interfaces/IRiskModel.sol";

contract LendingPool is ILendingPool, Ownable {
    struct Asset {
        IERC20 asset;
        string symbol;
        ICreditToken creditToken;
        IDebtToken debtToken;
    }

    struct AddAssetInput {
        address assetAddress;
        string symbol;
        address creditTokenAddress;
        address debtTokenAddress;
        IRiskModel.RiskParameter riskParameter;
    }

    struct HealthFactorInput {
        address asset;
        uint256 debt;
        uint256 collateral;
    }

    Asset[] public assets;

    IRiskModel public riskModel;

    bool public initialized;

    IPriceOracle public priceOracle;

    uint256 public HF_BASE = 1 ether;

    function initialize(
        address _riskModelAddress,
        address _priceOracle
    ) external onlyOwner {
        require(!initialized, "Already initialized");
        riskModel = IRiskModel(_riskModelAddress);
        priceOracle = IPriceOracle(_priceOracle);
        initialized = true;
    }

    function liquidationCall(
        string calldata collateralAsset,
        string calldata debtAsset,
        address user,
        uint256 debtToCover,
        bool receiveLiquidity
    ) external override {
        revert("todo");
    }

    function _healthFactor(
        HealthFactorInput[] memory inputs
    ) internal view returns (uint256) {
        uint256 totalBorrowsInUsd = 0;
        uint256 totalCollateralInUsdMulLiquidationThreshold = 0;
        for (uint256 i = 0; i < inputs.length; i++) {
            HealthFactorInput memory input = inputs[i];
            totalBorrowsInUsd += amountInUsd(input.asset, input.debt);
            totalCollateralInUsdMulLiquidationThreshold +=
                (amountInUsd(input.asset, input.collateral) *
                    riskModel
                        .riskParameters(input.asset)
                        .liquidationThreshold) /
                riskModel.BASE();
        }
        return
            (totalCollateralInUsdMulLiquidationThreshold * HF_BASE) /
            totalBorrowsInUsd;
    }

    function healthFactorOf(
        address user
    ) external view override returns (uint256) {
        HealthFactorInput[] memory inputs = new HealthFactorInput[](
            assets.length
        );
        for (uint256 i = 0; i < assets.length; i++) {
            inputs[i] = HealthFactorInput(
                address(assets[i].asset),
                assets[i].debtToken.balanceOf(user),
                assets[i].creditToken.balanceOf(user)
            );
        }
        return _healthFactor(inputs);
    }

    function amountInUsd(
        address _asset,
        uint256 amount
    ) internal view returns (uint256) {
        Asset memory asset;
        for (uint256 i = 0; i < assets.length; i++) {
            if (address(assets[i].asset) == _asset) {
                asset = assets[i];
                break;
            }
        }
        if (address(asset.asset) == address(0)) {
            revert("Asset not found");
        }
        uint256 price = priceOracle.getPriceInUsd(asset.symbol);
        return (price * amount) / priceOracle.BASE();
    }

    function addAsset(AddAssetInput memory input) external onlyOwner {
        assets.push(
            Asset(
                IERC20(input.assetAddress),
                input.symbol,
                ICreditToken(input.creditTokenAddress),
                IDebtToken(input.debtTokenAddress)
            )
        );
        riskModel.supportToken(
            input.assetAddress,
            input.riskParameter.ltv,
            input.riskParameter.liquidationThreshold,
            input.riskParameter.liquidationBonus
        );
    }

    function validateDeposit(
        address user,
        address asset,
        uint256 amount
    ) internal view returns (bool) {
        for (uint256 i = 0; i < assets.length; i++) {
            if (address(assets[i].asset) == asset) {
                return true;
            }
        }
        return false;
    }

    function deposit(address asset, uint256 amount) external override {
        require(validateDeposit(msg.sender, asset, amount), "Invalid asset");
        IERC20(asset).transferFrom(msg.sender, address(this), amount);
        for (uint256 i = 0; i < assets.length; i++) {
            if (address(assets[i].asset) == asset) {
                assets[i].creditToken.mint(msg.sender, amount);
            }
        }
    }

    function withdraw(
        address asset,
        uint256 amount
    ) external override returns (uint256) {
        for (uint256 i = 0; i < assets.length; i++) {
            if (address(assets[i].asset) == asset) {
                assets[i].creditToken.burn(msg.sender, amount);
                IERC20(asset).transfer(msg.sender, amount);
                return amount;
            }
        }
        return 0;
    }

    function borrow(address asset, uint256 amount) external override {}

    function repay(address asset, uint256 amount) external override {}
}

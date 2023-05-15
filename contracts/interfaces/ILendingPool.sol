// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface ILendingPool {
    function deposit(address asset, uint256 amount) external;

    function withdraw(address asset, uint256 amount) external returns (uint256);

    function borrow(address asset, uint256 amount) external;

    function repay(address asset, uint256 amount) external;

    function healthFactorOf(address user) external view returns (uint256);

    function liquidationCall(
        string calldata collateralAsset,
        string calldata debtAsset,
        address user,
        uint256 debtToCover,
        bool receiveLiquidity
    ) external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/access/Ownable.sol";
import "contracts/interfaces/IRiskModel.sol";

contract RiskModel is Ownable, IRiskModel {
    uint256 public override BASE = 1 ether;

    mapping(address => RiskParameter) public _riskParameters;
    address public _lendingPool;

    constructor(address lendingPool) {
        _lendingPool = lendingPool;
    }

    modifier onlyLendingPool() {
        require(msg.sender == _lendingPool, "Only lending pool");
        _;
    }

    function supportToken(
        address token,
        uint256 ltv,
        uint256 liquidationThreshold,
        uint256 liquidationBonus
    ) external onlyLendingPool {
        _riskParameters[token] = RiskParameter(
            ltv,
            liquidationThreshold,
            liquidationBonus
        );
    }

    function riskParameters(
        address token
    ) external view override returns (RiskParameter memory) {
        return _riskParameters[token];
    }
}

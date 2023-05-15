// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "contracts/interfaces/IPriceOracle.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MockPriceOracle is IPriceOracle, Ownable {
    mapping(string => uint256) prices;

    function getPriceInUsd(
        string memory symbol
    ) public view override returns (uint256) {
        return prices[symbol];
    }

    function setPrice(string memory symbol, uint256 price) public onlyOwner {
        prices[symbol] = price;
    }

    function BASE() external pure override returns (uint256) {
        return 1 ether;
    }
}

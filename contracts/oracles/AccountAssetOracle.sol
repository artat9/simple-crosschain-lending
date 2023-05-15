// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/access/Ownable.sol";
import "contracts/interfaces/IAccountAssetOracle.sol";

contract AccountAssetOracle is Ownable, IAccountAssetOracle {
    string public networkName;
    address public manager;

    struct AccountInfo {
        mapping(string => uint256) deposit;
        mapping(string => uint256) borrow;
        uint256 updatedAt;
    }

    mapping(address => AccountInfo) accountInfo;

    modifier onlyManager() {
        require(msg.sender == manager, "Only manager can call this function");
        _;
    }

    constructor(string memory _networkName) {
        networkName = _networkName;
    }

    function setNetworkName(string memory _networkName) public onlyOwner {
        networkName = _networkName;
    }

    function setManager(address _manager) public onlyOwner {
        manager = _manager;
    }

    function getDeposit(
        address _account,
        string memory symbol
    ) public view override returns (uint256) {
        return accountInfo[_account].deposit[symbol];
    }

    function getBorrow(
        address _account,
        string memory symbol
    ) public view override returns (uint256) {
        return accountInfo[_account].borrow[symbol];
    }

    function updateAccountInfo(
        address _account,
        string[] memory symbols,
        uint256[] memory _deposits,
        uint256[] memory _borrows
    ) public onlyManager {
        require(
            symbols.length == _deposits.length &&
                symbols.length == _borrows.length,
            "Array lengths must be equal"
        );

        for (uint256 i = 0; i < symbols.length; i++) {
            accountInfo[_account].deposit[symbols[i]] = _deposits[i];
            accountInfo[_account].borrow[symbols[i]] = _borrows[i];
        }

        accountInfo[_account].updatedAt = block.timestamp;
    }
}

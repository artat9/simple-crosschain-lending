// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "contracts/interfaces/IDebtToken.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DebtToken is ERC20, Ownable, IDebtToken {
    address public lendingPool;
    address public UNDERLYING_ASSET_ADDRESS;
    bool public initialized;

    modifier onlyLendingPool() {
        require(
            msg.sender == lendingPool,
            "Only lending pool can call this function"
        );
        _;
    }

    function initialize(
        address _lendingPool,
        address underlying
    ) public onlyOwner {
        require(!initialized, "Already initialized");
        lendingPool = _lendingPool;
        UNDERLYING_ASSET_ADDRESS = underlying;
        initialized = true;
    }

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    // mint can only be called by lending pool
    function mint(
        address account,
        uint256 amount
    ) public override onlyLendingPool {
        _mint(account, amount);
    }

    function burn(
        address account,
        uint256 amount
    ) public override onlyLendingPool {
        _burn(account, amount);
    }

    // disable transfer
    function transfer(address recipient, uint256 amount)
        public pure override(IERC20, ERC20)
        returns (bool)
    {
        revert("Disabled");
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public pure override(IERC20, ERC20) returns (bool) {
        revert("Disabled");
    }
}

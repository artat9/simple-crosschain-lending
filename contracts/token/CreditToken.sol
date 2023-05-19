// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "../interfaces/ICreditToken.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CreditToken is ERC20, Ownable, ICreditToken {
    address public lendingPool;
    address public UNDERLYING_ASSET_ADDRESS;
    address public chainsight;
    bool public initialized;
    mapping(address => mapping(uint256 => CrossChainAsset)) crossChainAssets;

    struct CrossChainAsset {
        uint256 amountLockedFor;
        uint256 amountLockedFrom;
    }

    uint256[] public knownChainIds;
    mapping(uint256 => bool) public chainIdExists;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    modifier onlyChainsight() {
        require(
            msg.sender == chainsight,
            "Only chainsight can call this function"
        );
        _;
    }

    modifier onlyLendingPool() {
        require(
            msg.sender == lendingPool,
            "Only lending pool can call this function"
        );
        _;
    }
    

    function setChainsight(address _chainsight) external override onlyOwner {
        chainsight = _chainsight;
    }

    function initialize(
        address _lendingPool,
        address underlying,
        address _chainsight
    ) public onlyOwner {
        require(!initialized, "Already initialized");
        lendingPool = _lendingPool;
        UNDERLYING_ASSET_ADDRESS = underlying;
        chainsight = _chainsight;
        initialized = true;
    }

    function setLendingPool(address _lendingPool) external override onlyOwner {
        lendingPool = _lendingPool;
    }
    function transferUnderlyingTo(address account, uint256 amount)
        public
        override
        onlyLendingPool
    {
        IERC20(UNDERLYING_ASSET_ADDRESS).transfer(account, amount);
    }
    
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        require(unlockedBalanceOf(sender) >= amount, "Insufficient balance");
        super._transfer(sender, recipient, amount);
    }

    function unlockedBalanceOf(address account)
        public
        view
        override
        returns (uint256)
    {
        return balanceOf(account) - lockedBalanceOf(account);
    }

    function lockedBalanceOf(
        address account
    ) public view override returns (uint256) {
        uint256 totalLockedBalance;
        for (uint256 i = 0; i < knownChainIds.length; i++) {
            totalLockedBalance += crossChainAssets[account][knownChainIds[i]]
                .amountLockedFor;
        }
        return totalLockedBalance;
    }

    function receivedAmountOf(address account) internal view returns (uint256) {
        uint256 totalReceivedAmount;
        for (uint256 i = 0; i < knownChainIds.length; i++) {
            totalReceivedAmount += crossChainAssets[account][knownChainIds[i]]
                .amountLockedFrom;
        }
        return totalReceivedAmount;
    }

    function onLockCreated(
        address account,
        uint256 amount,
        uint256 srcChainId
    ) external override onlyChainsight {
        knowChainId(srcChainId);
        crossChainAssets[account][srcChainId].amountLockedFrom += amount;
    }

    function knowChainId(uint256 chainId) internal {
        if (!chainIdExists[chainId]) {
            knownChainIds.push(chainId);
            chainIdExists[chainId] = true;
        }
    }

    function transferOnLiquidation(address from, address to, uint256 amount)
        public
        override
        onlyLendingPool
    {
        _transfer(from, to, amount);        
    }

    function collateralAmountOf(
        address account
    ) public view override returns (uint256) {
        return unlockedBalanceOf(account) + receivedAmountOf(account);
    }

    function lockFor(
        address account,
        uint256 amount,
        uint256 dstChainId
    ) public override onlyLendingPool {
        knowChainId(dstChainId);
        require(unlockedBalanceOf(account) >= amount, "Insufficient balance");
        CrossChainAsset storage crossChainAsset = crossChainAssets[account][
            dstChainId
        ];
        emit LockCreated(account, amount, dstChainId);   
        
        if (crossChainAsset.amountLockedFrom == 0){
            crossChainAsset.amountLockedFor = amount;
            return;
        } 
        if (crossChainAsset.amountLockedFrom >= amount) {
            crossChainAsset.amountLockedFrom -= amount;
            return;
        }
        crossChainAsset.amountLockedFor += amount - crossChainAsset.amountLockedFrom;
        crossChainAsset.amountLockedFrom = 0;  
    }
    

    // mint can only be called by lending pool
    function mint(
        address account,
        uint256 amount
    ) public override onlyLendingPool {
        _mint(account, amount);
    }

    function burn(
        address account,
        address receiver,
        uint256 amount
    ) public override onlyLendingPool {
        _burn(account, amount);
        IERC20(UNDERLYING_ASSET_ADDRESS).transfer(receiver, amount);
    }
}

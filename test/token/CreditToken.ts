import { expect } from 'chai';
import { ethers } from 'hardhat';

describe('CreditToken', function () {
  it('should deploy', async function () {
    const CreditToken = await ethers.getContractFactory('CreditToken');
    const creditToken = await CreditToken.deploy('Credit', 'Credit');
    await creditToken.deployed();
    expect(await creditToken.name()).to.equal('Credit');
    expect(await creditToken.symbol()).to.equal('Credit');
  });
  it('should initialize', async function () {
    const CreditToken = await ethers.getContractFactory('CreditToken');
    const creditToken = await CreditToken.deploy('Credit', 'Credit');
    await creditToken.deployed();
    const [lendPool, underlying] = await ethers.getSigners();
    await creditToken.initialize(
      await lendPool.getAddress(),
      await underlying.getAddress()
    );
    expect(await creditToken.lendingPool()).to.equal(
      await lendPool.getAddress()
    );
    expect(await creditToken.UNDERLYING_ASSET_ADDRESS()).to.equal(
      await underlying.getAddress()
    );
  });
  it('should mint', async function () {
    const CreditToken = await ethers.getContractFactory('CreditToken');
    const creditToken = await CreditToken.deploy('Credit', 'Credit');
    await creditToken.deployed();
    const [lendPool, underlying, user] = await ethers.getSigners();
    await creditToken.initialize(
      await lendPool.getAddress(),
      await underlying.getAddress()
    );
    await creditToken.connect(lendPool).mint(await user.getAddress(), 100);
    expect(await creditToken.balanceOf(await user.getAddress())).to.equal(100);
    await expect(
      creditToken.connect(underlying).mint(await user.getAddress(), 100)
    ).to.be.revertedWith('Only lending pool can call this function');
  });
  it('should burn', async function () {
    const CreditToken = await ethers.getContractFactory('CreditToken');
    const creditToken = await CreditToken.deploy('Credit', 'Credit');
    await creditToken.deployed();
    const [lendPool, underlying, user] = await ethers.getSigners();
    await creditToken.initialize(
      await lendPool.getAddress(),
      await underlying.getAddress()
    );
    await creditToken.connect(lendPool).mint(await user.getAddress(), 100);
    expect(await creditToken.balanceOf(await user.getAddress())).to.equal(100);
    await creditToken.connect(lendPool).burn(await user.getAddress(), 100);
    expect(await creditToken.balanceOf(await user.getAddress())).to.equal(0);
    await expect(
      creditToken.connect(underlying).burn(await user.getAddress(), 100)
    ).to.be.revertedWith('Only lending pool can call this function');
  });
});

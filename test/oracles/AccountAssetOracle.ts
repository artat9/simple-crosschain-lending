import { expect } from 'chai';
import { ethers } from 'hardhat';

describe('AccountAssetOracle', function () {
  it('Should be able to deploy', async function () {
    const assetOracle = await ethers.getContractFactory('AccountAssetOracle');
    await assetOracle.deploy('hardhat');
  });
  it('Should be able to set network name', async function () {
    const assetOracle = await ethers.getContractFactory('AccountAssetOracle');
    const instance = await assetOracle.deploy('hardhat');
    expect(await instance.networkName()).to.equal('hardhat');
    await instance.setNetworkName('test');
    expect(await instance.networkName()).to.equal('test');
  });
  it('Should be able to set manager', async function () {
    const assetOracle = await ethers.getContractFactory('AccountAssetOracle');
    const instance = await assetOracle.deploy('hardhat');
    const [manager] = await ethers.getSigners();
    await instance.setManager(await manager.getAddress());
    expect(await instance.manager()).to.equal(await manager.getAddress());
  });
  it('Should be able to update account info', async function () {
    const assetOracle = await ethers.getContractFactory('AccountAssetOracle');
    const instance = await assetOracle.deploy('hardhat');
    const [manager] = await ethers.getSigners();
    const symbol = 'USDC';
    await instance.setManager(await manager.getAddress());
    await instance.updateAccountInfo(
      await manager.getAddress(),
      [symbol],
      [1],
      [2]
    );
    const deposit = await instance.getDeposit(
      await manager.getAddress(),
      symbol
    );
    const borrow = await instance.getBorrow(await manager.getAddress(), symbol);
    expect(deposit).to.equal(1);
    expect(borrow).to.equal(2);
  });
});

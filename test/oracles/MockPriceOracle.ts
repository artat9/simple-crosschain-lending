import { expect } from 'chai';
import { ethers } from 'hardhat';

describe('MockPriceOracle', function () {
  it('Should be able to deploy', async function () {
    const mockPriceOracle = await ethers.getContractFactory('MockPriceOracle');
    await mockPriceOracle.deploy();
  });
  it('Should be able to set price', async function () {
    const mockPriceOracle = await ethers.getContractFactory('MockPriceOracle');
    const instance = await mockPriceOracle.deploy();
    const [manager] = await ethers.getSigners();
    await instance.setPrice(await manager.getAddress(), 1);
    expect(await instance.getPriceInUsd(await manager.getAddress())).to.equal(
      1
    );
  });
});

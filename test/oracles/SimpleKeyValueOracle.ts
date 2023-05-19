import { expect } from 'chai';
import { ethers } from 'hardhat';

describe('SimpleKeyValueOracle', function () {
  it('should deploy', async function () {
    const oracle = await ethers.getContractFactory('SimpleKeyValueOracle');
    await oracle.deploy();
  });
  it('should set price', async function () {
    const oracle = await ethers.getContractFactory('SimpleKeyValueOracle');
    const instance = await oracle.deploy();
    const [manager] = await ethers.getSigners();
    await instance.setPrice(await manager.getAddress(), 1);
    expect(await instance.getPriceInUsd(await manager.getAddress())).to.equal(
      1
    );
  });
});

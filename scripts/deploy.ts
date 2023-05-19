import { ethers } from 'hardhat';
import { deployMockToken } from './contracts/helpers';
import { ZERO_ADDRESS } from './contracts/utils';
import { saveAddress } from './deployments/contracts';
const TOKENS_COUNT = 2;
const main = async () => {
  const LendingPool = await ethers.getContractFactory('LendingPool');
  const lendingPool = await LendingPool.deploy();
  await lendingPool.deployed();
  await saveAddress('LendingPool', lendingPool.address);
  let tokens = [];

  for (const i of Array(TOKENS_COUNT).keys()) {
    const { creditToken, debtToken, mintableERC20 } = await deployMockToken(
      `TST${i}`,
      `Test${i}`
    );
    await creditToken.initialize(
      lendingPool.address,
      mintableERC20.address,
      ZERO_ADDRESS
    );
    await debtToken.initialize(lendingPool.address, mintableERC20.address);
    await lendingPool.initReserve(
      mintableERC20.address,
      creditToken.address,
      debtToken.address
    );
    tokens.push({
      mintableERC20,
      creditToken,
      debtToken,
    });
  }

  const oracle = await (
    await ethers.getContractFactory('SimpleKeyValueOracle')
  ).deploy();
  await oracle.deployed();
  await saveAddress('Oracle', oracle.address);
  await lendingPool.setOracle(oracle.address);
  const adapter = await (
    await ethers.getContractFactory('ChainsightAdapter')
  ).deploy(lendingPool.address);
  await saveAddress('ChainsightAdapter', adapter.address);

  return {
    lendingPool,
    tokens: {
      0: tokens[0],
      1: tokens[1],
    },
    oracle,
    adapter,
  };
};
main()
  .then((result) => {
    console.log('LendingPool deployed to:', result.lendingPool.address);
    for (const token of Object.values(result.tokens)) {
      console.log('MintableERC20 deployed to:', token.mintableERC20.address);
      console.log('CreditToken deployed to:', token.creditToken.address);
      console.log('DebtToken deployed to:', token.debtToken.address);
    }
    console.log('Oracle deployed to:', result.oracle.address);
    console.log('ChainsightAdapter deployed to:', result.adapter.address);
  })
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

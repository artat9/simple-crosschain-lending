import { ethers } from 'hardhat';
import { saveAddress } from '../deployments/contracts';

export const deployMockToken = async (symbol: string, name: string) => {
  const mintableERC20 = await (
    await ethers.getContractFactory('MintableErc20')
  ).deploy(name, symbol);
  await saveAddress(`MintableErc20-${symbol}`, mintableERC20.address);
  const creditToken = await (
    await ethers.getContractFactory('CreditToken')
  ).deploy(`Credit ${name}`, `CRD${symbol}`);
  await saveAddress(`CreditToken-${symbol}`, creditToken.address);
  const debtToken = await (
    await ethers.getContractFactory('DebtToken')
  ).deploy(`Debt ${name}`, `DBT${symbol}`);
  await saveAddress(`DebtToken-${symbol}`, debtToken.address);
  return { mintableERC20, creditToken, debtToken };
};

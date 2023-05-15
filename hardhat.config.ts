import { HardhatUserConfig } from 'hardhat/config';
import '@nomicfoundation/hardhat-toolbox';
import 'hardhat-abi-exporter';
const config: HardhatUserConfig = {
  solidity: '0.8.18',
  abiExporter: {
    path: './abi',
    clear: true,
    flat: true,
    only: ['interfaces'],
    runOnCompile: true,
  },
};

export default config;

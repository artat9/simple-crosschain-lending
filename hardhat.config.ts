import { HardhatUserConfig } from 'hardhat/config';
import '@nomicfoundation/hardhat-toolbox';
import 'hardhat-abi-exporter';
const config: HardhatUserConfig = {
  solidity: {
    compilers: [{ version: '0.8.9' }],
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000,
      },
    },
  },
};

export default config;

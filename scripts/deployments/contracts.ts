import hre from 'hardhat';
export const saveAddress = async (name: string, address: string) => {
  const network = hre.network.name;
  const path = `./contracts/deployments/${network}.json`;
  const fs = require('fs');
  // create file if not exists
  if (!fs.existsSync(path)) {
    fs.writeFileSync(path, '{}');
  }
  const data = JSON.parse(fs.readFileSync(path, 'utf8'));
  data[name] = address;
  fs.writeFileSync(path, JSON.stringify(data));
};

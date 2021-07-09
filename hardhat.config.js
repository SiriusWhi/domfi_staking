/* Hardhat and module imports */

require('@nomiclabs/hardhat-ethers');
require('hardhat-deploy');
require('@nomiclabs/hardhat-etherscan');
require('dotenv').config();

/* Tasks imports */

// ------------ //

/* Configurations */

module.exports = {
  defaultNetwork: 'rinkeby',
  networks: {
    rinkeby: {
      url: process.env.RPC_RINKEYBY,
      accounts: [process.env.PRIVATE_KEY],
      saveDeployments: true,
    },
  },
  solidity: {
    compilers: [
      {
        version: '0.8.5',
      },
    ],
  },
  paths: {
    sources: './contracts',
    tests: './test',
    cache: './cache',
    artifacts: './artifacts',
  },
  namedAccounts: {
    deployer: {
      default: process.env.ADDRESS,
    },
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
};

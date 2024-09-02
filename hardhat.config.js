require('dotenv').config(); // Эта строка загружает переменные из файла .env
require('@nomiclabs/hardhat-ethers');

module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.26",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          }
        }
      },
      {
        version: "0.8.0", // Добавьте другие версии, если нужно
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          }
        }
      }
    ]
  },
  networks: {
    arbitrum: {
      url: process.env.ARB_RPC_URL,
      accounts: [process.env.PRIVATE_KEY]
    }
  }
};


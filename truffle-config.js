require("dotenv").config()
const HDWalletProvider = require('@truffle/hdwallet-provider');

module.exports = {
  /**
   * Networks define how you connect to your ethereum client and let you set the
   * defaults web3 uses to send transactions. If you don't specify one truffle
   * will spin up a development blockchain for you on port 9545 when you
   * run `develop` or `test`. You can ask a truffle command to use a specific
   * network from the command line, e.g
   *
   * $ truffle test --network <network-name>
   */

  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*",
     },
     mainnet: {
       provider: () => new HDWalletProvider([process.env.PRIVATE_KEY], `https://mainnet.infura.io/v3/${process.env.INFURA_KEY}`),
       network_id: 1,       // mainnet's id
       //gas: 5500000,        // mainnet has a lower block limit than mainnet
       confirmations: 2,    // # of confs to wait between deployments. (default: 0)
       timeoutBlocks: 200,  // # of blocks before a deployment times out  (minimum/default: 50)
       skipDryRun: true     // Skip dry run before migrations? (default: false for public nets )
     },
     rinkeby: {
       provider: () => new HDWalletProvider([process.env.PRIVATE_KEY], `https://rinkeby.infura.io/v3/${process.env.INFURA_KEY}`),
       network_id: 4,       // rinkeby's id
       //gas: 5500000,        // rinkeby has a lower block limit than mainnet
       confirmations: 0,    // # of confs to wait between deployments. (default: 0)
       timeoutBlocks: 200,  // # of blocks before a deployment times out  (minimum/default: 50)
       skipDryRun: true     // Skip dry run before migrations? (default: false for public nets )
     },
     bsctestnet: {
       provider: () => new HDWalletProvider([process.env.PRIVATE_KEY], `https://data-seed-prebsc-1-s1.binance.org:8545`),
       network_id: 97,       // bsctestnet's id
       //gas: 5500000,        // bsctestnet has a lower block limit than mainnet
       confirmations: 0,    // # of confs to wait between deployments. (default: 0)
       timeoutBlocks: 200,  // # of blocks before a deployment times out  (minimum/default: 50)
       skipDryRun: true     // Skip dry run before migrations? (default: false for public nets )
     },
     bsc: {
       provider: () => new HDWalletProvider([process.env.PRIVATE_KEY], `https://bsc-private-dataseed1.nariox.org`),
       network_id: 56,       // bsc's id
       //gas: 5500000,        // bsc has a lower block limit than mainnet
       confirmations: 2,    // # of confs to wait between deployments. (default: 0)
       timeoutBlocks: 200,  // # of blocks before a deployment times out  (minimum/default: 50)
       skipDryRun: true     // Skip dry run before migrations? (default: false for public nets )
     },
  },

  // Set default mocha options here, use special reporters etc.
  mocha: {
    // timeout: 100000
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: "0.6.12",
      docker: false,
      settings: {
       optimizer: {
         enabled: true,
         runs: 200
       },
      }
    }
  },

  plugins: [
    'truffle-plugin-verify',
    'truffle-contract-size'
  ],

  api_keys: {
    etherscan: process.env.ETHERSCAN_API_KEY,
    bscscan: process.env.BSC_SCAN_API_KEY
  }
};

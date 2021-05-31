require("dotenv").config();
const fs = require('fs');
const path = require('path');
const BN = require("bignumber.js");

const InnoxFactory = artifacts.require("BoostVolume");

module.exports = async function (deployer, network, addresses) {
    console.log('Contracts Deployment have been saved to `deploymentResults.json`')
};

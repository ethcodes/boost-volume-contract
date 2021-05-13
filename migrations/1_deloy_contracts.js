require("dotenv").config();
const fs = require('fs');
const path = require('path');
const BN = require("bignumber.js");

const InnoxFactory = artifacts.require("BoostVolume");

module.exports = async function (deployer, network, addresses) {
    const {FEE_AMT, FEE_TOKEN} = process.env;
    if(!FEE_AMT || !FEE_TOKEN) throw "invalid argument";

    await deployer.deploy(BoostVolume, FEE_TOKEN, FEE_AMT);
    const BoostVolumeInstance = await BoostVolume.deployed();

    await deployer.deploy(PoolxFactory, FEE_TOKEN, FEE_AMT);
    const PoolxFactoryInstance = await PoolxFactory.deployed();

    await InnoxFactoryInstance.setPoolxFactory(PoolxFactoryInstance.address);
    await PoolxFactoryInstance.setInnoxFactory(InnoxFactoryInstance.address);

    const deployResultsPath = path.join(__dirname, '../deploymentResults.json')
    if (!fs.existsSync(deployResultsPath)) fs.writeFileSync(deployResultsPath, JSON.stringify({}));
    const deployResult = fs.readFileSync(deployResultsPath, { encoding: 'utf-8' })
    fs.writeFileSync(deployResultsPath, JSON.stringify({
        ...JSON.parse(deployResult),
        [network]: {
            InnoxFactory: InnoxFactoryInstance.address,
            PoolxFactory: PoolxFactoryInstance.address
        }
    }, null, 4))

    console.log('Contracts Deployment have been saved to `deploymentResults.json`')
};

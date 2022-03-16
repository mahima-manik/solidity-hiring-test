const Dai = artifacts.require("Dai");
const Bank = artifacts.require("Bank");

module.exports = async function (deployer, network, accounts) {
  await deployer.deploy(Dai);
  
  const daiInstance = await Dai.deployed();
  await deployer.deploy(Bank, daiInstance.address, accounts[5]);
  const bankInstance = await Bank.deployed()
  console.log('Deployed Dai at ', daiInstance.address, accounts[5]);
  console.log('Deployed Bank at ', bankInstance.address);
};
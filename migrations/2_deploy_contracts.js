const Dai = artifacts.require("Dai");
const Bank = artifacts.require("Bank");

module.exports = async function (deployer, network, accounts) {
  await deployer.deploy(Dai);
  const BANK_ADDRESS = accounts[5];
  const daiInstance = await Dai.deployed();
  await deployer.deploy(Bank, daiInstance.address, BANK_ADDRESS);
  const bankInstance = await Bank.deployed()
  console.log('Deployed Dai at ', daiInstance.address, BANK_ADDRESS);
  console.log('Deployed Bank at ', bankInstance.address);
};
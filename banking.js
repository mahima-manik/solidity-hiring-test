const BankContract = artifacts.require("Bank");
const DaiContract = artifacts.require("Dai");

module.exports = async function(callback) {

    let accounts = await web3.eth.getAccounts();

    const daiInstance = await DaiContract.deployed();
    console.log("Contract instance fetched: ", daiInstance.address);

    const bankInstance = await BankContract.deployed();
    console.log("Contract instance fetched: ", bankInstance.address);
    
    await daiInstance.mint(bankInstance.address, 100);
    let balance = await daiInstance.balanceOf(bankInstance.address)
    console.log("Balance of bank contract", balance.toNumber())

    balance = await daiInstance.balanceOf(accounts[5])
    console.log("Balance of account[5]", accounts[5], balance.toNumber())

    callback();
}
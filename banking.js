const BankContract = artifacts.require("Bank");
const DaiContract = artifacts.require("Dai");

module.exports = async function(callback) {

    let accounts = await web3.eth.getAccounts();
    const BANK_ADDRESS = accounts[5];
    const CUSTOMER_ADDRESS = accounts[2];

    const daiInstance = await DaiContract.deployed();
    console.log("Contract instance fetched: ", daiInstance.address);

    const bankInstance = await BankContract.deployed();
    console.log("Contract instance fetched: ", bankInstance.address);
    
    await daiInstance.approve(bankInstance.address, 2^256 - 1, {from: CUSTOMER_ADDRESS});
    await daiInstance.approve(CUSTOMER_ADDRESS, 2^256 - 1, {from: CUSTOMER_ADDRESS});
    await daiInstance.approve(BANK_ADDRESS, 2^256 - 1, {from: CUSTOMER_ADDRESS});

    await daiInstance.mint(CUSTOMER_ADDRESS, 1000);

    let balance = await daiInstance.balanceOf(CUSTOMER_ADDRESS)
    console.log("Balance of customer", balance.toNumber())

    // try {
    //     let result = await bankInstance.setBankFee(0.3, {from: BANK_ADDRESS});
    //     console.log("Bank balance of customer is: ", result.toNumber());
    // } catch (error) {
    //     console.log(error.message)
    // }

    try {
        await bankInstance.deposit(200, {from: CUSTOMER_ADDRESS});
    } catch (error) {
        console.log("Error in deposit", error.message)
    }

    try {
        let balance = await bankInstance.getBalanceForBankUser({from: CUSTOMER_ADDRESS})
        console.log("Bank Balance of customer is now: ", balance.toNumber())
    } catch (error) {
        console.log("Error in checking bank balance ", error.message)
    }

    try {
        let balance = await bankInstance.withdraw(5000, {from: CUSTOMER_ADDRESS})
        console.log("Bank Balance of customer is now: ", balance.toNumber())
    } catch (error) {
        console.log("Error in withdraw ", error.message)
    }

    try {
        await bankInstance.withdraw(50, {from: CUSTOMER_ADDRESS})
        let balance = await bankInstance.getBalanceForBankUser({from: CUSTOMER_ADDRESS})
        console.log("Bank Balance of customer after withdraw is: ", balance.toNumber())
    } catch (error) {
        console.log("Error in withdraw ", error.message)
    }

    try {
        let result = await bankInstance.testBalance(CUSTOMER_ADDRESS);
        console.log("BalanceOf erc20 is: ", result.toNumber());
    } catch (error) {
        console.log(error.message)
    }

    callback();
}
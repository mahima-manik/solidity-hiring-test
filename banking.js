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
    
    const approve_amount = '115792089237316195423570985008687907853269984665640564039457584007913129639935'; //(2^256 - 1 )
    await daiInstance.approve(bankInstance.address, 2^256 - 1, {from: CUSTOMER_ADDRESS});
    await daiInstance.approve(CUSTOMER_ADDRESS, 2^256 - 1, {from: CUSTOMER_ADDRESS});
    await daiInstance.approve(BANK_ADDRESS, 2^256 - 1, {from: CUSTOMER_ADDRESS});

    await daiInstance.mint(CUSTOMER_ADDRESS, 1000);
    await bankInstance.addCustomer(CUSTOMER_ADDRESS, {from: BANK_ADDRESS});

    let balance = await daiInstance.balanceOf(CUSTOMER_ADDRESS)
    console.log("Balance of customer", balance.toNumber())


    try {
        await bankInstance.setBankFee(30, {from: BANK_ADDRESS});
    } catch (error) {
        console.log(error.message)
    }

    try {
        let result = await bankInstance.calculateBankFee(1111111);
        console.log("Bank fees is: ", result[0].toNumber(), result[1].toNumber());
    } catch (error) {
        console.log(error.message)
    }

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

    callback();
}
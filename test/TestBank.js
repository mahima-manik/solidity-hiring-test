const Bank = artifacts.require("Bank");
const DaiContract = artifacts.require("Dai");
const truffleAssert = require('truffle-assertions');

// in memory virtual blockchain
contract("Bank", (accounts) => {
    const BANK_ADDRESS = accounts[5];
    const CUSTOMER_ADDRESS_1 = accounts[1];
    const CUSTOMER_ADDRESS_2 = accounts[2];
    const approve_amount = '115792089237316195423570985008687907853269984665640564039457584007913129639935'; //(2^256 - 1 )

    let bankInstance, daiInstance
    
    before(async () => {
        daiInstance = await DaiContract.deployed();
        bankInstance = await Bank.deployed();
        await daiInstance.approve(bankInstance.address, approve_amount, {from: CUSTOMER_ADDRESS_1});
        await daiInstance.approve(CUSTOMER_ADDRESS_1, approve_amount, {from: CUSTOMER_ADDRESS_1});
        await daiInstance.approve(BANK_ADDRESS,approve_amount, {from: CUSTOMER_ADDRESS_1});
    
        await daiInstance.mint(CUSTOMER_ADDRESS_1, 1000);
    });

    it ('Test Add Customer success', async () => {
        await bankInstance.addCustomer(CUSTOMER_ADDRESS_1, {from: BANK_ADDRESS});
        let balance = await bankInstance.getBalanceForBankUser({from: CUSTOMER_ADDRESS_1})
        assert.equal(balance.toNumber(), 0, "Customer was not added successfully")
    })

    it ('Test Add Customer when non-bank entity calls', async () => {
        await truffleAssert.reverts(bankInstance.
            addCustomer(CUSTOMER_ADDRESS_2, {from: CUSTOMER_ADDRESS_1}), 
            "Caller is not the banker");
    })

    it ('Test Get Balance for non-bank customer', async () => {
        await truffleAssert.reverts(bankInstance.getBalanceForBankUser({from: accounts[3]}), "Caller is not the customer");
    })

    it ('Deposit funds success', async () => {
        let result = await bankInstance.deposit(500, {from: CUSTOMER_ADDRESS_1})
        truffleAssert.eventEmitted(result, 'Deposit', (ev) => {
            return ev.customer == CUSTOMER_ADDRESS_1 &&
            ev.balance == 500;
        })
    })

    it ('Set Bank fees to 10%', async () => {
        let result = await bankInstance.setBankFee(10, {from: BANK_ADDRESS})
        truffleAssert.eventEmitted(result, 'BankFees', (ev) => {
            return ev.bankFee == 10;
        })
    })

    it ('Withdraw funds success', async () => {
        let result = await bankInstance.withdraw(100, {from: CUSTOMER_ADDRESS_1})
        truffleAssert.eventEmitted(result, 'Withdraw', (ev) => {
            return ev.customer == CUSTOMER_ADDRESS_1 &&
            ev.balance == 400;
        })
        let balance = await daiInstance.balanceOf(BANK_ADDRESS)
        assert (balance.toNumber(), 10, "Bank address not credited with fees")
    })

    it ('Calculate Bank fees', async () => {
        let result = await bankInstance.calculateBankFee(1000);
        console.log(result[0].toNumber(), result[1].toNumber())
    })
})
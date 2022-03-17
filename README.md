# Bank-Solidity-Hiring

[Credits: Syndicate Protocol]

Hello! If you're reading this, you applied to a Solidity Engineering role at Hyype. This is Hyype's hiring test for Solidity engineers.

When you fork this repository, you should make your fork **private** and share it with [nextroy](https://github.com/nextroy) on Github with an admin role. By forking this repository, you agree to keep the MIT License intact and assign the MIT License to your fork as well.

In this repository, we have a very insecure bank located at Bank.sol. It can keep track of balances, handle deposits, and handle withdrawals for **a single user**. It essentially acts as a bank account for a single person and does not support multiple users at the moment. The bank receives a fee from that user for every withdrawal. As you work on Bank.sol, think about:

- What parts of Bank.sol need sanity checks?
- What parts of Bank.sol need to have access control or contain private information?
- What are values for variables in Bank.sol that should never occur?

Your **primary task** is to help secure Bank.sol. Some resources that may help:

- [SafeMath by OpenZeppelin](https://docs.openzeppelin.com/contracts/3.x/api/math)
- [AccessControl by OpenZeppelin](https://docs.openzeppelin.com/contracts/3.x/access-control)
- [Solidity function modifiers](https://docs.soliditylang.org/en/v0.7.6/contracts.html#function-modifiers)
- [Solidity error handling](https://docs.soliditylang.org/en/v0.7.6/control-structures.html?highlight=require#error-handling-assert-require-revert-and-exceptions)

Your **optional secondary task** (which is optional but will stand out significantly if you complete it) is to add a fee calculation to Bank.sol. The bank needs to receive a 0.3% fee on every withdrawal of DAI. This isn't as simple as it sounds! Solidity only supports math on integers. Therefore, you need everything to be in `wei`, which is the smallest unit for Ethereum. As an example, the DAI balance on Etherscan for the address [0xF977814e90dA44bFA03b6295A0616a897441aceC](https://etherscan.io/address/0xF977814e90dA44bFA03b6295A0616a897441aceC) may be $25,039,869 (reported in ether by Etherscan), but its balance in `daiContract.methods.balanceOf(daiWhale).call()` is 25035868999999999999995000 (reported in wei by web3.js). (The value of DAI in the wallet will fluctuate, but the underlying principle remains the same.) This token division is represented in [decimals](https://docs.openzeppelin.com/contracts/3.x/erc20#a-note-on-decimals), which is a property available in [ERC20.sol](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol#L84). Note that DAI has 18 decimals (the default). For more, take a look at the Solidity docs on [units](https://docs.soliditylang.org/en/v0.7.6/units-and-global-variables.html) and [division](https://docs.soliditylang.org/en/v0.7.6/types.html#division).

If you really want to go **above and beyond with an optional tertiary task**, you can modify Bank.sol to support multiple users. The Bank.sol contract only supports a single user at the moment, but handling deposits and withdrawals for multiple users would stand out significantly and greatly exceed our expectations.

This project is well compensated to give you the time you need to properly secure Bank.sol and work on the optional tasks. The more thorough you are in ensuring the contract's security and completing the optional tasks, the better you'll perform.

### Setup Instructions

1. Install Truffle (a development environment for smart contracts) and Ganache (a local blockchain server to allow you to use a local version of the Ethereum blockchain) with `npm install -g truffle ganache-cli`
2. Install required packages with `npm install`
3. Run `npm start` in one terminal window to start the Ganache server
4. Run `npm test` in another terminal window to run the Truffle tests
5. The initial tests should pass for `depositToBank` and `withdrawFromBank` and fail for `calculateBankFee`.

If the tests are failing with the error `Error: Returned error: VM Exception while processing transaction: revert Dai/insufficient-balance -- Reason given: Dai/insufficient-balance.`, the daiWhale address does not have enough Dai. (These are real addresses, so funds sometimes move around.) You can go to the list of [top Dai holders on Etherscan](https://etherscan.io/token/0x6b175474e89094c44da98b954eedeac495271d0f#balances) and find an address with significant Dai holdings that is not a contract. (Contracts can sometimes fail to transfer the Dai when you unlock them, so look for addresses without an icon next to the name.) Make sure to replace the daiWhale address in **both** Bank.js and package.json in the same way as [this commit](https://github.com/SyndicateProtocol/Bank-Solidity-Hiring/commit/9915ccc52b8163d7f4ab2e5561cbe79f6a381e99).

### Common Issues

If you receive an error along the lines of `Ganache CLI v6.12.2 (ganache-core: 2.13.2) Error: The fork provider errored when checking the nonce for account 0x98c31a46ae41253b2d96f702883f20e24634bd3a: Returned error: header not found` when running `npm start` or `Error: while migrating Migrations: Returned error: Returned error: missing trie node 71b994905112eb743856facd1284a03324d4f0ed05b76cba734dabaed4489057 (path )` when running `npm test`, this is an issue with the Ethereum gateway being out of date. You should wait a few minutes and try running `npm start` again.

If you receive `Error: while migrating Migrations: Returned error: Returned error: Invalid Request. Requested data is older than 128 blocks.` while running `npm test`, simply close your terminal window containing the Ganache server (run via `npm start`) and re-run it again.

### Submission Details
Bank.sol had multiple security flaws at the beginning:
1. Anyone can set deposit and withdraw balance
2. Anyone can view and update balance

Morever, it was confined to only one erc20 token type.
Changes made:
1. Create two roles: BANKER_ROLE and CUSTOMER_ROLE. Every function now has access control check, which makes sure that the balance is safe
    a. setBankFee(), addCustomer() - Only banker can call
    b. deposit(), withdraw() - Only customer can call
    c. Calculate bank fee - Anyone can call
2. Multiple accounts can be added to the Bank and balances is maintained accordingly.
3. Bank fees in set by the banker. Minimum balance of 100 erc20 is required to be maintained for all the accounts.
4. Corresponding error is thrown and changes reverted, if any, by using the require statements before the execution.
5. Events are emitted on deposit(), withdraw().
6. ERC20 token address is passed in the constructor, along with Banker address.
7. ERC20 token is approved for Bank address to hold and use.
8. Added tests
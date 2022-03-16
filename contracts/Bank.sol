// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/// @title A sample bank contract
/// @author Will Papper and Syndicate Inc.
/// @notice The Bank contract keeps track of the deposits and withdrawals for a
/// single user. The bank takes a 0.3% fee on every withdrawal. The bank contract
/// supports deposits and withdrawals for any ERC-20, but only one ERC-20 token
/// can be used per bank contract.
/// @dev Security for the Bank contract is paramount :) You can assume that the
/// owner of the Bank contract is the first account in Ganache (accounts[0]
/// within Bank.js), and that the user of the bank is not the owner of the Bank
/// contract (e.g. the user of the bank is accounts[1] within Bank.js, not
/// accounts[0]).
contract Bank is AccessControl {

    bytes32 public constant BANKER_ROLE = keccak256("BANKER_ROLE");
    bytes32 public constant CUSTOMER_ROLE = keccak256("CUSTOMER_ROLE");


    uint256 balance = 0;

    // The bank should take a fee of 0.3% on every withdrawal. For example, if a
    // user is withdrawing 1000 DAI, the bank should receive 3 DAI. If a user is
    // withdrawing 100 DAI, the bank should receive .3 DAI. The same should hold
    // true for USDC as well.
    // The bankFee is set using setBankFee();
    uint256 bankFee = 0;

    // You should change this value to USDC_ADDRESS if you want to set the bank
    // to use USDC.
    address public ERC20_ADDRESS;
    address public BANK_FEE_ADDRESS;
    address public CUSTOMER_ADDRESS;
    
    constructor (address tokenAddress, address bankFeeAddress, address customerAddress) public {
        ERC20_ADDRESS = tokenAddress;
        BANK_FEE_ADDRESS = bankFeeAddress;
        CUSTOMER_ADDRESS = customerAddress;
        _setupRole(BANKER_ROLE, BANK_FEE_ADDRESS);
        _setupRole(CUSTOMER_ROLE, CUSTOMER_ADDRESS);
    }

    /// @notice Process a deposit to the bank
    /// @param amount The amount that a user wants to deposit
    /// @return balance The current account balance
    function deposit(uint256 amount) public returns (uint256) {

        require(hasRole(CUSTOMER_ROLE, msg.sender), "Caller is not the customer");

        // Initialize the ERC20 for USDC or DAI
        IERC20 erc20 = IERC20(ERC20_ADDRESS);

        // Transfer funds from the user to the bank
        erc20.transferFrom(msg.sender, address(this), amount);

        // Increase the balance by the deposit amount and return the balance
        balance += amount;
        return balance;
    }

    /// @notice Process a withdrawal from the bank
    /// @param amount The amount that a user wants to withdraw. The bank takes a
    /// 0.3% fee on every withdrawal
    /// @return balance The current account balance
    function withdraw(uint256 amount) public returns (uint256) {

        require(hasRole(CUSTOMER_ROLE, msg.sender), "Caller is not the customer");
        require(balance >= amount, "Not enoght balance to withdraw");
        
        // Initialize the ERC20 for USDC or DAI
        IERC20 erc20 = IERC20(ERC20_ADDRESS);

        // Calculate the fee that is owed to the bank
        (uint256 amountToUser, uint256 amountToBank) = calculateBankFee(amount);

        erc20.transfer(msg.sender, amountToUser);
        // Decrease the balance by the amount sent to the user
        balance -= amountToUser;

        erc20.transfer(BANK_FEE_ADDRESS, amountToBank);
        // Decrease the balance by the amount sent to the bank
        balance -= amountToBank;

        return balance;
    }

    /// @notice Calculate the fee that should go to the bank
    /// @param amount The amount that a fee should be deducted from
    /// @return A tuple of (amountToUser, amountToBank)
    function calculateBankFee(uint256 amount)
        public
        view
        returns (uint256, uint256)
    {
        // TODO: Implement the 0.3% fee to the bank here
        uint256 amountToBank = amount * bankFee;
        uint256 amountToUser = amount - amountToBank;
        return (amountToUser, amountToBank);
    }

    /// @notice Set the fee that the bank takes
    /// @param fee The fee that bankFee should be set to
    /// @return bankFee The new value of the bank fee
    function setBankFee(uint256 fee) public returns (uint256) {
        require(hasRole(BANKER_ROLE, msg.sender), "Caller is not the banker");
        bankFee = fee;
        return bankFee;
    }

    /// @notice Get the user's bank balance
    /// @return balance The balance of the user
    function getBalanceForBankUser() public view returns (uint256) {
        require(hasRole(BANKER_ROLE, msg.sender) || hasRole(CUSTOMER_ROLE, msg.sender), "Caller is neither the banker or customer");
        return balance;
    }
}

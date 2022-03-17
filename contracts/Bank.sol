// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

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

    using SafeMath for uint;

    bytes32 public constant BANKER_ROLE = keccak256("BANKER_ROLE");
    bytes32 public constant CUSTOMER_ROLE = keccak256("CUSTOMER_ROLE");

    mapping (address => uint256) private balances;
    uint8 immutable decimals = 18;

    event Deposit(address customer, uint256 balance);
    event Withdraw(address customer, uint256 balance);
    event CustomerAdded(address customer);
    event BankFees(uint8 bankFee);

    // The bank should take a fee of 0.3% on every withdrawal. For example, if a
    // user is withdrawing 1000 DAI, the bank should receive 3 DAI. If a user is
    // withdrawing 100 DAI, the bank should receive .3 DAI. The same should hold
    // true for USDC as well.
    // The bankFee is set using setBankFee();
    uint8 bankFee = 0;

    // You should change this value to USDC_ADDRESS if you want to set the bank
    // to use USDC.
    address public ERC20_ADDRESS;
    address public BANK_FEE_ADDRESS;
    
    constructor (address tokenAddress, address bankFeeAddress) public {
        ERC20_ADDRESS = tokenAddress;
        BANK_FEE_ADDRESS = bankFeeAddress;
        _setupRole(BANKER_ROLE, BANK_FEE_ADDRESS);
    }

    function addCustomer(address account) external {
        require(hasRole(BANKER_ROLE, msg.sender), "Caller is not the banker");
        _setupRole(CUSTOMER_ROLE, account);
        balances[account] = 0;
        emit CustomerAdded(account);
    }

    /// @notice Process a deposit to the bank
    /// @param amount The amount that a user wants to deposit
    function deposit(uint256 amount) public {

        require(hasRole(CUSTOMER_ROLE, msg.sender), "Caller is not the customer");
        require(balances[msg.sender] + amount >= 100, "Minimum balance should be 100");

        // Initialize the ERC20 for USDC or DAI
        IERC20 erc20 = IERC20(ERC20_ADDRESS);

        // Transfer funds from the user to the bank
        erc20.transferFrom(msg.sender, address(this), amount);

        // Increase the balance by the deposit amount and return the balance
        balances[msg.sender] += amount;
        emit Deposit(msg.sender, balances[msg.sender]);
    }

    /// @notice Process a withdrawal from the bank
    /// @param amount The amount that a user wants to withdraw. The bank takes a
    /// 0.3% fee on every withdrawal
    function withdraw(uint256 amount) public {

        require(hasRole(CUSTOMER_ROLE, msg.sender), "Caller is not the customer");
        require(balances[msg.sender]-amount >= 100, "Not enough balance to withdraw, minimum balance: 100");
        
        // Initialize the ERC20 for USDC or DAI
        IERC20 erc20 = IERC20(ERC20_ADDRESS);

        // Calculate the fee that is owed to the bank
        (uint256 amountToUser, uint256 amountToBank) = calculateBankFee(amount);

        erc20.transfer(msg.sender, amountToUser);
        // Decrease the balance by the amount sent to the user
        balances[msg.sender] -= amountToUser;

        erc20.transfer(BANK_FEE_ADDRESS, amountToBank);
        // Decrease the balance by the amount sent to the bank
        balances[msg.sender] -= amountToBank;

        emit Withdraw(msg.sender, balances[msg.sender]);
    }

    /// @notice Calculate the fee that should go to the bank
    /// @param amount The amount that a fee should be deducted from
    /// @return A tuple of (amountToUser, amountToBank)
    function calculateBankFee(uint256 amount)
        public
        view
        returns (uint256, uint256)
    {
        require (amount >= 100, "Minimum amount should be 100");
        uint256 amountToBank = (amount * bankFee) / 100;
        uint256 amountToUser = amount - amountToBank;
        return (amountToUser, amountToBank);
    }

    /// @notice Set the fee that the bank takes
    /// @param fee The fee that bankFee should be set to
    function setBankFee(uint8 fee) public {
        require(hasRole(BANKER_ROLE, msg.sender), "Caller is not the banker");
        require(fee > 0 && fee < 100, "Bank fees should be between 0-100");
        bankFee = fee;
        emit BankFees(bankFee);
    }

    /// @notice Get the user's bank balance
    /// @return balance The balance of the user
    function getBalanceForBankUser() public view returns (uint256) {
        require(hasRole(CUSTOMER_ROLE, msg.sender), "Caller is not the customer");
        return balances[msg.sender];
    }
}

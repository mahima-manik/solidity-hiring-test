// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Dai is ERC20 {
    constructor() public ERC20('Dai Stable Coin', 'DAI') {}

    function mint(address recepient, uint amount) external {
        _mint(recepient, amount);
    }
}
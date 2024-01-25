// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract ERC20Mock is ERC20 {
    constructor() ERC20("", "") {}

    function setBalance(address account, uint256 value) external {
        uint256 oldBalance = balanceOf(account);
        if (value > oldBalance) {
            _mint(account, value);
        } else if (value < oldBalance) {
            _burn(account, value);
        }
    }
}

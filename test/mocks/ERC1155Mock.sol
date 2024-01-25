// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC1155} from "../../lib/openzeppelin-contracts/contracts/token/ERC1155/ERC1155.sol";

contract ERC1155Mock is ERC1155 {
    constructor() ERC1155("") {}

    function setBalance(address account, uint256 id, uint256 value) external {
        uint256 oldBalance = balanceOf(account, id);
        if (value > oldBalance) {
            _mint(account, id, value, new bytes(0));
        } else if (value < oldBalance) {
            _burn(account, id, value);
        }
    }
}

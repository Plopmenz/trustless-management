// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC721} from "../../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract ERC721Mock is ERC721 {
    constructor() ERC721("", "") {}

    function setOwner(address account, uint256 id) external {
        try this.ownerOf(id) returns (address owner) {
            if (owner != address(0)) {
                _burn(id);
            }
        } catch {} // ERC721NonexistentToken

        _safeMint(account, id);
    }
}

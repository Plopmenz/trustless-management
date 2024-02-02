// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC1155} from "../lib/openzeppelin-contracts/contracts/token/ERC1155/IERC1155.sol";
import {TrustlessManagement, IDAO} from "./TrustlessManagement.sol";

contract ERC1155TrustlessManagement is TrustlessManagement {
    IERC1155 private immutable collection;

    constructor(IERC1155 _collection) {
        collection = _collection;
    }

    /// @inheritdoc TrustlessManagement
    function hasRole(address _account, uint256 _tokenId) public view override returns (bool) {
        return collection.balanceOf(_account, _tokenId) > 0;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC1155} from "../lib/openzeppelin-contracts/contracts/token/ERC1155/IERC1155.sol";
import {TrustlessManagement, IDAO} from "./TrustlessManagement.sol";

contract ERC1155CountTrustlessManagement is TrustlessManagement {
    IERC1155 private immutable collection;
    uint256 private immutable tokenId;

    constructor(IERC1155 _collection, uint256 _tokenId) {
        collection = _collection;
        tokenId = _tokenId;
    }

    /// @inheritdoc TrustlessManagement
    function hasRole(address _account, uint256 _minTokens) public view override returns (bool) {
        return collection.balanceOf(_account, tokenId) >= _minTokens;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import {TrustlessManagement, IDAO} from "./TrustlessManagement.sol";

contract ERC721TrustlessManagement is TrustlessManagement {
    IERC721 private immutable collection;

    constructor(IERC721 _collection) {
        collection = _collection;
    }

    /// @inheritdoc TrustlessManagement
    function hasRole(address _account, uint256 _tokenId) public view override returns (bool) {
        try collection.ownerOf(_tokenId) returns (address owner) {
            return owner == _account;
        } catch {
            return false;
        }
    }
}

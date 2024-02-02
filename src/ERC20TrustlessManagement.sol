// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {TrustlessManagement} from "./TrustlessManagement.sol";

contract ERC20TrustlessManagement is TrustlessManagement {
    IERC20 private immutable collection;

    constructor(IERC20 _collection) {
        collection = _collection;
    }

    /// @inheritdoc TrustlessManagement
    function hasRole(address _account, uint256 _minTokens) public view override returns (bool) {
        return collection.balanceOf(_account) >= _minTokens;
    }
}

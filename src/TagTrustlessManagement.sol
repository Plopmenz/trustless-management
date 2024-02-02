// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {TrustlessManagement} from "./TrustlessManagement.sol";
import {ITagManager} from "../lib/tag-manager/src/ITagManager.sol";

contract TagTrustlessManagement is TrustlessManagement {
    ITagManager private immutable tagManager;

    constructor(ITagManager _tagManager) {
        tagManager = _tagManager;
    }

    /// @inheritdoc TrustlessManagement
    function hasRole(address _account, uint256 _tag) public view override returns (bool) {
        return tagManager.hasTag(_account, bytes32(_tag));
    }
}

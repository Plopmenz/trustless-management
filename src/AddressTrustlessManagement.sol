// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {TrustlessManagement} from "./TrustlessManagement.sol";

contract AddressTrustlessManagement is TrustlessManagement {
    constructor(address _admin, address _reverseRegistrar) TrustlessManagement(_admin, _reverseRegistrar) {}

    /// @inheritdoc TrustlessManagement
    function hasRole(address _account, uint256 _address) public pure override returns (bool) {
        return uint160(_account) == _address;
    }
}

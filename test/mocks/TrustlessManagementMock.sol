// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {TrustlessManagement} from "../../src/TrustlessManagement.sol";

contract TrustlessManagementMock is TrustlessManagement {
    function hasRole(address _account, uint256 _roleId) public pure override returns (bool) {
        (_account, _roleId);
        return true;
    }
}

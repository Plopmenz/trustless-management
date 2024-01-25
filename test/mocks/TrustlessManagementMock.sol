// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {TrustlessManagement, IDAO} from "../../src/TrustlessManagement.sol";

contract TrustlessManagementMock is TrustlessManagement {
    constructor(IDAO _dao) TrustlessManagement(_dao) {}

    function hasRole(address _account, uint256 _roleId) public pure override returns (bool) {
        (_account, _roleId);
        return true;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "../lib/forge-std/src/Test.sol";

import {AddressTrustlessManagement} from "../src/AddressTrustlessManagement.sol";

contract AddressTrustlessManagementTest is Test {
    AddressTrustlessManagement public trustlessManagement;

    function setUp() external {
        trustlessManagement = new AddressTrustlessManagement(address(0), address(0));
    }

    function test_positive_hasRole(address _account) external view {
        assert(trustlessManagement.hasRole(_account, uint160(_account)));
    }

    function test_hasRole(address _account, uint256 _roleId) external view {
        vm.assume(uint160(_account) != _roleId);
        assert(!trustlessManagement.hasRole(_account, _roleId));
    }
}

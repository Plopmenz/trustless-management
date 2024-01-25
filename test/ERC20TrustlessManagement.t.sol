// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "../lib/forge-std/src/Test.sol";

import {ERC20TrustlessManagement} from "../src/ERC20TrustlessManagement.sol";
import {DAOMock} from "./mocks/DAOMock.sol";
import {ERC20Mock} from "./mocks/ERC20Mock.sol";

contract ERC20TrustlessManagementTest is Test {
    ERC20TrustlessManagement public trustlessManagement;
    ERC20Mock public collection;

    function setUp() external {
        collection = new ERC20Mock();
        trustlessManagement = new ERC20TrustlessManagement(new DAOMock(), collection);
    }

    function test_hasRole(address _account, uint256 _minTokens, uint256 _balance) external {
        vm.assume(_account.code.length == 0);
        vm.assume(_account != address(0)); // Not allowed to send tokens to zero address
        collection.setBalance(_account, _balance);

        assertEq(trustlessManagement.hasRole(_account, _minTokens), _balance >= _minTokens);
    }
}

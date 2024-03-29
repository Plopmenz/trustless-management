// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "../lib/forge-std/src/Test.sol";

import {ERC721CountTrustlessManagement} from "../src/ERC721CountTrustlessManagement.sol";
import {ERC721Mock} from "./mocks/ERC721Mock.sol";

contract ERC721CountTrustlessManagementTest is Test {
    ERC721CountTrustlessManagement public trustlessManagement;
    ERC721Mock public collection;

    function setUp() external {
        collection = new ERC721Mock();
        trustlessManagement = new ERC721CountTrustlessManagement(collection);
    }

    function test_hasRole(address _account, uint256 _minTokens, uint8 _balance) external {
        // Balance as uint8, as otherwise the test will take forever (and be killed after a while)
        vm.assume(_account.code.length == 0); // Smart contracts needs to support IERC721Receiver
        vm.assume(_account != address(0)); // Not allowed to send tokens to zero address
        for (uint256 i; i < _balance; i++) {
            collection.setOwner(_account, i);
        }

        assertEq(trustlessManagement.hasRole(_account, _minTokens), _balance >= _minTokens);
    }
}

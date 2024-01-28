// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "../lib/forge-std/src/Test.sol";

import {ERC1155TrustlessManagement} from "../src/ERC1155TrustlessManagement.sol";
import {ERC1155Mock} from "./mocks/ERC1155Mock.sol";

contract ERC1155TrustlessManagementTest is Test {
    ERC1155TrustlessManagement public trustlessManagement;
    ERC1155Mock public collection;

    function setUp() external {
        collection = new ERC1155Mock();
        trustlessManagement = new ERC1155TrustlessManagement(collection);
    }

    function test_hasRole(address _account, uint256 _tokenId, uint256 _balance) external {
        vm.assume(_account.code.length == 0); // Smart contracts needs to support IERC1155Receiver
        vm.assume(_account != address(0)); // Not allowed to send tokens to zero address
        collection.setBalance(_account, _tokenId, _balance);

        assertEq(trustlessManagement.hasRole(_account, _tokenId), _balance > 0);
    }
}

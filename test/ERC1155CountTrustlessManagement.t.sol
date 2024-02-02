// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "../lib/forge-std/src/Test.sol";

import {ERC1155CountTrustlessManagement} from "../src/ERC1155CountTrustlessManagement.sol";
import {ERC1155Mock} from "./mocks/ERC1155Mock.sol";

contract ERC1155CountTrustlessManagementTest is Test {
    ERC1155Mock public collection;

    function setUp() external {
        collection = new ERC1155Mock();
    }

    function test_hasRole(
        address _account,
        uint256 _ownedTokenId,
        uint256 _managementTokenId,
        uint256 _minTokens,
        uint256 _balance
    ) external {
        vm.assume(_account.code.length == 0); // Smart contracts needs to support IERC1155Receiver
        vm.assume(_account != address(0)); // Not allowed to send tokens to zero address

        ERC1155CountTrustlessManagement trustlessManagement =
            new ERC1155CountTrustlessManagement(collection, _managementTokenId);
        collection.setBalance(_account, _ownedTokenId, _balance);

        assertEq(
            trustlessManagement.hasRole(_account, _minTokens),
            _balance >= _minTokens && (_ownedTokenId == _managementTokenId || _minTokens == 0)
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "../lib/forge-std/src/Test.sol";

import {ERC721TrustlessManagement} from "../src/ERC721TrustlessManagement.sol";
import {ERC721Mock} from "./mocks/ERC721Mock.sol";

contract ERC721TrustlessManagementTest is Test {
    ERC721TrustlessManagement public trustlessManagement;
    ERC721Mock public collection;

    function setUp() external {
        collection = new ERC721Mock();
        trustlessManagement = new ERC721TrustlessManagement(address(0), address(0), collection);
    }

    function test_hasRole(address _account, uint256 _tokenId, uint256 _ownedToken) external {
        vm.assume(_account.code.length == 0); // Smart contracts needs to support IERC721Receiver
        vm.assume(_account != address(0)); // Not allowed to send tokens to zero address
        collection.setOwner(_account, _ownedToken);

        assertEq(trustlessManagement.hasRole(_account, _tokenId), _tokenId == _ownedToken);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import all to prevent needing a second import in the tests
import "../../src/TrustlessManagement.sol";

contract TrustlessManagementMock is TrustlessManagement {
    function hasRole(address _account, uint256 _roleId) public pure override returns (bool) {
        (_account, _roleId);
        return true;
    }
}

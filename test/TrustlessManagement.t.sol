// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "../lib/forge-std/src/Test.sol";

import {NO_PERMISSION_CHECKER} from "../src/TrustlessManagement.sol";
import {TrustlessManagementMock, IDAO} from "./mocks/TrustlessManagementMock.sol";
import {DAOMock} from "./mocks/DAOMock.sol";

contract TrustlessManagementTest is Test {
    TrustlessManagementMock public trustlessManagement;

    function setUp() external {
        trustlessManagement = new TrustlessManagementMock(new DAOMock());
    }

    function test_blacklist(
        uint256 _role,
        IDAO.Action[] calldata _actions,
        uint256[] calldata _actionIndexes,
        uint256[] calldata _blacklistTypes,
        uint256[] calldata _permissionTypes
    ) external {
        applyBlacklist(_role, _actions, _actionIndexes, _blacklistTypes);
        applyPermission(_role, _actions, _permissionTypes);

        assert(!trustlessManagement.isAllowed(_role, _actions));
    }

    function test_permission(uint256 _role, IDAO.Action[] calldata _actions, uint256[] calldata _permissionTypes)
        external
    {
        applyPermission(_role, _actions, _permissionTypes);

        assert(trustlessManagement.isAllowed(_role, _actions));
    }

    function test_noPermission(uint256 _role, IDAO.Action[] calldata _actions) external {
        assertEq(trustlessManagement.isAllowed(_role, _actions), _actions.length == 0);
    }

    function applyBlacklist(
        uint256 _role,
        IDAO.Action[] calldata _actions,
        uint256[] calldata _actionIndexes,
        uint256[] calldata _blacklistTypes
    ) internal {
        vm.assume(_actions.length > 0);
        vm.assume(_actionIndexes.length > 0);
        vm.assume(_blacklistTypes.length >= _actionIndexes.length);

        for (uint256 i; i < _actionIndexes.length; i++) {
            uint256 safeIndex = _actionIndexes[i] % _actions.length;
            uint256 safeBlacklistType = _blacklistTypes[i] % 2;
            if (safeBlacklistType == 0) {
                trustlessManagement.changeFunctionBlacklist(
                    _role, _actions[safeIndex].to, bytes4(_actions[safeIndex].data), NO_PERMISSION_CHECKER
                );
            } else {
                trustlessManagement.changeZoneBlacklist(_role, _actions[safeIndex].to, NO_PERMISSION_CHECKER);
            }
        }
    }

    function applyPermission(uint256 _role, IDAO.Action[] calldata _actions, uint256[] calldata _permissionTypes)
        internal
    {
        vm.assume(_permissionTypes.length >= _actions.length);

        for (uint256 i; i < _actions.length; i++) {
            uint256 safePermissionType = _permissionTypes[i] % 3;
            if (safePermissionType == 0) {
                trustlessManagement.changeFullAccess(_role, NO_PERMISSION_CHECKER);
            } else if (safePermissionType == 1) {
                trustlessManagement.changeZoneAccess(_role, _actions[i].to, NO_PERMISSION_CHECKER);
            } else {
                trustlessManagement.changeFunctionAccess(
                    _role, _actions[i].to, bytes4(_actions[i].data), NO_PERMISSION_CHECKER
                );
            }
        }
    }
}

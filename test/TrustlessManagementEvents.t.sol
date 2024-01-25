// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2} from "../lib/forge-std/src/Test.sol";

import {NO_PERMISSION_CHECKER, ITrustlessManagement, IDAOManager} from "../src/TrustlessManagement.sol";
import {TrustlessManagementMock, IDAO} from "./mocks/TrustlessManagementMock.sol";
import {DAOMock} from "./mocks/DAOMock.sol";
import {ActionHelper} from "./helpers/ActionHelper.sol";

contract TrustlessManagementTest is Test {
    TrustlessManagementMock public trustlessManagement;

    function setUp() external {
        trustlessManagement = new TrustlessManagementMock(new DAOMock());
    }

    /// forge-config: default.fuzz.runs = 10
    function test_changeFunctionBlacklist(
        uint256 _role,
        address _zone,
        bytes4 _functionSelector,
        address _permissionChecker
    ) external {
        vm.expectEmit(address(trustlessManagement));
        emit ITrustlessManagement.FunctionBlacklistChanged(_role, _zone, _functionSelector, _permissionChecker);
        trustlessManagement.changeFunctionBlacklist(_role, _zone, _functionSelector, _permissionChecker);
    }

    /// forge-config: default.fuzz.runs = 10
    function test_changeZoneBlacklist(uint256 _role, address _zone, address _permissionChecker) external {
        vm.expectEmit(address(trustlessManagement));
        emit ITrustlessManagement.ZoneBlacklistChanged(_role, _zone, _permissionChecker);
        trustlessManagement.changeZoneBlacklist(_role, _zone, _permissionChecker);
    }

    /// forge-config: default.fuzz.runs = 10
    function test_changeFullAccess(uint256 _role, address _permissionChecker) external {
        vm.expectEmit(address(trustlessManagement));
        emit ITrustlessManagement.FullAccessChanged(_role, _permissionChecker);
        trustlessManagement.changeFullAccess(_role, _permissionChecker);
    }

    /// forge-config: default.fuzz.runs = 10
    function test_changeZoneAccess(uint256 _role, address _zone, address _permissionChecker) external {
        vm.expectEmit(address(trustlessManagement));
        emit ITrustlessManagement.ZoneAccessChanged(_role, _zone, _permissionChecker);
        trustlessManagement.changeZoneAccess(_role, _zone, _permissionChecker);
    }

    /// forge-config: default.fuzz.runs = 10
    function test_changeFunctionAccess(
        uint256 _role,
        address _zone,
        bytes4 _functionSelector,
        address _permissionChecker
    ) external {
        vm.expectEmit(address(trustlessManagement));
        emit ITrustlessManagement.FunctionAccessChanged(_role, _zone, _functionSelector, _permissionChecker);
        trustlessManagement.changeFunctionAccess(_role, _zone, _functionSelector, _permissionChecker);
    }

    /// forge-config: default.fuzz.runs = 10
    function test_asDAO(
        uint256 _role,
        uint256[] calldata _callableIndexes,
        bytes[] calldata _calldatas,
        bytes[] calldata _returnValues,
        uint256 _failureMap
    ) external {
        vm.assume(_calldatas.length >= _callableIndexes.length);
        vm.assume(_returnValues.length >= _callableIndexes.length);
        ActionHelper actionHelper = new ActionHelper(_callableIndexes, _calldatas, _returnValues);
        vm.assume(actionHelper.isValid());

        trustlessManagement.changeFullAccess(_role, NO_PERMISSION_CHECKER);
        IDAO.Action[] memory actions = actionHelper.getActions();
        bytes[] memory shortendReturnValues = new bytes[](actions.length);
        for (uint256 i; i < shortendReturnValues.length; i++) {
            shortendReturnValues[i] = _returnValues[i];
        }

        vm.expectEmit(address(trustlessManagement));
        emit IDAOManager.Execution(address(this), _role, actions, shortendReturnValues, 0);
        trustlessManagement.asDAO(_role, actions, _failureMap);
    }
}

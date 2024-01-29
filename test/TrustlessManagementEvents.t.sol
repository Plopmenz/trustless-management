// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "../lib/forge-std/src/Test.sol";

import {
    TrustlessManagementMock,
    NO_PERMISSION_CHECKER,
    ITrustlessManagement,
    IDAOManager,
    IDAO,
    IDAOExtensionWithAdmin
} from "./mocks/TrustlessManagementMock.sol";
import {DAOMock} from "./mocks/DAOMock.sol";
import {ActionHelper} from "./helpers/ActionHelper.sol";

contract TrustlessManagementTest is Test {
    DAOMock public dao;
    TrustlessManagementMock public trustlessManagement;

    function setUp() external {
        dao = new DAOMock();
        trustlessManagement = new TrustlessManagementMock();
        vm.prank(address(dao));
        trustlessManagement.setAdmin(dao, address(this));
    }

    /// forge-config: default.fuzz.runs = 10
    function test_changeFunctionBlacklist(
        uint256 _role,
        address _zone,
        bytes4 _functionSelector,
        address _permissionChecker
    ) external {
        vm.expectEmit(address(trustlessManagement));
        emit ITrustlessManagement.FunctionBlacklistChanged(dao, _role, _zone, _functionSelector, _permissionChecker);
        trustlessManagement.changeFunctionBlacklist(dao, _role, _zone, _functionSelector, _permissionChecker);
    }

    /// forge-config: default.fuzz.runs = 10
    function test_changeZoneBlacklist(uint256 _role, address _zone, address _permissionChecker) external {
        vm.expectEmit(address(trustlessManagement));
        emit ITrustlessManagement.ZoneBlacklistChanged(dao, _role, _zone, _permissionChecker);
        trustlessManagement.changeZoneBlacklist(dao, _role, _zone, _permissionChecker);
    }

    /// forge-config: default.fuzz.runs = 10
    function test_changeFullAccess(uint256 _role, address _permissionChecker) external {
        vm.expectEmit(address(trustlessManagement));
        emit ITrustlessManagement.FullAccessChanged(dao, _role, _permissionChecker);
        trustlessManagement.changeFullAccess(dao, _role, _permissionChecker);
    }

    /// forge-config: default.fuzz.runs = 10
    function test_changeZoneAccess(uint256 _role, address _zone, address _permissionChecker) external {
        vm.expectEmit(address(trustlessManagement));
        emit ITrustlessManagement.ZoneAccessChanged(dao, _role, _zone, _permissionChecker);
        trustlessManagement.changeZoneAccess(dao, _role, _zone, _permissionChecker);
    }

    /// forge-config: default.fuzz.runs = 10
    function test_changeFunctionAccess(
        uint256 _role,
        address _zone,
        bytes4 _functionSelector,
        address _permissionChecker
    ) external {
        vm.expectEmit(address(trustlessManagement));
        emit ITrustlessManagement.FunctionAccessChanged(dao, _role, _zone, _functionSelector, _permissionChecker);
        trustlessManagement.changeFunctionAccess(dao, _role, _zone, _functionSelector, _permissionChecker);
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

        trustlessManagement.changeFullAccess(dao, _role, NO_PERMISSION_CHECKER);
        IDAO.Action[] memory actions = actionHelper.getActions();
        bytes[] memory shortendReturnValues = new bytes[](actions.length);
        for (uint256 i; i < shortendReturnValues.length; i++) {
            shortendReturnValues[i] = _returnValues[i];
        }

        vm.expectEmit(address(trustlessManagement));
        emit IDAOManager.Execution(dao, _role, address(this), actions, shortendReturnValues, 0);
        trustlessManagement.asDAO(dao, _role, actions, _failureMap);
    }

    /// forge-config: default.fuzz.runs = 10
    function test_setAdmin(address _admin) external {
        vm.expectEmit(address(trustlessManagement));
        emit IDAOExtensionWithAdmin.AdminSet(dao, _admin);
        trustlessManagement.setAdmin(dao, _admin);
    }
}

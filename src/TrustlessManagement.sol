// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Plugin} from "../lib/osx-commons/contracts/src/plugin/Plugin.sol";
import {IPermissionChecker} from "./IPermissionChecker.sol";

import {ITrustlessManagement, IDAOManager, IDAO, MANAGER_PERMISSION_ID} from "./ITrustlessManagement.sol";

address constant NO_PERMISSION_CHECKER = address(type(uint160).max);
bytes32 constant EXECUTION_ID = keccak256("TRUSTLESS_MANAGEMENT");

abstract contract TrustlessManagement is Plugin, ITrustlessManagement {
    mapping(uint256 => mapping(uint256 => address)) private functionBlacklist;
    mapping(address => mapping(uint256 => address)) private zoneBlacklist;
    mapping(uint256 => address) private fullAccess;
    mapping(address => mapping(uint256 => address)) private zoneAccess;
    mapping(uint256 => mapping(uint256 => address)) private functionAccess;

    constructor(IDAO _dao) Plugin(_dao) {}

    /// @inheritdoc Plugin
    function supportsInterface(bytes4 _interfaceId) public view virtual override returns (bool) {
        return _interfaceId == type(ITrustlessManagement).interfaceId || super.supportsInterface(_interfaceId);
    }

    /// @inheritdoc ITrustlessManagement
    function hasRole(address _account, uint256 _roleId) public view virtual returns (bool);

    /// @inheritdoc ITrustlessManagement
    function isAllowed(uint256 _role, IDAO.Action[] calldata _actions) public view returns (bool) {
        for (uint256 i; i < _actions.length;) {
            uint256 functionId = _functionId(_actions[i].to, bytes4(_actions[i].data));
            if (
                checkPermission(functionBlacklist[functionId][_role], _role, _actions[i])
                    || checkPermission(zoneBlacklist[_actions[i].to][_role], _role, _actions[i])
            ) {
                // Blacklisted
                return false;
            }

            if (
                !checkPermission(fullAccess[_role], _role, _actions[i])
                    && !checkPermission(zoneAccess[_actions[i].to][_role], _role, _actions[i])
                    && !checkPermission(functionAccess[functionId][_role], _role, _actions[i])
            ) {
                // Permission not granted
                return false;
            }

            unchecked {
                ++i;
            }
        }

        // No action rejected => allowed
        return true;
    }

    /// @inheritdoc IDAOManager
    function asDAO(uint256 _role, IDAO.Action[] calldata _actions, uint256 _failureMap)
        external
        returns (bytes[] memory returnValues, uint256 failureMap)
    {
        if (!hasRole(msg.sender, _role)) {
            revert SenderDoesNotHaveRole();
        }
        if (!isAllowed(_role, _actions)) {
            revert AccessDenied();
        }

        (returnValues, failureMap) = dao().execute(EXECUTION_ID, _actions, _failureMap);
        emit Execution(msg.sender, _role, _actions, returnValues, failureMap);
    }

    /// @inheritdoc ITrustlessManagement
    function changeFunctionBlacklist(uint256 _role, address _zone, bytes4 _functionSelector, address _permissionChecker)
        external
        auth(MANAGER_PERMISSION_ID)
    {
        functionBlacklist[_functionId(_zone, _functionSelector)][_role] = _permissionChecker;
        emit FunctionBlacklistChanged(_role, _zone, _functionSelector, _permissionChecker);
    }

    /// @inheritdoc ITrustlessManagement
    function changeZoneBlacklist(uint256 _role, address _zone, address _permissionChecker)
        external
        auth(MANAGER_PERMISSION_ID)
    {
        zoneBlacklist[_zone][_role] = _permissionChecker;
        emit ZoneBlacklistChanged(_role, _zone, _permissionChecker);
    }

    /// @inheritdoc ITrustlessManagement
    function changeFullAccess(uint256 _role, address _permissionChecker) external auth(MANAGER_PERMISSION_ID) {
        fullAccess[_role] = _permissionChecker;
        emit FullAccessChanged(_role, _permissionChecker);
    }

    /// @inheritdoc ITrustlessManagement
    function changeZoneAccess(uint256 _role, address _zone, address _permissionChecker)
        external
        auth(MANAGER_PERMISSION_ID)
    {
        zoneAccess[_zone][_role] = _permissionChecker;
        emit ZoneAccessChanged(_role, _zone, _permissionChecker);
    }

    /// @inheritdoc ITrustlessManagement
    function changeFunctionAccess(uint256 _role, address _zone, bytes4 _functionSelector, address _permissionChecker)
        external
        auth(MANAGER_PERMISSION_ID)
    {
        functionAccess[_functionId(_zone, _functionSelector)][_role] = _permissionChecker;
        emit FunctionAccessChanged(_role, _zone, _functionSelector, _permissionChecker);
    }

    function checkPermission(address _permissionChecker, uint256 _role, IDAO.Action calldata _action)
        internal
        view
        returns (bool)
    {
        if (_permissionChecker == address(0)) {
            // Permission not granted
            return false;
        }
        if (_permissionChecker == NO_PERMISSION_CHECKER) {
            // Permission always granted
            return true;
        }

        // Additional check
        return IPermissionChecker(_permissionChecker).checkPermission(_role, _action);
    }

    // address + function selector
    function _functionId(address _zone, bytes4 _functionSelector) internal pure returns (uint256) {
        return (uint160(bytes20(_zone)) << 32) + uint32(_functionSelector);
    }
}

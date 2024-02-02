// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC165} from "../lib/openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";
import {ClaimReverseENS} from "../lib/ens-reverse-registrar/src/ClaimReverseENS.sol";

import {IPermissionChecker} from "./IPermissionChecker.sol";
import {ITrustlessManagement, IDAOManager, IDAO, IDAOExtensionWithAdmin} from "./ITrustlessManagement.sol";

address constant NO_PERMISSION_CHECKER = address(type(uint160).max);
bytes32 constant EXECUTION_ID = keccak256("TRUSTLESS_MANAGEMENT");

abstract contract TrustlessManagement is ERC165, ClaimReverseENS, ITrustlessManagement {
    mapping(IDAO dao => DAOInfo info) private daoInfo;

    constructor(address _admin, address _reverseRegistrar) ClaimReverseENS(_reverseRegistrar, _admin) {}

    /// @inheritdoc ERC165
    function supportsInterface(bytes4 _interfaceId) public view virtual override returns (bool) {
        return _interfaceId == type(ITrustlessManagement).interfaceId || super.supportsInterface(_interfaceId);
    }

    /// @inheritdoc ITrustlessManagement
    function hasRole(address _account, uint256 _roleId) public view virtual returns (bool);

    /// @inheritdoc ITrustlessManagement
    function isAllowed(IDAO _dao, uint256 _role, IDAO.Action[] calldata _actions) public view returns (bool) {
        PermissionInfo storage permissions = daoInfo[_dao].permissions[_role];

        for (uint256 i; i < _actions.length;) {
            uint256 functionId = _functionId(_actions[i].to, bytes4(_actions[i].data));
            if (
                _checkPermission(permissions.functionBlacklist[functionId], _role, _actions[i])
                    || _checkPermission(permissions.zoneBlacklist[_actions[i].to], _role, _actions[i])
            ) {
                // Blacklisted
                return false;
            }

            if (
                !_checkPermission(permissions.fullAccess, _role, _actions[i])
                    && !_checkPermission(permissions.zoneAccess[_actions[i].to], _role, _actions[i])
                    && !_checkPermission(permissions.functionAccess[functionId], _role, _actions[i])
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
    function asDAO(IDAO _dao, uint256 _role, IDAO.Action[] calldata _actions, uint256 _failureMap)
        external
        returns (bytes[] memory returnValues, uint256 failureMap)
    {
        if (!hasRole(msg.sender, _role)) {
            revert SenderDoesNotHaveRole();
        }
        if (!isAllowed(_dao, _role, _actions)) {
            revert AccessDenied();
        }

        (returnValues, failureMap) = _dao.execute(EXECUTION_ID, _actions, _failureMap);
        emit Execution(_dao, _role, msg.sender, _actions, returnValues, failureMap);
    }

    /// @inheritdoc IDAOExtensionWithAdmin
    function setAdmin(IDAO _dao, address _admin) external {
        DAOInfo storage info = daoInfo[_dao];
        _ensureSenderIsAdmin(_dao, info.admin);
        info.admin = _admin;
        emit AdminSet(_dao, _admin);
    }

    /// @inheritdoc ITrustlessManagement
    function changeFullAccess(IDAO _dao, uint256 _role, address _permissionChecker) external {
        DAOInfo storage info = daoInfo[_dao];
        _ensureSenderIsAdmin(_dao, info.admin);
        info.permissions[_role].fullAccess = _permissionChecker;
        emit FullAccessChanged(_dao, _role, _permissionChecker);
    }

    /// @inheritdoc ITrustlessManagement
    function changeZoneAccess(IDAO _dao, uint256 _role, address _zone, address _permissionChecker) external {
        DAOInfo storage info = daoInfo[_dao];
        _ensureSenderIsAdmin(_dao, info.admin);
        info.permissions[_role].zoneAccess[_zone] = _permissionChecker;
        emit ZoneAccessChanged(_dao, _role, _zone, _permissionChecker);
    }

    /// @inheritdoc ITrustlessManagement
    function changeZoneBlacklist(IDAO _dao, uint256 _role, address _zone, address _permissionChecker) external {
        DAOInfo storage info = daoInfo[_dao];
        _ensureSenderIsAdmin(_dao, info.admin);
        info.permissions[_role].zoneBlacklist[_zone] = _permissionChecker;
        emit ZoneBlacklistChanged(_dao, _role, _zone, _permissionChecker);
    }

    /// @inheritdoc ITrustlessManagement
    function changeFunctionAccess(
        IDAO _dao,
        uint256 _role,
        address _zone,
        bytes4 _functionSelector,
        address _permissionChecker
    ) external {
        DAOInfo storage info = daoInfo[_dao];
        _ensureSenderIsAdmin(_dao, info.admin);
        info.permissions[_role].functionAccess[_functionId(_zone, _functionSelector)] = _permissionChecker;
        emit FunctionAccessChanged(_dao, _role, _zone, _functionSelector, _permissionChecker);
    }

    /// @inheritdoc ITrustlessManagement
    function changeFunctionBlacklist(
        IDAO _dao,
        uint256 _role,
        address _zone,
        bytes4 _functionSelector,
        address _permissionChecker
    ) external {
        DAOInfo storage info = daoInfo[_dao];
        _ensureSenderIsAdmin(_dao, info.admin);
        info.permissions[_role].functionBlacklist[_functionId(_zone, _functionSelector)] = _permissionChecker;
        emit FunctionBlacklistChanged(_dao, _role, _zone, _functionSelector, _permissionChecker);
    }

    function _checkPermission(address _permissionChecker, uint256 _role, IDAO.Action calldata _action)
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

    function _ensureSenderIsAdmin(IDAO _dao, address _admin) internal view {
        if (_admin == address(0)) {
            // Admin not set means DAO is the admin
            if (msg.sender != address(_dao)) {
                revert SenderIsNotAdmin();
            }
        } else {
            // Specific admin will only be allowed. DAO is not allowed to change permissions. (for example: if it is a SubDAO)
            if (msg.sender != _admin) {
                revert SenderIsNotAdmin();
            }
        }
    }
}

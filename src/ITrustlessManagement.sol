// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IDAOManager, IDAO} from "./IDAOManager.sol";

interface ITrustlessManagement is IDAOManager {
    error SenderIsNotAdmin();
    error SenderDoesNotHaveRole();

    event FunctionBlacklistChanged(
        IDAO indexed dao, uint256 indexed role, address zone, bytes4 functionSelector, address permissionChecker
    );
    event ZoneBlacklistChanged(IDAO indexed dao, uint256 indexed role, address zone, address permissionChecker);
    event FullAccessChanged(IDAO indexed dao, uint256 indexed role, address permissionChecker);
    event ZoneAccessChanged(IDAO indexed dao, uint256 indexed role, address zone, address permissionChecker);
    event FunctionAccessChanged(
        IDAO indexed dao, uint256 indexed role, address zone, bytes4 functionSelector, address permissionChecker
    );

    struct DAOInfo {
        address admin;
        mapping(uint256 role => PermissionInfo) permissions;
    }

    struct PermissionInfo {
        address fullAccess;
        mapping(address zone => address permissionChecker) zoneAccess;
        mapping(address zone => address permissionChecker) zoneBlacklist;
        mapping(uint256 functionId => address permissionChecker) functionAccess;
        mapping(uint256 functionId => address permissionChecker) functionBlacklist;
    }

    /// @notice Verifies if an address has/satisfies a certain role.
    /// @param _account The address to check.
    /// @param _roleId The role to check.
    function hasRole(address _account, uint256 _roleId) external view returns (bool);

    /// @notice Verifies if a role is allowed to execute a list of actions.
    /// @param _dao The dao to check permissions of.
    /// @param _role The role to check permission for.
    /// @param _actions The actions to check.
    /// @dev Only a single role means that a user satisfies multiple roles they might need to split their actions into multiple batches (one per role).
    function isAllowed(IDAO _dao, uint256 _role, IDAO.Action[] calldata _actions) external view returns (bool);

    /// @notice Grants/Revokes a role the permission to do any action (if not blacklisted).
    /// @param _dao The dao that will have the permission change.
    /// @param _role The role that is granted/revoked the permission.
    /// @param _permissionChecker ZeroAddress for always off, FullAddress (0xFFF...FFF) for always on. Can be the address of IPermissionChecker smart contract for a custom condition check.
    function changeFullAccess(IDAO _dao, uint256 _role, address _permissionChecker) external;

    /// @notice Grants/Revokes a role the permission to call all functions of one smart contract (if not blacklisted).
    /// @param _dao The dao that will have the permission change.
    /// @param _role The role that is granted/revoked the permission.
    /// @param _zone The address of the smart contract.
    /// @param _permissionChecker ZeroAddress for always off, FullAddress (0xFFF...FFF) for always on. Can be the address of IPermissionChecker smart contract for a custom condition check.
    function changeZoneAccess(IDAO _dao, uint256 _role, address _zone, address _permissionChecker) external;

    /// @notice Adds to / Removes from a blacklist preventing a role from calling one function of one smart contract.
    /// @param _dao The dao that will have the permission change.
    /// @param _role The role that is added to / removed from this blacklist.
    /// @param _zone The address of the smart contract.
    /// @param _functionSelector The function selector of the smart contract.
    /// @param _permissionChecker ZeroAddress for always off, FullAddress (0xFFF...FFF) for always on. Can be the address of IPermissionChecker smart contract for a custom condition check.
    /// @dev This takes priority no matter what access (full/zone/function) the role has.
    function changeFunctionBlacklist(
        IDAO _dao,
        uint256 _role,
        address _zone,
        bytes4 _functionSelector,
        address _permissionChecker
    ) external;

    /// @notice Grants/Revokes a role the permission to call one function of one smart contract (if not blacklisted).
    /// @param _dao The dao that will have the permission change.
    /// @param _role The role that is granted/revoked the permission.
    /// @param _zone The address of the smart contract.
    /// @param _functionSelector The function selector of the smart contract.
    /// @param _permissionChecker ZeroAddress for always off, FullAddress (0xFFF...FFF) for always on. Can be the address of IPermissionChecker smart contract for a custom condition check.
    function changeFunctionAccess(
        IDAO _dao,
        uint256 _role,
        address _zone,
        bytes4 _functionSelector,
        address _permissionChecker
    ) external;

    /// @notice Adds to / Removes from a blacklist preventing a role from calling any function of one smart contract.
    /// @param _dao The dao that will have the permission change.
    /// @param _role The role that is added to / removed from this blacklist.
    /// @param _zone The address of the smart contract.
    /// @param _permissionChecker ZeroAddress for always off, FullAddress (0xFFF...FFF) for always on. Can be the address of IPermissionChecker smart contract for a custom condition check.
    /// @dev This takes priority no matter what access (full/zone/function) the role has.
    function changeZoneBlacklist(IDAO _dao, uint256 _role, address _zone, address _permissionChecker) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IDAOManager, IDAO} from "./IDAOManager.sol";

bytes32 constant MANAGER_PERMISSION_ID = keccak256("MANAGER_PERMISSION");

interface ITrustlessManagement is IDAOManager {
    error SenderDoesNotHaveRole();

    event FunctionBlacklistChanged(
        uint256 indexed role, address zone, bytes4 functionSelector, address permissionChecker
    );
    event ZoneBlacklistChanged(uint256 indexed role, address zone, address permissionChecker);
    event FullAccessChanged(uint256 indexed role, address permissionChecker);
    event ZoneAccessChanged(uint256 indexed role, address zone, address permissionChecker);
    event FunctionAccessChanged(uint256 indexed role, address zone, bytes4 functionSelector, address permissionChecker);

    /// @notice Verifies if an address has/satisfies a certain role.
    /// @param _account The address to check.
    /// @param _roleId The role to check.
    function hasRole(address _account, uint256 _roleId) external view returns (bool);

    /// @notice Verifies if a role is allowed to execute a list of actions.
    /// @param _role The role to check permission for.
    /// @param _actions The actions to check.
    /// @dev Only a single role means that a user satisfies multiple roles they might need to split their actions into multiple batches (one per role).
    function isAllowed(uint256 _role, IDAO.Action[] calldata _actions) external view returns (bool);

    /// @notice Adds to / Removes from a blacklist preventing a role from calling one function of one smart contract.
    /// @param _role The role that is added to / removed from this blacklist.
    /// @param _zone The address of the smart contract.
    /// @param _functionSelector The function selector of the smart contract.
    /// @param _permissionChecker ZeroAddress for always off, FullAddress (0xFFF...FFF) for always on. Can be the address of IPermissionChecker smart contract for a custom condition check.
    /// @dev This takes priority no matter what access (full/zone/function) the role has.
    function changeFunctionBlacklist(uint256 _role, address _zone, bytes4 _functionSelector, address _permissionChecker)
        external;

    /// @notice Adds to / Removes from a blacklist preventing a role from calling any function of one smart contract.
    /// @param _role The role that is added to / removed from this blacklist.
    /// @param _zone The address of the smart contract.
    /// @param _permissionChecker ZeroAddress for always off, FullAddress (0xFFF...FFF) for always on. Can be the address of IPermissionChecker smart contract for a custom condition check.
    /// @dev This takes priority no matter what access (full/zone/function) the role has.
    function changeZoneBlacklist(uint256 _role, address _zone, address _permissionChecker) external;

    /// @notice Grants/Revokes a role the permission to do any action (if not blacklisted).
    /// @param _role The role that is granted/revoked the permission.
    /// @param _permissionChecker ZeroAddress for always off, FullAddress (0xFFF...FFF) for always on. Can be the address of IPermissionChecker smart contract for a custom condition check.
    function changeFullAccess(uint256 _role, address _permissionChecker) external;

    /// @notice Grants/Revokes a role the permission to call all functions of one smart contract (if not blacklisted).
    /// @param _role The role that is granted/revoked the permission.
    /// @param _zone The address of the smart contract.
    /// @param _permissionChecker ZeroAddress for always off, FullAddress (0xFFF...FFF) for always on. Can be the address of IPermissionChecker smart contract for a custom condition check.
    function changeZoneAccess(uint256 _role, address _zone, address _permissionChecker) external;

    /// @notice Grants/Revokes a role the permission to call one function of one smart contract (if not blacklisted).
    /// @param _role The role that is granted/revoked the permission.
    /// @param _zone The address of the smart contract.
    /// @param _functionSelector The function selector of the smart contract.
    /// @param _permissionChecker ZeroAddress for always off, FullAddress (0xFFF...FFF) for always on. Can be the address of IPermissionChecker smart contract for a custom condition check.
    function changeFunctionAccess(uint256 _role, address _zone, bytes4 _functionSelector, address _permissionChecker)
        external;
}

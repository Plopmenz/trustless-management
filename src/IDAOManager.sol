// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IDAO} from "../lib/osx-commons/contracts/src/dao/IDAO.sol";

interface IDAOManager {
    error AccessDenied();

    event Execution(
        IDAO indexed dao,
        uint256 indexed role,
        address indexed sender,
        IDAO.Action[] actions,
        bytes[] returnValues,
        uint256 failureMap
    );

    event AdminSet(IDAO indexed dao, address admin);

    /// @notice Executes a list of actions as the DAO.
    /// @param _dao Which dao should execute the actions.
    /// @param _role The role to use for validation if execution is allowed.
    /// @param _actions The actions to execute.
    /// @param _failureMap Which actions are allowed to fail without reverting the whole transaction.
    /// @dev Only a single role means that a user satisfies multiple roles they might need to split their actions into multiple batches (one per role).
    function asDAO(IDAO _dao, uint256 _role, IDAO.Action[] calldata _actions, uint256 _failureMap)
        external
        returns (bytes[] memory returnValues, uint256 failureMap);

    /// @notice Registers or updates the admin of a dao. The admin has the permission to change permissions.
    /// @param _dao The dao this admin will control.
    /// @param _admin The address that will control the dao.
    /// @dev If no admin is set, this can only be called by the dao itself. When an admin is set, only the existing admin can update.
    function setAdmin(IDAO _dao, address _admin) external;
}

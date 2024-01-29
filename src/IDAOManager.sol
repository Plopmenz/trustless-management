// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IDAOExtensionWithAdmin, IDAO} from "./IDAOExtensionWithAdmin.sol";

interface IDAOManager is IDAOExtensionWithAdmin {
    error AccessDenied();

    event Execution(
        IDAO indexed dao,
        uint256 indexed role,
        address indexed sender,
        IDAO.Action[] actions,
        bytes[] returnValues,
        uint256 failureMap
    );

    /// @notice Executes a list of actions as the DAO.
    /// @param _dao Which DAO should execute the actions.
    /// @param _role The role to use for validation if execution is allowed.
    /// @param _actions The actions to execute.
    /// @param _failureMap Which actions are allowed to fail without reverting the whole transaction.
    /// @dev Only a single role means that a user satisfies multiple roles they might need to split their actions into multiple batches (one per role).
    function asDAO(IDAO _dao, uint256 _role, IDAO.Action[] calldata _actions, uint256 _failureMap)
        external
        returns (bytes[] memory returnValues, uint256 failureMap);
}

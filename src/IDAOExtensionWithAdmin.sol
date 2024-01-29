// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IDAO} from "../lib/osx-commons/contracts/src/dao/IDAO.sol";

interface IDAOExtensionWithAdmin {
    event AdminSet(IDAO indexed dao, address admin);

    /// @notice Registers or updates the admin of a DAO. The admin has the permission to change permissions.
    /// @param _dao The DAO this admin will control.
    /// @param _admin The address that will control the DAO.
    /// @dev If no admin is set, this can only be called by the DAO itself. When an admin is set, only the existing admin can update.
    function setAdmin(IDAO _dao, address _admin) external;
}

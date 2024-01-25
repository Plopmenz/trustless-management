// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IDAO} from "../lib/osx-commons/contracts/src/dao/IDAO.sol";

interface IPermissionChecker {
    /// @notice Additional external check if custom conditions are met.
    /// @param _role The role to check permission for. (this could represent address / holding x amount of ERC20 tokens / ERC721 tokenId / ERC1155 tokenId)
    /// @param _action The action to check.
    function checkPermission(uint256 _role, IDAO.Action calldata _action) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IDAO} from "../../lib/osx-commons/contracts/src/dao/IDAO.sol";
import {CallableMock} from "../mocks/CallableMock.sol";

contract ActionHelper {
    error InvalidActions();

    mapping(uint256 => mapping(bytes4 => bytes32)) returnValuesCheck;
    mapping(uint256 => CallableMock) callables;
    bool private valid = true;
    IDAO.Action[] private actions;

    constructor(uint256[] memory _callableIndexes, bytes[] memory _calldatas, bytes[] memory _returnValues) {
        for (uint256 i; i < _callableIndexes.length; i++) {
            if (
                returnValuesCheck[_callableIndexes[i]][bytes4(_calldatas[i])] != bytes32(0)
                    && returnValuesCheck[_callableIndexes[i]][bytes4(_calldatas[i])] != keccak256(_returnValues[i])
            ) {
                valid = false;
                return;
            }

            if (address(callables[_callableIndexes[i]]) == address(0)) {
                callables[_callableIndexes[i]] = new CallableMock();
            }
            if (!callables[_callableIndexes[i]].setReturnValue(bytes4(_calldatas[i]), _returnValues[i])) {
                valid = false;
                return;
            }
            returnValuesCheck[_callableIndexes[i]][bytes4(_calldatas[i])] = keccak256(_returnValues[i]);
        }

        for (uint256 i; i < _callableIndexes.length; i++) {
            actions.push(IDAO.Action(address(callables[_callableIndexes[i]]), 0, _calldatas[i]));
        }
    }

    function isValid() external view returns (bool) {
        return valid;
    }

    function getActions() external view returns (IDAO.Action[] memory) {
        if (!valid) {
            revert InvalidActions();
        }

        return actions;
    }
}

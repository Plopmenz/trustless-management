// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "../../lib/forge-std/src/Test.sol";

import {CallableMock} from "./CallableMock.sol";

contract CallableMockTest is Test {
    CallableMock public callableMock;

    function setUp() external {
        callableMock = new CallableMock();
    }

    /// forge-config: default.fuzz.runs = 10
    function test_setReturnValue(bytes calldata _calldata, bytes calldata _returnValue) external {
        vm.assume(callableMock.setReturnValue(bytes4(_calldata), _returnValue));
        (, bytes memory result) = address(callableMock).call(_calldata);
        assert(keccak256(result) == keccak256(_returnValue));
    }
}

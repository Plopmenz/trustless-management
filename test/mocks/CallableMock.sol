// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CallableMock {
    mapping(bytes4 => bytes) returnValue;

    function setReturnValue(bytes4 _functionSelector, bytes calldata _returnValue) external returns (bool) {
        if (_functionSelector == bytes4(0) || _functionSelector == this.setReturnValue.selector) {
            return false;
        }

        returnValue[_functionSelector] = _returnValue;
        return true;
    }

    fallback(bytes calldata _data) external returns (bytes memory) {
        return returnValue[bytes4(_data)];
    }
}

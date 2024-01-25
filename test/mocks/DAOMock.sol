// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IDAO} from "../../lib/osx-commons/contracts/src/dao/IDAO.sol";

contract DAOMock is IDAO {
    error ActionReverted(uint256 actionIndex);

    function hasPermission(address _where, address _who, bytes32 _permissionId, bytes memory _data)
        external
        pure
        returns (bool)
    {
        (_where, _who, _permissionId, _data);
        return true;
    }

    function setMetadata(bytes calldata _metadata) external {}

    function execute(bytes32 _callId, Action[] memory _actions, uint256 _allowFailureMap)
        external
        returns (bytes[] memory returnValues, uint256 failureMap)
    {
        (_callId, _allowFailureMap);
        failureMap = 0;
        returnValues = new bytes[](_actions.length);
        for (uint256 i; i < _actions.length; i++) {
            (bool success, bytes memory result) = _actions[i].to.call{value: _actions[i].value}(_actions[i].data);
            if (!success) {
                revert ActionReverted(i);
            }
            returnValues[i] = result;
        }
    }

    function deposit(address _token, uint256 _amount, string calldata _reference) external payable {}

    function setTrustedForwarder(address _trustedForwarder) external {}

    function getTrustedForwarder() external view returns (address) {}

    function setSignatureValidator(address _signatureValidator) external {}

    function isValidSignature(bytes32 _hash, bytes memory _signature) external returns (bytes4) {}

    function registerStandardCallback(bytes4 _interfaceId, bytes4 _callbackSelector, bytes4 _magicNumber) external {}
}

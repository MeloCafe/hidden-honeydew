// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./IVerifier.sol";

contract TrueVerifier is IVerifier {
    function verify(bytes calldata) external pure override returns (bool) {
        return true;
    }
}

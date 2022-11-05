// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

interface IVerifier {
    function verify(bytes calldata) external view returns (bool);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "forge-std/Script.sol";

import "../src/MeloVaultFactory.sol";

contract MeloVaultFactoryDeploy is Script {
    function run() public {
        vm.broadcast();
        new MeloVaultFactory();
    }
}

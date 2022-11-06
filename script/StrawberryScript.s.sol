// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "forge-std/Script.sol";

import "../src/SuspiciousStrawberry.sol";

contract StrawberryScript is Script {
    function run() public {
        address strawberryAddress = vm.envAddress("STRAWBERRY_ADDRESS");
        SuspiciousStrawberry strawberry = SuspiciousStrawberry(strawberryAddress);

        vm.broadcast();
        strawberry.setBaseURI("https://api.melo.cafe/strawberry/");
    }
}

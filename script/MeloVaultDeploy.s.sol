// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "forge-std/Script.sol";

import "../../src/MeloVault.sol";
import "../../src/TrueVerifier.sol";
import "../../src/SuspiciousStrawberry.sol";

contract Deploy is Script {
    function run() public {
        vm.broadcast();
        IVerifier verifier = new TrueVerifier();
        
        vm.broadcast();
        SuspiciousStrawberry strawberry = new SuspiciousStrawberry();

        vm.broadcast();
        new MeloVault("my vault", address(verifier), address(strawberry));
    }
}

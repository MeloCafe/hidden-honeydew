// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "forge-std/Script.sol";

import "../src/MeloVault.sol";
import "../src/TrueVerifier.sol";
import "../src/SuspiciousStrawberry.sol";

contract MeloVaultDeploy is Script {
    function run() public {
        vm.broadcast();
        IVerifier verifier = new TrueVerifier();
        
        vm.broadcast();
        SuspiciousStrawberry strawberry = new SuspiciousStrawberry("base uri");

        vm.broadcast();
        strawberry.mint(tx.origin, 1);

        vm.broadcast();
        new MeloVault("my vault", address(strawberry), address(verifier));
    }
}

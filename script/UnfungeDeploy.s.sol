// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "forge-std/Script.sol";

import "../src/Unfunge.sol";

contract UnfungeDeploy is Script {
    function run() public {
        vm.broadcast();
        new Unfunge("Unfunge", "UNF", vm.envAddress("FUNGIBLE_TOKEN_ADDRESS"), vm.envUint("AMOUNT_PER_NFT"));
    }
}

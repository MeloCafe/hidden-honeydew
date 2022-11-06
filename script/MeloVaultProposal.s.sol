// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "forge-std/Script.sol";

import "../src/MeloVault.sol";

contract MeloVaultProposal is Script {
    function run() public {
        address vaultAddress = vm.envAddress("VAULT_ADDRESS");
        MeloVault vault = MeloVault(payable(vaultAddress));

        MeloVault.Proposal memory proposal = MeloVault.Proposal({
            endBlock: block.number + 100,
            title: "a really good idea",
            descriptionHash: "bafybeicxohold3t3hfo4j3trns3bmi6oeifkfstfdz4c45fgbhprx6zlba",
            transactions: new MeloVault.Transaction[](1)
        });

        proposal.transactions[0] = MeloVault.Transaction({
            to: address(0x69),
            value: 0.001 ether,
            data: new bytes(0),
            gas: 21000
        });

        vm.broadcast();
        vault.propose(proposal);
    }
}

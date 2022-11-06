// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./MeloVault.sol";

contract MeloVaultFactory {
    function createVault(
        string memory _name,
        address _nft,
        address _verifier
    ) external returns (address) {
        MeloVault vault = new MeloVault(_name, _nft, _verifier);
        return address(vault);
    }
}

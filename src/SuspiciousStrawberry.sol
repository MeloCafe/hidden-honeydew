// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "ERC721A/ERC721A.sol";

contract SuspiciousStrawberry is ERC721A {
    string baseURI;

    constructor(string memory uri) ERC721A("Suspicious Strawberry", "SUSSTRAWB") {
        baseURI = uri;
    }

    function setBaseURI(string memory uri) public {
        baseURI = uri;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function mint(address to, uint256 tokenId) public {
        _mint(to, tokenId);
    }
}

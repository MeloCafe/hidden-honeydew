// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "ERC721A/ERC721A.sol";
import "openzeppelin/access/Ownable.sol";

contract SuspiciousStrawberry is ERC721A, Ownable {
    string baseURI;

    constructor(string memory uri) ERC721A("Suspicious Strawberry", "SUSSTRAWB") {
        baseURI = uri;
    }

    function setBaseURI(string memory uri) external onlyOwner {
        baseURI = uri;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function mint(address to, uint256 tokenId) external onlyOwner {
        _mint(to, tokenId);
    }
}

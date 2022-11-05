// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "openzeppelin/token/ERC721/ERC721.sol";

contract SuspiciousStrawberry is ERC721 {
    constructor() ERC721("Suspicious Strawberry", "SUSSTRAWB") {}

    function mint(address to, uint256 tokenId) public {
        _mint(to, tokenId);
    }
}

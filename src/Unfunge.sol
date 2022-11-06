// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "ERC721A/ERC721A.sol";
import "openzeppelin/token/ERC20/IERC20.sol";

contract Unfunge is ERC721A {

    IERC20 public immutable fungibleToken;
    uint256 public immutable amountPerNonFungibleToken;


    constructor(
        string memory name,
        string memory symbol,
        address _fungibleToken,
        uint256 _amountPerNonFungibleToken
    ) ERC721A(name, symbol) {
        fungibleToken = IERC20(_fungibleToken);
        amountPerNonFungibleToken = _amountPerNonFungibleToken;
    }

    function wrap(uint256 amount) public {
        require(amount > 0, "Unfunge: amount must be greater than 0");
        require(amount % amountPerNonFungibleToken == 0, "Unfunge: amount must be a multiple of amountPerNonFungibleToken");
        fungibleToken.transferFrom(msg.sender, address(this), amount);
        uint256 numTokens = amount / amountPerNonFungibleToken;
        _mint(msg.sender, numTokens);
    }

    function unwrap(uint256 tokenId) public {
        require(ownerOf(tokenId) == msg.sender, "Unfunge: caller is not the owner");
        fungibleToken.transfer(msg.sender, amountPerNonFungibleToken);
        _burn(tokenId);
    }
}

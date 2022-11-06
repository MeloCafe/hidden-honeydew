// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/Unfunge.sol";
import "openzeppelin/token/ERC20/ERC20.sol";

contract TestERC20 is ERC20 {
    constructor() ERC20("TestERC20", "TST") {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract UnfungeTest is Test {
   function testDeploy() public {
       new Unfunge("Unfunge", "UNF", address(0), 1);
   }

   function testWrapAndUnwrap() public {
        // make a test ERC20 token
        TestERC20 token = new TestERC20();

        // make a Unfunge contract
        Unfunge unfunge = new Unfunge("Unfunge", "UNF", address(token), 1 ether);


        address actor = address(1);

        // ensure we can't wrap 0
        vm.expectRevert("Unfunge: amount must be greater than 0");
        vm.prank(actor);
        unfunge.wrap(0);

        // ensure we can't wrap amounts that aren't multiples of the amountPerNonFungibleToken
        // first, mint some tokens
        token.mint(actor, 1 ether);
        vm.expectRevert("Unfunge: amount must be a multiple of amountPerNonFungibleToken");
        vm.prank(actor);
        unfunge.wrap(1);

        // ensure we can wrap
        vm.prank(actor);
        token.approve(address(unfunge), type(uint256).max);

        vm.prank(actor);
        unfunge.wrap(1 ether);

        assertEq(unfunge.balanceOf(actor), 1);
        assertEq(token.balanceOf(address(actor)), 0);
        assertEq(token.balanceOf(address(unfunge)), 1 ether);

        // wrap more

        token.mint(actor, 5 ether);
        vm.prank(actor);
        unfunge.wrap(5 ether);

        assertEq(unfunge.balanceOf(actor), 6);
        assertEq(token.balanceOf(address(actor)), 0);
        assertEq(token.balanceOf(address(unfunge)), 6 ether);

        // unwrap

        vm.prank(actor);
        unfunge.unwrap(0);

        assertEq(unfunge.balanceOf(actor), 5);
        assertEq(token.balanceOf(address(actor)), 1 ether);
        assertEq(token.balanceOf(address(unfunge)), 5 ether);
   }
}

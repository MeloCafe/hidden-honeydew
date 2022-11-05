// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/MeloVault.sol";
import "openzeppelin/token/ERC721/ERC721.sol";

contract TestVerifier is IVerifier {
    bool public output = true;

    function setOutput(bool _output) external {
        output = _output;
    }

    function verify(bytes calldata) external view override returns (bool) {
        return output;
    }
}

contract TestNFT is ERC721 {
    constructor() ERC721("TestNFT", "TST") {}

    function mint(address to, uint256 id) external {
        _mint(to, id);
    }
}

contract MeloVaultTest is Test {
    
    TestNFT token;
    IVerifier verifier;
    MeloVault vault;

    event ProposalCreated(
        bytes32 indexed id,
        bytes32 indexed snapshotBlockHash,
        MeloVault.Proposal indexed proposal
    );

    event ProposalExecuted(bytes32 indexed id, MeloVault.Proposal indexed proposal);

    function setUp() public {
        token = new TestNFT();
        verifier = new TestVerifier();
        vault = new MeloVault("MV", address(token), address(verifier));
    }
    
    function testDeploy() public {
       new MeloVault("MV", address(0), address(0));
    }

    function testReceive() public {
        address actor = address(1);
        vm.deal(address(actor), 1 ether);

        vm.prank(actor);
        payable(address(vault)).transfer(1 ether);

        token.mint(address(actor), 1);
        vm.prank(actor);
        token.safeTransferFrom(address(actor), address(vault), 1);
    }

    function testProposeAndExecute() public {
        address proposer = address(1);

        vm.deal(address(vault), 1 ether);

        // make a proposal with 1 transaction that sends 1 wei to the address(2)

        MeloVault.Proposal memory proposal = MeloVault.Proposal({
            endBlock: block.number + 100,
            title: "test",
            descriptionHash: "test",
            transactions: new MeloVault.Transaction[](1)
        });
        proposal.transactions[0] = MeloVault.Transaction({
            to: address(2),
            value: 1,
            data: new bytes(0),
            gas: 1
        });
        
        bytes32 propId = vault.proposalHash(proposal);

        // propose

        vm.prank(proposer);
        vm.expectRevert("MeloVault: not a token holder");
        vault.propose(proposal);

        token.mint(proposer, 1);

        vm.prank(proposer);
        vm.expectEmit(true, true, true, true);
        emit ProposalCreated(propId, blockhash(block.number - 1), proposal);
        vault.propose(proposal);

        // execute

        bytes memory fact = abi.encode(0);

        vm.expectRevert("MeloVault: too soon");
        vault.executeProposal(proposal, fact);

        vm.roll(proposal.endBlock);
        vm.expectRevert("MeloVault: too soon");
        vault.executeProposal(proposal, fact);

        vm.roll(proposal.endBlock + vault.blocksAllowedForExecution() + 1);
        vm.expectRevert("MeloVault: too late");
        vault.executeProposal(proposal, fact);

        vm.roll(proposal.endBlock + 1);
        vm.expectEmit(true, true, true, true);
        emit ProposalExecuted(propId, proposal);
        vault.executeProposal(proposal, fact);

        assertEq(address(2).balance, 1);

        vm.expectRevert("MeloVault: already executed");
        vault.executeProposal(proposal, fact);
    }
}


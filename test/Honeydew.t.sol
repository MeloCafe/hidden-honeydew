// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/Honeydew.sol";
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

contract HoneydewTest is Test {
    
    TestNFT token;
    IVerifier verifier;
    Honeydew honeydew;

    event ProposalCreated(
        bytes32 indexed id,
        bytes32 snapshotBlockHash,
        Honeydew.Proposal indexed proposal
    );

    event ProposalExecuted(bytes32 indexed id, Honeydew.Proposal indexed proposal);

    function setUp() public {
        token = new TestNFT();
        verifier = new TestVerifier();
        honeydew = new Honeydew("MV", address(token), address(verifier));
    }
    
    function testDeploy() public {
       new Honeydew("MV", address(0), address(0));
    }

    function testProposeAndExecute() public {
        address proposer = address(0x1);
        
        Honeydew.Proposal memory proposal = Honeydew.Proposal({
            endBlock: block.number + 100,
            transactions: new Honeydew.Transaction[](0)
        });
        bytes32 propId = honeydew.proposalHash(proposal);

        // propose

        vm.prank(proposer);
        vm.expectRevert("Honeydew: not a token holder");
        honeydew.propose(proposal);

        token.mint(proposer, 1);

        vm.prank(proposer);
        vm.expectEmit(true, true, true, true);
        emit ProposalCreated(propId, blockhash(block.number - 1), proposal);
        honeydew.propose(proposal);

        // execute

        bytes memory fact = abi.encode(0);

        vm.expectRevert("Honeydew: too soon");
        honeydew.executeProposal(proposal, fact);

        vm.roll(proposal.endBlock);
        vm.expectRevert("Honeydew: too soon");
        honeydew.executeProposal(proposal, fact);

        vm.roll(proposal.endBlock + honeydew.blocksAllowedForExecution() + 1);
        vm.expectRevert("Honeydew: too late");
        honeydew.executeProposal(proposal, fact);

        vm.roll(proposal.endBlock + 1);
        vm.expectEmit(true, true, true, true);
        emit ProposalExecuted(propId, proposal);
        honeydew.executeProposal(proposal, fact);

        vm.expectRevert("Honeydew: already executed");
        honeydew.executeProposal(proposal, fact);
    }
}


// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "openzeppelin/token/ERC721/IERC721.sol";

interface IVerifier {
    function verify(bytes calldata) external view returns (bool);
}

contract Honeydew {
    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        uint256 gas;
    }

    struct Proposal {
        uint256 endBlock;
        Transaction[] transactions;
    }
    
    event MeloVaultCreated(string indexed name);

    event ProposalCreated(
        bytes32 indexed id,
        bytes32 snapshotBlockHash,
        Proposal indexed proposal
    );

    event ProposalExecuted(bytes32 indexed id, Proposal indexed proposal);

    uint256 public constant blocksAllowedForExecution = 40320; // 7 days
    uint256 public constant maxBlocksInFuture = 172800; // 30 days

    IERC721 public nft;
    IVerifier public verifier;
    string public name;

    /** @dev proposal hash => start block */
    mapping(bytes32 => uint256) public proposals;
    mapping(bytes32 => bool) public executed;

    constructor(string memory _name, address _nft, address _verifier) {
        name = _name;
        nft = IERC721(_nft);
        verifier = IVerifier(_verifier);

        emit MeloVaultCreated(_name);
    }

    function propose(Proposal calldata proposal) external {
        require(nft.balanceOf(msg.sender) > 0, "Honeydew: not a token holder");
        require(
            proposal.endBlock > block.number,
            "Honeydew: end block must be in the future"
        );
        require(
            proposal.endBlock <= block.number + maxBlocksInFuture,
            "Honeydew: end block too far in the future"
        );

        bytes32 id = proposalHash(proposal);
        require(proposals[id] == 0, "Honeydew: proposal already exists");

        bytes32 snapshotBlockHash = blockhash(block.number - 1);

        proposals[id] = block.number;
        emit ProposalCreated(id, snapshotBlockHash, proposal);
    }

    function executeProposal(Proposal calldata proposal, bytes calldata fact)
        external
    {
        require(verifier.verify(fact), "Honeydew: invalid fact");

        bytes32 id = proposalHash(proposal);
        require(proposals[id] != 0, "Honeydew: proposal does not exist");
        require(block.number > proposal.endBlock, "Honeydew: too soon");
        require(
            block.number <= proposal.endBlock + blocksAllowedForExecution,
            "Honeydew: too late"
        );

        require(!executed[id], "Honeydew: already executed");
        executed[id] = true;

        for (uint256 i = 0; i < proposal.transactions.length; i++) {
            Transaction memory transaction = proposal.transactions[i];
            (bool success, ) = transaction.to.call{
                value: transaction.value,
                gas: transaction.gas
            }(transaction.data);
            require(success, "Honeydew: transaction failed");
        }

        emit ProposalExecuted(id, proposal);
    }

    function proposalHash(Proposal calldata proposal)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encode(proposal));
    }

    /// admin ///

    modifier onlySelf() {
        require(msg.sender == address(this), "Honeydew: not self");
        _;
    }

    function setVerifier(address _verifier) external onlySelf {
        verifier = IVerifier(_verifier);
    }
}

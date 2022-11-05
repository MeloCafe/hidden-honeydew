// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "openzeppelin/token/ERC721/IERC721.sol";
import "openzeppelin/token/ERC721/IERC721Receiver.sol";
import "openzeppelin/token/ERC1155/IERC1155Receiver.sol";

import "./IVerifier.sol";

contract MeloVault is IERC1155Receiver, IERC721Receiver {
    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        uint256 gas;
    }

    struct Proposal {
        uint256 endBlock;
        string title;
        string descriptionHash;
        Transaction[] transactions;
    }
    
    event MeloVaultCreated(string name, address token);

    event ProposalCreated(
        bytes32 id,
        bytes32 snapshotBlockHash,
        Proposal proposal
    );

    event ProposalExecuted(bytes32 id, Proposal proposal);

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

        emit MeloVaultCreated(_name, _nft);
    }

    function propose(Proposal calldata proposal) external {
        require(nft.balanceOf(msg.sender) > 0, "MeloVault: not a token holder");
        require(
            proposal.endBlock > block.number,
            "MeloVault: end block must be in the future"
        );
        require(
            proposal.endBlock <= block.number + maxBlocksInFuture,
            "MeloVault: end block too far in the future"
        );

        bytes32 id = proposalHash(proposal);
        require(proposals[id] == 0, "MeloVault: proposal already exists");

        bytes32 snapshotBlockHash = blockhash(block.number - 1);

        proposals[id] = block.number;
        emit ProposalCreated(id, snapshotBlockHash, proposal);
    }

    function executeProposal(Proposal calldata proposal, bytes calldata fact)
        external
    {
        require(verifier.verify(fact), "MeloVault: invalid fact");

        bytes32 id = proposalHash(proposal);
        require(proposals[id] != 0, "MeloVault: proposal does not exist");
        require(block.number > proposal.endBlock, "MeloVault: too soon");
        require(
            block.number <= proposal.endBlock + blocksAllowedForExecution,
            "MeloVault: too late"
        );

        require(!executed[id], "MeloVault: already executed");
        executed[id] = true;

        uint256 len = proposal.transactions.length;
        for (uint256 i; i < len; ) {
            Transaction memory transaction = proposal.transactions[i];
            (bool success, ) = transaction.to.call{
                value: transaction.value,
                gas: transaction.gas
            }(transaction.data);
            require(success, "MeloVault: transaction failed");

            unchecked {
                ++i;
            }
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
        require(msg.sender == address(this), "MeloVault: not self");
        _;
    }

    function setVerifier(address _verifier) external onlySelf {
        verifier = IVerifier(_verifier);
    }

    /// receive ///

    receive() external payable {}

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata 
    ) external pure returns (bytes4){
        return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external pure returns (bytes4) {
        return bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"));
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }

    function supportsInterface(bytes4 interfaceId)
        override
        external
        pure
        returns (bool)
    {
        return
            interfaceId == type(IERC1155Receiver).interfaceId ||
            interfaceId == type(IERC721Receiver).interfaceId;
    }
}

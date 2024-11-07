// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract DAO is ReentrancyGuard, AccessControl {
    //STAKEHOLDER == CONTRIBUTOR && PROPOSER == STAKEHOLDER
    bytes32 private immutable STAKEHOLDER_ROLE = keccak256("STAKEHOLDER");
    bytes32 private immutable PROPOSER_ROLE = keccak256("PROPOSER");

    uint256 immutable MIN_PROPOSER_CONTRIBUTION = 40 ether;
    uint32 immutable MIN_VOTE_DURATION = 10 minutes;

    uint32 totalProposals;
    uint256 public daoBalance;

    mapping(uint256 => ProposalStruct) private raisedProposals;

    mapping(address => uint256[]) private proposerVotes;

    mapping(uint256 => VotedStruct[]) private votedOn;

    mapping(address => uint256) private stakeholders;

    mapping(address => uint256) private proposers;

    struct ProposalStruct {
        uint256 id;
        uint256 amount;
        uint256 duration;
        uint256 upvotes;
        uint256 downvotes;
        string title;
        string description;
        bool passed;
        bool paid;
        address payable beneficiary;
        address originator;
        address executor;
    }

    struct VotedStruct {
        address voter;
        uint256 timestamp;
        bool chosen;
    }

    event Action(
        address indexed initiator,
        bytes32 role,
        string message,
        address indexed beneficiary,
        uint256 amount
    );

    modifier proposerOnly(string memory message) {
        require(hasRole(PROPOSER_ROLE, msg.sender), message);
        _;
    }

    modifier stakeholderOnly(string memory message) {
        require(hasRole(STAKEHOLDER_ROLE, msg.sender), message);
        _;
    }

    function createProposal(
        string memory title,
        string memory description,
        address beneficiary,
        uint amount
    )
        external
        proposerOnly("proposal creation allowed for the proposers only")
    {
        uint32 proposalId = totalProposals++;
        ProposalStruct storage proposal = raisedProposals[proposalId];

        proposal.id = proposalId;
        proposal.originator = payable(msg.sender);
        proposal.title = title;
        proposal.description = description;
        proposal.beneficiary = payable(beneficiary);
        proposal.amount = amount;
        proposal.duration = block.timestamp + MIN_VOTE_DURATION;

        emit Action(
            msg.sender,
            PROPOSER_ROLE,
            "PROPOSAL RAISED",
            beneficiary,
            amount
        );
    }

    function handleVoting(ProposalStruct storage proposal) internal {
        if (proposal.passed || proposal.duration <= block.timestamp) {
            proposal.passed = true;
            revert("proposal duration expired");
        }

        uint256[] memory tempVotes = proposerVotes[msg.sender];

        for (uint256 votes = 0; votes < tempVotes.length; votes++) {
            if (proposal.id == tempVotes[votes]) {
                revert("Double voting not allowed");
            }
        }
    }

    function Vote(
        uint256 proposalId,
        bool chosen
    )
        external
        proposerOnly("Unauthorized access: Proposers only permitted")
        returns (VotedStruct memory)
    {
        ProposalStruct storage proposal = raisedProposals[proposalId];
        handleVoting(proposal);

        if (chosen) proposal.upvotes++;
        else proposal.downvotes++;

        proposerVotes[msg.sender].push(proposal.id);

        votedOn[proposal.id].push(
            VotedStruct(msg.sender, block.timestamp, chosen)
        );
        emit Action(
            msg.sender,
            PROPOSER_ROLE,
            "PROPOSAL VOTE",
            proposal.beneficiary,
            proposal.amount
        );
        return VotedStruct(msg.sender, block.timestamp, chosen);
    }

    function payTo(address to, uint256 amount) internal returns (bool) {
        (bool success, ) = payable(to).call{value: amount}("");
        require(success, "Payment failed");
        return true;
    }

    function payBeneficiary(
        uint256 proposalId
    )
        public
        proposerOnly("Unauthorized: Proposers only")
        nonReentrant
        returns (uint256)
    {
        ProposalStruct storage proposal = raisedProposals[proposalId];
        require(daoBalance >= proposal.amount, "Insufficient fund");

        if (proposal.paid) revert("Payment sent before");

        if (proposal.upvotes <= proposal.downvotes)
            revert("Insufficient votes");

        proposal.paid = true;
        proposal.executor = msg.sender;
        daoBalance -= proposal.amount;

        payTo(proposal.beneficiary, proposal.amount);

        emit Action(
            msg.sender,
            PROPOSER_ROLE,
            "PAYMENT TRANSFERED",
            proposal.beneficiary,
            proposal.amount
        );

        return daoBalance;
    }

    function contribute() public payable {
        require(msg.value > 0 ether, "Contributing zero is not allowed.");
        if (!hasRole(PROPOSER_ROLE, msg.sender)) {
            uint256 totalContribution = stakeholders[msg.sender] + msg.value;

            if (totalContribution >= MIN_PROPOSER_CONTRIBUTION) {
                proposers[msg.sender] = totalContribution;
                _grantRole(PROPOSER_ROLE, msg.sender);
            }
            stakeholders[msg.sender] += msg.value;
            _grantRole(STAKEHOLDER_ROLE, msg.sender);
        } else {
            stakeholders[msg.sender] += msg.value;
            proposers[msg.sender] += msg.value;
        }
        daoBalance += msg.value;

        emit Action(
            msg.sender,
            PROPOSER_ROLE,
            "CONTRIBUTION RECEIVED",
            address(this),
            msg.value
        );
    }

    function getProposals()
        public
        view
        returns (ProposalStruct[] memory props)
    {
        props = new ProposalStruct[](totalProposals);

        for (uint256 i = 0; i < totalProposals; i++) {
            props[i] = raisedProposals[i];
        }
    }
    function getProposal(
        uint256 proposalId
    ) external view returns (ProposalStruct memory) {
        return raisedProposals[proposalId];
    }

    function getVotesOf(
        uint256 proposalId
    ) external view returns (VotedStruct[] memory) {
        return votedOn[proposalId];
    }

    function getProposerVotes()
        external
        view
        proposerOnly("Unauthorized: not a proposer")
        returns (uint256[] memory)
    {
        return proposerVotes[msg.sender];
    }

    function getProposerBalance()
        external
        view
        proposerOnly("Unauthorized: not a proposer")
        returns (uint256)
    {
        return proposers[msg.sender];
    }

    function isProposer() external view returns (bool) {
        return proposers[msg.sender] > 0;
    }

    function getStakeholderBalance()
        external
        view
        stakeholderOnly("Denied: User is not a stakeholder")
        returns (uint256)
    {
        return stakeholders[msg.sender];
    }

    function isStakeholder() external view returns (bool) {
        return stakeholders[msg.sender] > 0;
    }

    function getBalance() external view returns (uint256) {
        return stakeholders[msg.sender];
    }
}

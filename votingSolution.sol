pragma solidity ^0.5.0;

contract Voting {
    bytes32 eligibleVotersMerkleRoot;
    mapping(address => bool) voted;
    uint256 yesVotes;
    uint256 noVotes;

    constructor(bytes32 eligibleVotersMerkleRoot_) public {
        eligibleVotersMerkleRoot = eligibleVotersMerkleRoot_;
    }

    function leafHash(address leaf) private pure returns(bytes32) {
        return keccak256(abi.encodePacked(uint8(0x00), leaf));
    }

    function nodeHash(bytes32 left, bytes32 right) private pure returns(bytes32) {
        return keccak256(abi.encodePacked(uint8(0x01), left, right));
    }

    function vote(uint256 path, bytes32[] memory witnesses, bool myVote) public{
        require(!voted[msg.sender], "already voted");
        
        bytes32 i1;
        bytes32 i2;
        
        i1 = leafHash(msg.sender);
        for(uint i=0; i<witnesses.length; i++)
        {
            if(path % 2 == 0)
                i2 = nodeHash(i1, witnesses[i]);
            else
                i2 = nodeHash(witnesses[i], i1);
                
            path = path/2;
            i1 = i2;
        }
        
        require(i2 == eligibleVotersMerkleRoot, "Bad actor");
            voted[msg.sender] = true;

            if (myVote) yesVotes++;
            else noVotes++;
         
    }       

}

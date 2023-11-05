//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Voting{
    //Structure for the candidate's information
    struct Candidate {
        uint256 id;
        string name;
        uint256 numberOfVotes; //candidate's number of votes
    }
    
    Candidate[] public candidates; //list of candidates

    address public owner; //address of the voting organizer

    //To track all voters 
    mapping (address => bool) public voters;
    //list of voters
    address[] public listOfVoters;

    //Voting Sessions
    uint256 public votingStart; //session start
    uint256 public votingEnd; //session end

    // status of the election
    bool public electionStarted;

    //admin privileges
    modifier onlyOwner() {
        require(msg.sender == owner,"Error: You do not have admin privileges.");
        _;
    }

    //if election is election
    modifier electionOnGoing() {
        require(electionStarted,"Election has not started.");
        _;
    }
    //deployer will be owner of the contract, only admin can deploy the contract hence, admin is owner
    constructor(){
        owner = msg.sender;
    }

    //start election function
    function startElection(string[] memory _candidates, uint256 _votingDuration)public onlyOwner{
        require(electionStarted == false, "Election is currently election.");
        delete candidates;
        resetAllVoterStatus();

        for(uint256 i = 0; i < _candidates.length; i++){
            candidates.push(
                Candidate({id: i,name:_candidates[i],numberOfVotes:0})
            );
        }
        electionStarted = true;
        votingStart = block.timestamp;
        votingEnd = block.timestamp + (_votingDuration * 1 minutes);
    }

    //add candidate function
    function addCandidate(string memory _name)public onlyOwner {
        require(checkElectionPeriod(), "Election Period has ended.");
        candidates.push(
            Candidate({id: candidates.length,name: _name, numberOfVotes:0})
        );
    }
    
    //if voters has voted or not
    function voterStatus(address _voter)public view electionOnGoing returns(bool){
        if(voters[_voter] == true){
            return true;
        }
        return false;
    }
    //vote function
    function voteTo(uint256 _id)public electionOnGoing {
        require(checkElectionPeriod(),"Election Period has ended.");
        require(!voterStatus(msg.sender),"You can only vote once.");
        candidates[_id].numberOfVotes++;
        voters[msg.sender] = true;
        listOfVoters.push(msg.sender);
    }
    //get num of votes
    function retrieveVotes() public view returns(Candidate[] memory){
        return candidates;
    }

    //monitor election time function
    function electionTimer() public view electionOnGoing returns(uint256){
        if(block.timestamp >= votingEnd){
            return 0;
        }
        return (votingEnd - block.timestamp);
    }

    //check if election is still election
    function checkElectionPeriod() public returns(bool) {
        if(electionTimer() > 0){
            return true;
        }
        electionStarted = false;
        return false;
    }
    
    //reset voter status for new election
    function resetAllVoterStatus() public onlyOwner{
        for (uint256 i = 0; i < listOfVoters.length; i++){
            voters[listOfVoters[i]] = false;
        }
        delete listOfVoters;
    }
}
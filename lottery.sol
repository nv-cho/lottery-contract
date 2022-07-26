//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract Lottery {

    address public owner;

    //Minimun fee to play
    uint public minFee;
    
    //List of players
    address[] public players;
    
    //Balance of each player
    mapping(address => uint) public playerBalance;

    constructor(uint _minFee) {
        minFee = _minFee;
        owner = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }

    modifier minFeePay(){
        require(msg.value >= minFee, "The minimun fee is higher");
        _;
    }

    //Principal function to play lottery
    //The reserved word payable makes this contract able to receive eth
    function play() public payable minFeePay{
        players.push(msg.sender);
        playerBalance[msg.sender] += msg.value;
    }

    //Function to know how much ETH the contract have
    function getBalance() public view returns(uint){
        return address(this).balance;
    }

    //Winner of the lottery
    function pickWinner() public onlyOwner{
        uint index = getRandomNumber() % players.length;
        (bool sucess,) = players[index].call{value:getBalance()}("");
        require(sucess, "Pay failed, please try again");
        players = new address[](0);
    }

    function getRandomNumber() public view returns(uint){
        return uint(keccak256(abi.encodePacked(owner, block.timestamp)));
    }
}
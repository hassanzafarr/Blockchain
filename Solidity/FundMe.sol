// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";

contract FundMe { 
    using PriceConverter for uint256;
    
    uint256 public minimunUsd = 50 * 1e18; 

    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    address public owner; 

    constructor(){
        owner = msg.sender;
    }

    function fund() public payable { 
        require(msg.value.getConversionRate() >= minimunUsd, "You need to send more ETH" );
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

   
    function withdraw() public onlyOwner{
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0; 
        }
        //reset the array 
        funders = new address[](0);
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "call failed");
    }

     modifier onlyOwner { 
        require(msg.sender == owner,"Sender is not owner!" );
        _;
    }

}
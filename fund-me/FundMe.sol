// Get funds from users
// Withdraw funds
// Set a minimun funding value in users
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";

error NotOwner();

// intitial transaction cost 876819
// after adding constant keyword transaction cost 856465
contract FundMe {
// adresss of contract deployed 0x6cA672A74Cd7f1ae3c35f98d4EA0010298236480

  using PriceConverter for uint256;

  uint256 public constant MINIMUM_USD = 5e18;

  address[] public funders;
  mapping(address funder => uint256 amountFunded) public addressToAmountFunded;

  address public immutable i_owner;
  constructor() {
    i_owner = msg.sender;
  }

  function fund() public payable {
    // Allow users to send $
    // Have a minimun $ sent
    // 1. How do we send ETH to this contract? A: with payable word at signature
    require(msg.value.getConversionRate() >= MINIMUM_USD, "didn't send enough ETH"); // eth-converter.com 1e18 = 1 ETH = 1000000000000000000 = 1*10**18
    funders.push(msg.sender);
    addressToAmountFunded[msg.sender] = addressToAmountFunded[msg.sender] + msg.value;

    // What is a revert?
    // Undo any actions that I have been done , and send the remaining gas back

  }

  function withdraw() public onlyOwner {
    for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
      address funder = funders[funderIndex];
      addressToAmountFunded[funder] = 0;
    }

    // reset array
    funders = new address[](0);

    // actually withdraw the funds


    // transfer
    // payable(msg.sender).transfer(address(this).balance);

    // send
    // bool sendSuccess =  payable(msg.sender).send(address(this).balance);
    // require(sendSuccess, "Send Failed");
    
    // call
    (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
    require(callSuccess, "Call failed");
  }

  modifier onlyOwner() {
    // require(msg.sender == i_owner, "Sender is not the owner!");
    if (msg.sender != i_owner) {
      revert NotOwner();
    }
    _;
  }

  // What happens if someone sends ETH without calling the fund function?
  receive() external payable {
    fund();
  }
  fallback() external payable {
    fund();
  }
}

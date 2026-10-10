// Get funds from users
// Withdraw funds
// Set a minimun funding value in users
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

error FundMe__NotOwner();

// intitial transaction cost 876819
// after adding constant keyword transaction cost 856465
contract FundMe {
    // adresss of contract deployed 0x6cA672A74Cd7f1ae3c35f98d4EA0010298236480

    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5e18;

    address[] private s_funders;
    mapping(address funder => uint256 amountFunded) private s_addressToAmountFunded;

    address public immutable i_owner;

    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable {
        // Allow users to send $
        // Have a minimun $ sent
        // 1. How do we send ETH to this contract? A: with payable word at signature
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "didn't send enough ETH"); // eth-converter.com 1e18 = 1 ETH = 1000000000000000000 = 1*10**18
        s_addressToAmountFunded[msg.sender] = s_addressToAmountFunded[msg.sender] + msg.value;
        s_funders.push(msg.sender);

        // What is a revert?
        // Undo any actions that I have been done , and send the remaining gas back
    }

    function withdraw() public onlyOwner {
        for (uint256 funderIndex = 0; funderIndex < s_funders.length; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }

        // reset array
        s_funders = new address[](0);

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
            revert FundMe__NotOwner();
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

    function getVersion() public view returns (uint256) {
        return PriceConverter.getVersion(s_priceFeed);
    }

    function getConversionRate(uint256 ethAmount) public view returns (uint256) {
        return PriceConverter.getConversionRate(ethAmount, s_priceFeed);
    }

    /**
     * View / Pure functions (Getters)
     */

    function getAdressToAmountFunded(address fundingAdress) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAdress];
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }
}

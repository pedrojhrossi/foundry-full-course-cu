// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether; // 100000000000000000
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        console.log(fundMe.i_owner());
        console.log(msg.sender);
        // assertEq(fundMe.i_owner(), address(this));
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        console.log("Price Feed Version: ", version);

        if (block.chainid == 11155111) {
            // Sepolia ETH/USD AggregatorV3Interface version is 4
            assertEq(version, 4); // Sepolia
        } else if (block.chainid == 1) {
            // Mainnet ETH/USD AggregatorV3Interface version is 4
            assertEq(version, 6); // Mainnet
        } else {
            // Anvil ETH/USD MockV3Aggregator version is 0
            assertEq(version, 0);
        }
    }

    function testFunFailsWithoutEnoughETH() public {
        vm.expectRevert(); //the next line should revert
        fundMe.fund(); //send 0 value
    }

    function testFundUpdatesFundedDataStructured() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        uint256 amountFunded = fundMe.getAdressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testGetConversionRate() public view {
        uint256 ethAmount = 1 ether;
        uint256 ethAmountInUSD = fundMe.getConversionRate(ethAmount);

        assertGt(ethAmountInUSD, 0);
    }
}

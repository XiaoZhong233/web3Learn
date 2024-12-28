// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";


contract Fundme{
    AggregatorV3Interface internal dataFeed;

    mapping (address => uint256) internal fundersToAmount;

    uint256 MINIMUN_VALUE = 1 * 10 ** 18;

    /**
     * Network: Sepolia
     * Aggregator: ETH/USD
     * Address: 0x694AA1769357215DE4FAC081bf1f309aDC325306
     */
    constructor() {
        dataFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
    }

    function getChainlinkDataFeedLatestAnswer() public view returns (int) {
        // prettier-ignore
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return answer;
    }

    function fund()external payable {
        require(convertEthToUSD(msg.value) >= MINIMUN_VALUE);
        fundersToAmount[msg.sender] = msg.value;
    }

    function convertEthToUSD(uint256 amountCount) internal view returns (uint){
        return amountCount * uint(getChainlinkDataFeedLatestAnswer()) / 10**8;
    }
}
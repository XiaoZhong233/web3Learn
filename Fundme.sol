// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//收款
//记录投资人并查看
//在锁定期内，达到目标值，生产商可以提款
//在锁定期内，没有达到目标值，投资人在锁定期以后退款
contract Fundme{
    AggregatorV3Interface internal dataFeed;

    mapping (address => uint256) private  fundersToAmount;

    uint256 MINIMUN_VALUE = 1 * 10 ** 18;

    uint constant TARGET = 10 * 10 ** 18;

    address public owner;

    uint256 deploymentTimestamp;
    uint256 lockTime; //second

    address erc20Addr;

    bool public getFundSuccess = false;

    /**
     * Network: Sepolia
     * Aggregator: ETH/USD
     * Address: 0x694AA1769357215DE4FAC081bf1f309aDC325306
     */
    constructor(uint256 _lockTime) {
        dataFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        owner = msg.sender;
        deploymentTimestamp = block.timestamp;
        lockTime = _lockTime;
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
        require(block.timestamp < deploymentTimestamp+lockTime, "windows is closed");
        fundersToAmount[msg.sender] = msg.value;
    }

    function convertEthToUSD(uint256 amountCount) internal view returns (uint){
        return amountCount * uint(getChainlinkDataFeedLatestAnswer()) / 10**8;
    }

    //众筹者提取资产
    function getFund() external windowsClosed onlyOwner{
        require(convertEthToUSD(address(this).balance) >= TARGET, "Target is not reached");
        // require(msg.sender == owner, "this function can only be called by owner");
        // require(block.timestamp >= deploymentTimestamp+lockTime, "windows is not closed");

        //transfer: 如果交易失败，则交易会回滚，但是gas不会
        // payable(msg.sender).transfer(address(this).balance);
        //send: 会有返回值 return true false
        // bool success = payable(msg.sender).send(address(this).balance);
        // require(success, "tx failed");
        //call evm推荐方法 可以获取到函数的返回值和交易结果
        bool success;
        (success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "tx failed");
        fundersToAmount[msg.sender] = 0;
        getFundSuccess = true;
    }

    //投资人退款
    function refund() external windowsClosed{
        require(convertEthToUSD(address(this).balance) < TARGET, "Target is reached");
        uint256 amount = fundersToAmount[msg.sender];
        require(amount>0, "there is no fund for you");
        //最好是先清空余额 再转账
        fundersToAmount[msg.sender] = 0;
        bool success;
        (success, ) = payable(msg.sender).call{value: amount}("");
        if(!success){
            fundersToAmount[msg.sender] = amount;
        }
        require(success, "tx failed");
    }


    //合约所有权转移
    function transferOwnership(address newOwner) public {
        require(msg.sender == owner, "this function can only be called by owner");
        owner = newOwner;
    }

    //设置该众筹合约的erc20通证合约地址
    function setERC20Addr(address _erc20Addr) public onlyOwner {
        erc20Addr = _erc20Addr;
    }

    //设置某个地址所拥有的token数量
    function setFunderToAmount(address funderAddr, uint256 amount) external {
        require(msg.sender == erc20Addr, "You dont have permission to call this function");
        fundersToAmount[funderAddr] = amount;
    }

    function queryFundersToAmount(address funderAddr) public view returns(uint256){
        return fundersToAmount[funderAddr];
    }

    modifier windowsClosed(){
        require(block.timestamp >= deploymentTimestamp+lockTime, "windows is not closed");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "this function can only be called by owner");
        _;
    }
}
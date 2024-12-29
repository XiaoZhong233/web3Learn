// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FundToken{
    // 1. 通证名称
    // 2. 通证简称
    // 3. 通证发行数量
    // 4. owner地址
    // 5. balance

    // mint: 铸造通证、获取通证
    // transfer: 交易通证
    // balanceOf: 查看某个地址的通证数量

    string public tokenName;
    string public tokenSymbol;
    uint256 public totalSupply;
    address public owner;
    mapping (address => uint256) public balances;

    constructor(string memory _tokenName, string memory _tokebSymbol){
        tokenName = _tokenName;
        tokenSymbol = _tokebSymbol;
        owner = msg.sender;
    }

    //铸造通证
    function mint(uint256 amountToMint) public {
        balances[msg.sender] += amountToMint;
        totalSupply += amountToMint;
    }

    //交易通证
    function transfer(address payee, uint256 amount) public {
        require(balances[msg.sender] >= amount, "You don have enough balance to transfer");
        balances[msg.sender] -= amount;
        balances[payee] += amount;
    }

    function balanceOf(address addr) public view returns (uint256){
        return balances[addr];
    }
}
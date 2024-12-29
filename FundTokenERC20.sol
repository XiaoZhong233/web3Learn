// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Fundme} from "./Fundme.sol";
//1. 让Fundme的参与者，基于mapping获取到相应的通证
//2. 参与者可以transfer通证
//3. 使用完成后，burn掉通证

contract FundTokenERC20 is ERC20{
    // mapping (address => uint256) internal fundersToAmount;

    Fundme fundme;

    constructor(address fundmeAddr) ERC20("FoxToken", "FT"){
        fundme = Fundme(fundmeAddr);
        fundme.setERC20Addr(address(this));
    }

    //铸造
    function mint(uint256 amountToMint) public {
        require(fundme.queryFundersToAmount(msg.sender) >= amountToMint, "You can not mint so much tokens");
        require(fundme.getFundSuccess(), "Fundme is not complted yet");
        _mint(msg.sender, amountToMint);
        fundme.setFunderToAmount(msg.sender, fundme.queryFundersToAmount(msg.sender) - amountToMint);
    }

    //兑换通证、并burn
    function claim(uint256 amountToClaim) public {
        // complate claim
        require(balanceOf(msg.sender) >= amountToClaim, "You dont have enough ERC20 tokens to claim.");
        require(fundme.getFundSuccess(), "Fundme is not complted yet");
        //to add 
        // burn tokens
        _burn(msg.sender, amountToClaim);
    }

} 
// Realized Volatility.  Takes data from price feeds and computes the 
// the realized Volatility from the last 30 days.  
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

// my stats library for 64x64 bit fixed point
import {ql} from "https://github.com/pbharrin/bc-quant/blob/main/ql.sol";

contract PriceFeed{
    int128 public currentPrice;
}

contract RealizedVol{

    int128 public vol; // the current volatility (the output)
    uint256 public timeForUpdate = 1601609551;
    uint256 updateDelta = 60; // 86400;  // time delta in seconds until next update is allowed
    int128 prevPrice;
    int128[] returnsData;
    uint8 public bufferPos = 0; // buffer position 
    address approvedFeed = 0x51BfE6949fD75Fbf806C9Aa3Ac4af4a1EF64A382; // approved feeds
    address creator; 
    
    string public debugMsg = 'not updated';
    
    constructor() public {
        creator = msg.sender;
    }
    
    function setApprovedFeed(address _feed) external {
        require(creator == msg.sender);
        approvedFeed = _feed;
    }
    
    // price feeds will trigger this
    function poke() external{
        //check if it is time for an update
        if (now > timeForUpdate){
            update();
        }
    }
    
    function updatePriceBuffer() internal{
        // get price from feed TODO: make this multiple feeds
        PriceFeed pf = PriceFeed(approvedFeed);
        int128 currPrice = pf.currentPrice();  
        
        // compute returns from price 
        if (prevPrice == 0 && returnsData.length == 0){  // cold start
            debugMsg = 'update ran - cold start';
        } else {
            debugMsg = 'update ran - normal';
            // compute return (curr - prevPrice)/prevPrice
            int128 ret = ql.pct_change(currPrice, prevPrice);
            
            if (returnsData.length < 30){
                returnsData.push(ret);
            } else {
                returnsData[bufferPos] = ret;
            }

            // update buffer position
            bufferPos++; 
            if (bufferPos > 29){
                bufferPos = 0;
            }
        }
        prevPrice = currPrice; 
    }
    
    // debug function
    function getBuffer(uint256 i) external view returns(int128){
        return returnsData[i];
    }
    
    // computes the new volatility, and updates timeForUpdate
    function update() internal{
        
        // get prices from approved feeds
        updatePriceBuffer();
        
        // compute volatility only if we have enough data points
        if (returnsData.length > 9){  
            vol = ql.std(returnsData);
        }
        
        // update timeForUpdate
        timeForUpdate += updateDelta;
    }
}


// Realized Volatility.  Takes data from price feeds and computes the 
// the realized Volatility from the last 30 days.  
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

// ABDK's fixed point library, has average, sqrt, power, etc. 
import {ABDKMath64x64} from "https://github.com/abdk-consulting/abdk-libraries-solidity/blob/master/ABDKMath64x64.sol";


contract PriceFeed{
    int128 public currentPrice;
}

// TODO: test approvedFeed setable by creator only
// TODO: extract out std() calculation to a library. 

contract RealizedVol{
    using ABDKMath64x64 for int128;
    
    int128 public vol; // the current volatility (the output)
    uint256 public timeForUpdate = 1601609551;
    uint256 updateDelta = 60; // 86400;  // time delta in seconds until next update is allowed
    int128 prevPrice;
    int128[] returnsData;
    uint8 bufferSize = 0;
    uint8 public bufferPos = 0; // buffer position 
    address approvedFeed = 0x51BfE6949fD75Fbf806C9Aa3Ac4af4a1EF64A382; // approved feeds
    address creator; 
    
    string public debugMsg = 'not updated';
    
    function std(int128[] memory buff) internal pure returns (int128) {  // TODO: move this to library
        // compute mean of buffer 
        int128 accum = 0;
        for (uint i=0; i<buff.length; i++){
            accum = ABDKMath64x64.add(accum, buff[i]);
        }
        // divide 
        int128 denom = int128(buff.length) << 64;
        int128 bufferMean = ABDKMath64x64.div(accum, denom);
        
        // compute dispersion from mean
        accum = 0;
        int128 delta;
        int128 sqDispersion;
        for (uint i=0; i<buff.length; i++){
            delta = ABDKMath64x64.sub(bufferMean, buff[i]);
            sqDispersion = ABDKMath64x64.mul(delta, delta);
            accum = ABDKMath64x64.add(accum, sqDispersion);
        }
        // lastly divide the sum sqDispersion by the number of points
        return ABDKMath64x64.sqrt(ABDKMath64x64.div(accum, denom));  //std
    }
    
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
        if (prevPrice == 0 && bufferSize == 0){  // cold start
            debugMsg = 'update ran - cold start';
        } else {
            debugMsg = 'update ran - normal';
            // compute return (curr - prevPrice)/prevPrice
            int128 delta = ABDKMath64x64.sub(currPrice, prevPrice);
            int128 ret = ABDKMath64x64.div(delta, prevPrice);
            
            if (bufferSize < 30){
                bufferSize++;
                returnsData.push(ret);
            } else {
                returnsData[bufferPos] = ret;
            }

            // update buffer
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
        if (bufferSize > 9){  
            vol = std(returnsData);
        }
        
        // update timeForUpdate
        timeForUpdate += updateDelta;
    }
}


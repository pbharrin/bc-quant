// SPDX-License-Identifier: BSD-4-Clause
/*
 * ql Math 64.64 Smart Contract Library.  Copyright © 2020 by Peter Harrington.
 * Author: Peter Harrington <peter.b.harrington@gmail.com>
 */
pragma solidity ^0.5.0 || ^0.6.0 || ^0.7.0;

// ABDK's fixed point library, has average, sqrt, power, etc. 
import {ABDKMath64x64} from "https://github.com/abdk-consulting/abdk-libraries-solidity/blob/master/ABDKMath64x64.sol";


/**
 * Smart contract library of statistical functions in 64x64 bit fixed point.
 * 
 */
library ql {
    
    // standard deviation
    function std(int128[] memory buff) internal pure returns (int128) {

        int128 bufferMean = mean(buff);
        
        // compute dispersion from mean
        int128 accum = 0;
        int128 delta;
        int128 sqDispersion;
        for (uint i=0; i<buff.length; i++){
            delta = ABDKMath64x64.sub(bufferMean, buff[i]);
            sqDispersion = ABDKMath64x64.mul(delta, delta);
            accum = ABDKMath64x64.add(accum, sqDispersion);
        }
        // lastly divide the sum sqDispersion by the number of points
        int128 denom = int128(buff.length) << 64;
        return ABDKMath64x64.sqrt(ABDKMath64x64.div(accum, denom));  //std
    }

    // (a - b)/b 
    function pct_change(int128 a, int128 b) internal pure returns (int128) {
        int128 delta = ABDKMath64x64.sub(a, b);
        return ABDKMath64x64.div(delta, b);
    }
    
    // mean of an array 
    function mean(int128[] memory buff) internal pure returns (int128) { 
        // compute sum of buffer 
        int128 accum = 0;
        for (uint i=0; i<buff.length; i++){
            accum = ABDKMath64x64.add(accum, buff[i]);
        }
        // divide 
        int128 denom = int128(buff.length) << 64;
        return ABDKMath64x64.div(accum, denom);
    }
}

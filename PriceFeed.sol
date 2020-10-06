
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

contract PriceFeed {
    int128 public currentPrice;  // 64x64 fixed point
    
    function setPrice(int128 _price) public {
        currentPrice = _price;
    }
}

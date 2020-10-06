
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

interface RealizedVol {
    function poke() external;
}

contract PriceFeed {
    int128 public currentPrice;  // 64x64 fixed point
    
    function setPrice(int128 _price, RealizedVol _rvol) public {
        currentPrice = _price;
        _rvol.poke(); 
    }
}


// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

interface RealizedVol {
    function poke() external;
}

contract PriceFeed {
    int128 public currentPrice;  // 64x64 fixed point
    address creator;
    
    constructor() public {
        creator = msg.sender;
    }
    
    function setPrice(int128 _price, RealizedVol _rvol) public {
        require(creator == msg.sender);
        currentPrice = _price;
        _rvol.poke(); 
    }
}

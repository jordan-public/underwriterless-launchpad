// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "./interfaces/ILaunchpad.sol";

contract Launchpad is ILaunchpad{
    function launchToken(string memory symbol, string memory name, uint256 priceLow, uint256 priceHigh, bool oneWay, uint256 launchAmount, uint256 duration) external returns (address tokenAddress) {
        // !!! TBD
        tokenAddress = address(0x0); // !!! TBD
    }

    function buy(address tokenAddress, uint256 amount) external {
        // !!! TBD
    }

    function sell(address tokenAddress, uint256 amount) external {
        // !!! TBD
    }
}

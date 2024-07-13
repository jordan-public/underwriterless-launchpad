// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

interface ILaunchpad {
    function launchToken(string memory symbol, string memory name, uint256 priceLow, uint256 priceHigh, bool oneWay, uint256 launchAmount, uint256 duration) external returns (address);
    function buy(address tokenAddress, uint256 amount) external;
    function sell(address tokenAddress, uint256 amount) external;
    function lastToken() external view returns (address);
    function finishCampaign(address tokenAddress) external;
}

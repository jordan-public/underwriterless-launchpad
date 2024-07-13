// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "./interfaces/ILaunchpad.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./interfaces/IToken.sol";

contract Launchpad is ILaunchpad{
    address public lastToken;
    address public owner;
    IToken public baseToken;

    constructor(IToken _baseToken) {
        owner = msg.sender;
        baseToken = _baseToken;
    }

    function launchToken(string memory symbol, string memory name, uint256 priceLow, uint256 priceHigh, bool oneWay, uint256 launchAmount, uint256 duration) external returns (address tokenAddress) {
        // !!! TBD
        tokenAddress = address(0x17eE56D300E3A0a6d5Fd9D56197bFfE968096EdB); // !!! TBD
        lastToken = tokenAddress;
    }

    function buy(address tokenAddress, uint256 amount) external {
        // !!! TBD
    }

    function sell(address tokenAddress, uint256 amount) external {
        // !!! TBD
    }

    function finishCampaign(address tokenAddress) external {
        // !!! TBD
    }
}

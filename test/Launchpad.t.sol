// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {Launchpad} from "../src/Launchpad.sol";
import {Token} from "../src/Token.sol";
import {IToken} from "../src/interfaces/IToken.sol";
import {Constants} from "@pancakeswap/v4-core/test/pool-cl/helpers/Constants.sol";

contract LaunchpadTest is Test {
    Launchpad public launchpad;
    IToken public baseToken;

    function setUp() public {
        baseToken = new Token("Wrapped test ETH", "WETH", 1 * 10**6 * 10**18 /* 1M */);
        console.log("baseToken address: %s", address(baseToken));
        launchpad = new Launchpad(baseToken);
    }

    function testLaunchToken() public {
        // /* address tokenAddress =*/ launchpad.launchToken("TEST", "Test", 1 * 2**96, 10 * 2**96, false, 1 * 10**6 * 10**18, 100);
        /* address tokenAddress =*/ launchpad.launchToken("TEST", "Test", Constants.SQRT_RATIO_1_1 / 1000, Constants.SQRT_RATIO_1_1 / 10, false, 1 * 10**6 * 10**18, 100);
    }

    function testBuy() public {
        baseToken.transfer(address(launchpad), 1000 * 10**18);
        // /* address tokenAddress =*/ launchpad.launchToken("TEST", "Test", 1 * 2**96, 10 * 2**96, false, 1 * 10**6 * 10**18, 100);
        address tokenAddress = launchpad.launchToken("TEST", "Test", Constants.SQRT_RATIO_1_1 / 1000, Constants.SQRT_RATIO_1_1 / 10, false, 1 * 10**6 * 10**18, 100);
        launchpad.buy(tokenAddress, 1 * 10**18);
        launchpad.proxyCollect(launchpad.liquidityIdsPerToken(launchpad.lastToken()));
    }

    function testFinishCampaign() public {
        // /* address tokenAddress =*/ launchpad.launchToken("TEST", "Test", 1 * 2**96, 10 * 2**96, false, 1 * 10**6 * 10**18, 100);
        address tokenAddress = launchpad.launchToken("TEST", "Test", Constants.SQRT_RATIO_1_1 / 1000, Constants.SQRT_RATIO_1_1 / 10, false, 1 * 10**6 * 10**18, 100);
        launchpad.finishCampaign(tokenAddress);
    }  
}

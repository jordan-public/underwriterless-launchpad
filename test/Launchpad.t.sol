// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {Launchpad} from "../src/Launchpad.sol";
import {Token} from "../src/Token.sol";
import {IToken} from "../src/interfaces/IToken.sol";

contract LaunchpadTest is Test {
    Launchpad public launchpad;

    function setUp() public {
        IToken baseToken = new Token("Wrapped test ETH", "WETH", 1 * 10**6 * 10**18 /* 1M */);
        launchpad = new Launchpad(baseToken);

    }

    function testSucceed() public {
        assert(true);
    }

}

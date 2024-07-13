// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.26;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/Launchpad.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "../src/Token.sol";

contract Deploy is Script {
    Launchpad public launchpad;

    function run() external {
        vm.startBroadcast();

        console.log("Creator (owner): ", msg.sender);

        IToken baseToken = new Token("Wrapped test ETH", "WETH", 1 * 10**6 * 10**18 /* 1M */);
        console.log("Base token %s deployed: ", baseToken.symbol(), address(baseToken));

        launchpad = new Launchpad(baseToken);
        console.log("Launchpad deployed: ", address(launchpad));
    }
}

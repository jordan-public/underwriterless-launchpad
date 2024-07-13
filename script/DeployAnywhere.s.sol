// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/Launchpad.sol";

contract Deploy is Script {
    Launchpad public launchpad;

    function run() external {
        vm.startBroadcast();

        console.log("Creator (owner): ", msg.sender);
        launchpad = new Launchpad();
        console.log("Launchpad deployed: ", address(launchpad));
    }
}

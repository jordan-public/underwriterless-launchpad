// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/Launchpad.sol";

contract Deploy is Script {
    uint256 constant ETHEREUM_CHAINID = 1; // Mainnet
    uint256 constant ARBITRUM_ONE_CHAINID = 42161; // Arbitrum One Mainnet
    uint256 constant BASE_CHAINID = 8453; // Base Mainnet
    uint256 constant OP_CHAINID = 10; // Optimism Mainnet
    uint256 constant MANTLE_CHAINID = 5000; // Mantle Mainnet

    Launchpad public launchpad;

    function run() external {
        vm.startBroadcast();

        console.log("Creator (owner): ", msg.sender);
        launchpad = new Launchpad();
        console.log("Launchpad deployed: ", address(launchpad));
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import { DeSwapTimelockController } from "../src/DeSwapTimelockController.sol";

contract DeSwapTimelockControllerScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        new DeSwapTimelockController(address(0x7e727520B29773e7F23a8665649197aAf064CeF1));

        vm.stopBroadcast();
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import {DeSwapGovernor} from "../src/DeSwapGovernor.sol";
import {DeSwapToken} from "../src/DeSwapToken.sol";
import {DeSwapTimelockController} from "../src/DeSwapTimelockController.sol";

contract DeSwapGovernorScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        new DeSwapGovernor(
            DeSwapToken(address(0xACA8cC8BC17D7A3e6cB62065F2C79dC66FbBC86C)),
            DeSwapTimelockController(payable(
                address(0x25D30E1Bb90F197FED0eF5D8f097b3F020ff61c1)
            ))
        );

        vm.stopBroadcast();
    }
}

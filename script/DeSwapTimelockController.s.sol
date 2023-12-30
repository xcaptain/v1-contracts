// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import { DeSwapTimelockController } from "../src/DeSwapTimelockController.sol";
import "create3-factory/src/CREATE3Factory.sol";

contract DeSwapTimelockControllerScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        string memory version = vm.envString("VERSION");

        vm.startBroadcast(deployerPrivateKey);
        CREATE3Factory factory = CREATE3Factory(
            0x93FEC2C00BfE902F733B57c5a6CeeD7CD1384AE1
        );

        bytes memory args = abi.encode(
            0x7e727520B29773e7F23a8665649197aAf064CeF1
        );
        bytes memory creationCode = abi.encodePacked(
            vm.getCode("DeSwapTimelockController.sol:DeSwapTimelockController"),
            args
        );

        bytes32 salt = keccak256(abi.encode("DeSwapTimelockController", version));
        factory.deploy(salt, creationCode);

        vm.stopBroadcast();
    }
}

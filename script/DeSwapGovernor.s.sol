// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import {DeSwapGovernor} from "../src/DeSwapGovernor.sol";
import {DeSwapToken} from "../src/DeSwapToken.sol";
import {DeSwapTimelockController} from "../src/DeSwapTimelockController.sol";
import "create3-factory/src/CREATE3Factory.sol";

contract DeSwapGovernorScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        CREATE3Factory factory = CREATE3Factory(
            0x93FEC2C00BfE902F733B57c5a6CeeD7CD1384AE1
        );

        bytes memory args = abi.encode(
            DeSwapToken(0x68C36e8d2fB887e7f06a700Ef89fB7671b49E1bd),
            DeSwapTimelockController(payable(
                0xD686D2c83B86Ed6A9d5A1e817fA5f4c1269deedC
            ))
        );
        bytes memory creationCode = abi.encodePacked(
            vm.getCode("DeSwapGovernor.sol:DeSwapGovernor"),
            args
        );

        bytes32 salt = keccak256(abi.encode("DeSwapGovernor", "v1"));
        factory.deploy(salt, creationCode);

        vm.stopBroadcast();
    }
}

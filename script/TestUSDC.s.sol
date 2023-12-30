// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import {TestUSDC} from "../src/TestUSDC.sol";
import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "create3-factory/src/CREATE3Factory.sol";

contract TestUSDCScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        string memory version = vm.envString("VERSION");

        vm.startBroadcast(deployerPrivateKey);

        CREATE3Factory factory = CREATE3Factory(
            0x93FEC2C00BfE902F733B57c5a6CeeD7CD1384AE1
        );

        bytes memory args = abi.encode();
        bytes memory creationCode = abi.encodePacked(
            vm.getCode("TestUSDC.sol:TestUSDC"),
            args
        );

        bytes32 salt = keccak256(abi.encode("TestUSDC", version));
        factory.deploy(salt, creationCode);

        vm.stopBroadcast();
    }
}

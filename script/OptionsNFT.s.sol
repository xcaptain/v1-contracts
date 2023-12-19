// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import {OptionsNFT} from "../src/OptionsNFT.sol";
import "create3-factory/src/CREATE3Factory.sol";

contract OptionsNFTScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        CREATE3Factory factory = CREATE3Factory(
            0x93FEC2C00BfE902F733B57c5a6CeeD7CD1384AE1
        );

        bytes memory args = abi.encode(
            address(0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9), // WETH
            address(0xFCAE2250864A678155f8F4A08fb557127053E59E), // TESTUSDC
            address(0x25D30E1Bb90F197FED0eF5D8f097b3F020ff61c1), // royalty receiver（DAO treasury/timelock controller）
            "WETH/USDC Options",
            "WETH/USDC"
        );
        bytes memory creationCode = abi.encodePacked(
            vm.getCode("OptionsNFT.sol:OptionsNFT"),
            args
        );

        bytes32 salt = keccak256(abi.encode("OptionsNFT", "v1"));
        factory.deploy(salt, creationCode);

        vm.stopBroadcast();
    }
}

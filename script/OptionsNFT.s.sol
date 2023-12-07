// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import {OptionsNFT} from "../src/OptionsNFT.sol";
import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract OptionsNFTScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        new OptionsNFT(
            address(0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9), // WETH
            address(0xFCAE2250864A678155f8F4A08fb557127053E59E), // TESTUSDC
            "WETH/USDC Options",
            "WETH/USDC"
        );

        vm.stopBroadcast();
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import {CallOptionNFT} from "../src/OptionNFT.sol";
import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract OptionNFTScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        new CallOptionNFT(
            address(0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9),
            address(0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9),
            "vault ETH",
            "vETH"
        );

        vm.stopBroadcast();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/governance/TimelockController.sol";

contract DeSwapTimelockController is TimelockController {
    constructor(
        address initialOwner
    )
        TimelockController(
            60,
            new address[](0),
            new address[](0),
            initialOwner
        )
    {}
}

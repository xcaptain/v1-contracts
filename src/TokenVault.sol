//SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {ERC4626} from "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC4626.sol";
import {OptionNFT} from "./OptionNFT.sol";

contract TokenVault is ERC4626 {
    constructor(
        IERC20 _asset,
        string memory _name,
        string memory _symbol
    ) ERC4626(_asset) ERC20(_name, _symbol) {}

    // returns total number of assets
    // function totalAssets() public view override returns (uint256) {
    //     return asset.balanceOf(address(this));
    // }

    function issueNFT(OptionNFT _callee) public payable returns (uint256) {
        // uint256 newItemId = ++currentTokenId;
        // _safeMint(recipient, newItemId);
        // return newItemId;
    }
}

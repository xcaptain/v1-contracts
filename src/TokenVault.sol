//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "solmate/mixins/ERC4626.sol";
import "solmate/tokens/ERC20.sol";

contract TokenVault is ERC4626 {
    // ERC-4626 LIBRARY
    constructor(
        ERC20 _asset,
        string memory _name,
        string memory _symbol
    ) ERC4626(_asset, _name, _symbol) {}

    // returns total number of assets
    function totalAssets() public view override returns (uint256) {
        return asset.balanceOf(address(this));
    }
}

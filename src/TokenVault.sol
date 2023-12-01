//SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {ERC4626} from "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC4626.sol";
import {CallOptionNFT} from "./OptionNFT.sol";

contract TokenVault is ERC4626 {
    // 锁定的资产，一个期权合约里面，每张期权都能锁定一部分资产
    mapping(address => mapping(uint256 => uint256)) public lockedAssets;

    // TODO: 依赖 IERC20 还是 ERC20 ？？
    constructor(
        IERC20 _asset,
        string memory _name,
        string memory _symbol
    ) ERC4626(_asset) ERC20(_name, _symbol) {}

    // function issueNFT(CallOptionNFT _callee) public payable returns (uint256) {
    //     // uint256 newItemId = ++currentTokenId;
    //     // _safeMint(recipient, newItemId);
    //     // return newItemId;
    // }
    function lock(
        uint256 assets,
        address owner,
        uint256 tokenId,
        uint64 maturityDate
    ) public virtual returns (uint256) {
        uint256 maxAssets = maxWithdraw(owner);
        if (assets > maxAssets) {
            revert ERC4626ExceededMaxWithdraw(owner, assets, maxAssets);
        }

        uint256 shares = previewWithdraw(assets);
        _withdraw(_msgSender(), msg.sender, owner, assets, shares);

        return shares;
    }
}

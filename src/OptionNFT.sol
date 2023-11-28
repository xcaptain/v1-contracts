// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "solmate/tokens/ERC721.sol";
import { Owned } from "solmate/auth/Owned.sol";

contract OptionNFT is ERC721, Owned(msg.sender) {
    uint256 public currentTokenId;

    address public channelAddress;

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {}

    function updateChannel(address _channel) public onlyOwner {
        channelAddress = _channel;
    }

    // 确保只有vault能调用xxx
    // vault 扣款成功后，再mint出nft来
    function mintTo() public payable returns (uint256) {
        address recipient = msg.sender;
        uint256 newItemId = ++currentTokenId;
        _safeMint(recipient, newItemId);
        return newItemId;
    }

    function tokenURI(
        uint256 id
    ) public view virtual override returns (string memory) {
        return "TODO: fakejson";
    }
}

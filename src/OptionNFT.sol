// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

contract OptionNFT is ERC721, Ownable {
    uint256 public currentTokenId;

    address public channelAddress;

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) Ownable(msg.sender) {}

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

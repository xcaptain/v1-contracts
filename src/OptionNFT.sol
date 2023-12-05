// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";
import "openzeppelin-contracts/contracts/utils/Base64.sol";
import "./ITokenVault.sol";

// 看涨期权的合约
// TODO: 是否需要Upgradable
contract CallOptionNFT is ERC721 {
    uint256 public currentTokenId; // TODO: uint64 是否够大？

    IERC20 public targetAsset;
    IERC20 public strikeAsset;

    struct Metadata {
        uint256 strikeAssetAmount; // usdt
        uint256 targetAssetAmount; // weth
        uint maturityDate;
        bool exercised;
    }
    mapping(uint256 => Metadata) public tokenMetadata;

    // TODO: 是否要细化错误类型？？？锁定的资产转账失败
    error TransferFailed();

    constructor(
        address _targetAsset,
        address _strikeAsset,
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {
        targetAsset = IERC20(_targetAsset);
        strikeAsset = IERC20(_strikeAsset);
    }

    // 铸造一个看涨期权NFT，属性里包含：
    // maturityDate: 期权到期日
    // strikeAssetAmount: 行权资产
    // strikeAddress: 行权资产（ERC20）地址
    // targetAssetAmount: 标的资产数量，如WETH，vault应该先扣款
    function mint(
        uint maturityDate,
        uint256 strikeAssetAmount,
        uint256 targetAssetAmount
    ) public returns (uint256) {
        require(
            maturityDate > block.timestamp,
            "ERC721: maturityDate must be in the future"
        );
        require(
            strikeAssetAmount > 0,
            "ERC721: strikeAssetAmount must be greater than zero"
        );
        require(
            targetAssetAmount > 0,
            "ERC721: targetAssetAmount must be greater than zero"
        );

        address recipient = msg.sender;
        uint256 newItemId = currentTokenId++;
        _safeMint(recipient, newItemId);

        if (
            !targetAsset.transferFrom(
                msg.sender,
                address(this),
                targetAssetAmount
            )
        ) {
            revert TransferFailed();
        }

        // 保存行权信息，便于未来读取
        tokenMetadata[newItemId] = Metadata({
            strikeAssetAmount: strikeAssetAmount,
            targetAssetAmount: targetAssetAmount,
            maturityDate: maturityDate,
            exercised: false
        });
        return newItemId;
    }

    function isExercised(uint256 tokenId) public view returns (bool) {
        return tokenMetadata[tokenId].exercised;
    }

    // 看涨期权到期日，买家进行行权
    function exercise(uint256 tokenId) public {
        require(
            ownerOf(tokenId) == msg.sender,
            "ERC721: caller is not the owner"
        );
        require(!isExercised(tokenId), "ERC721: token already exercised");

        // 欧式期权只有到期日才能行权
        require(
            block.timestamp >= tokenMetadata[tokenId].maturityDate,
            "ERC721: token not matured yet"
        );
        require(
            block.timestamp <= tokenMetadata[tokenId].maturityDate + 1 days,
            "ERC721: token expired"
        );

        // TODO: 行权资产先转移，确保卖家收到usdt之类的，然后卖家再把标的资产转移过去
        if (
            !strikeAsset.transferFrom(
                msg.sender,
                ownerOf(tokenId),
                tokenMetadata[tokenId].strikeAssetAmount
            )
        ) {
            revert TransferFailed();
        }
        if (
            !targetAsset.transferFrom(
                address(this),
                msg.sender,
                tokenMetadata[tokenId].targetAssetAmount
            )
        ) {
            revert TransferFailed();
        }

        tokenMetadata[tokenId].exercised = true;

        // TODO: burn erc721 token
        _burn(tokenId);
    }

    // 过了行权日，没人行权，卖家赎回锁定的资产
    function redeem(uint256 tokenId) public {
        require(
            ownerOf(tokenId) == msg.sender,
            "ERC721: caller is not the owner"
        );
        require(!isExercised(tokenId), "ERC721: token already exercised");

        // 欧式期权只有到期日才能行权
        require(
            block.timestamp > tokenMetadata[tokenId].maturityDate + 1 days,
            "ERC721: token not expired yet"
        );

        if (
            !targetAsset.transferFrom(
                address(this),
                msg.sender,
                tokenMetadata[tokenId].targetAssetAmount
            )
        ) {
            revert TransferFailed();
        }
        _burn(tokenId);
    }

    function _createTokenURI(
        uint256 tokenId
    ) internal view virtual returns (string memory) {
        string memory attributes = string.concat(
            '[{"trait_type":"maturityDate","value":',
            Strings.toString(tokenMetadata[tokenId].maturityDate),
            ',"display_type":"date"},{"trait_type":"strikeAssetAmount","value":',
            Strings.toString(tokenMetadata[tokenId].strikeAssetAmount),
            ',"display_type":"number"},{"trait_type":"targetAssetAmount","value":',
            Strings.toString(tokenMetadata[tokenId].targetAssetAmount),
            ',"display_type":"number"}]'
        );
        string memory name = string.concat(
            "#OptionNFT ",
            Strings.toString(tokenId)
        );
        string memory image = string.concat(
            '<svg xmlns="http://www.w3.org/2000/svg"><text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">',
            name,
            "</text></svg>"
        );
        string memory image_url = string.concat(
            "data:image/svg+xml;base64,",
            Base64.encode(bytes(image))
        );

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            string.concat(
                                "{",
                                '"name": "',
                                name,
                                '", ',
                                '"image": "',
                                image_url,
                                '", ',
                                '"attributes":',
                                attributes,
                                "}"
                            )
                        )
                    )
                )
            );
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        require(tokenId < currentTokenId, string.concat("ERC721: invalid tokenId, max: ", Strings.toString(tokenId)));
        return _createTokenURI(tokenId);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";
import "openzeppelin-contracts/contracts/utils/Base64.sol";

// 看涨期权的合约
contract OptionsNFT is ERC721Royalty {
    uint64 public currentTokenId;

    ERC20 public baseAsset;
    ERC20 public quoteAsset;

    enum OptionsKind {
        Call,
        Put
    }

    struct Metadata {
        uint256 quoteAssetAmount; // usdc
        uint256 baseAssetAmount; // weth
        uint maturityDate;
        bool exercised;
        address writer; // 期权承约方（看涨期权卖方，看跌期权的买方）
        OptionsKind kind;
    }
    mapping(uint256 => Metadata) public tokenMetadata;

    // TODO: 是否要细化错误类型？？？锁定的资产转账失败
    error TransferFailed();

    // base/quote
    constructor(
        address _baseAsset, // weth
        address _quoteAsset, // usdc
        address _royaltyAddress, // default royalty receiver
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {
        baseAsset = ERC20(_baseAsset);
        quoteAsset = ERC20(_quoteAsset);
        _setDefaultRoyalty(_royaltyAddress, 50); // set default royalty to 0.5%
    }

    // 铸造一个看涨期权NFT，属性里包含：
    // maturityDate: 期权到期日
    // quoteAssetAmount: 行权资产
    // baseAssetAmount: 标的资产数量，如WETH，vault应该先扣款
    function calls(
        uint maturityDate,
        uint256 quoteAssetAmount,
        uint256 baseAssetAmount
    ) public returns (uint256) {
        require(
            maturityDate >= block.timestamp + 1 days,
            "ERC721: maturityDate must be in the future"
        );
        require(
            quoteAssetAmount > 0,
            "ERC721: quoteAssetAmount must be greater than zero"
        );
        require(
            baseAssetAmount > 0,
            "ERC721: baseAssetAmount must be greater than zero"
        );

        address recipient = msg.sender;
        uint64 newItemId = currentTokenId++;
        _safeMint(recipient, newItemId);

        if (
            !baseAsset.transferFrom(msg.sender, address(this), baseAssetAmount)
        ) {
            revert TransferFailed();
        }

        tokenMetadata[newItemId] = Metadata({
            quoteAssetAmount: quoteAssetAmount,
            baseAssetAmount: baseAssetAmount,
            maturityDate: maturityDate,
            exercised: false,
            writer: msg.sender,
            kind: OptionsKind.Call
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

        // 行权资产先转移，确保卖家收到usdt之类的，然后卖家再把标的资产转移过去
        if (
            !quoteAsset.transferFrom(
                msg.sender,
                tokenMetadata[tokenId].writer,
                tokenMetadata[tokenId].quoteAssetAmount
            )
        ) {
            revert TransferFailed();
        }
        if (
            !baseAsset.transferFrom(
                address(this),
                msg.sender,
                tokenMetadata[tokenId].baseAssetAmount
            )
        ) {
            revert TransferFailed();
        }

        tokenMetadata[tokenId].exercised = true;

        _burn(tokenId);
    }

    // 过了行权日，没人行权，卖家赎回锁定的资产
    function redeem(uint256 tokenId) public {
        require(
            tokenMetadata[tokenId].writer == msg.sender,
            "ERC721: caller is not the original owner"
        );
        require(!isExercised(tokenId), "ERC721: token already exercised");

        // 过期不行权，才能赎回
        require(
            block.timestamp > tokenMetadata[tokenId].maturityDate + 1 days,
            "ERC721: token not expired yet"
        );

        if (
            !baseAsset.transferFrom(
                address(this),
                msg.sender,
                tokenMetadata[tokenId].baseAssetAmount
            )
        ) {
            revert TransferFailed();
        }
        _burn(tokenId);
    }

    function _createTokenURI(
        uint256 tokenId
    ) internal view virtual returns (string memory) {
        string memory optionsKindAttr = tokenMetadata[tokenId].kind ==
            OptionsKind.Call
            ? "call"
            : "put";

        string memory attributes = string.concat(
            '[{"trait_type":"maturityDate","value":',
            Strings.toString(tokenMetadata[tokenId].maturityDate),
            ',"display_type":"date"},{"trait_type":"quoteAssetAmount","value":',
            Strings.toString(tokenMetadata[tokenId].quoteAssetAmount),
            ',"display_type":"number"},{"trait_type":"baseAssetAmount","value":',
            Strings.toString(tokenMetadata[tokenId].baseAssetAmount),
            ',"display_type":"number"},',
            '{"trait_type":"optionsKind","value":',
            '"',
            optionsKindAttr,
            '"',
            "}]"
        );
        string memory tokenPairName = string.concat(
            baseAsset.symbol(),
            "/",
            quoteAsset.symbol()
        );
        string memory name = string.concat(
            "#Derswap ",
            tokenPairName,
            " #",
            Strings.toString(tokenId)
        );
        string memory optionsKindUnicodeSymbol = tokenMetadata[tokenId].kind ==
            OptionsKind.Call
            ? unicode"📈"
            : unicode"📉";
        string memory image = string.concat(
            '<svg width="290" height="500" viewBox="0 0 290 500">',
            '<style>text{font-size:12px;fill:#fff}</style><clipPath id="corners"><rect width="290" height="500" rx="42" ry="42"/></clipPath><g clip-path="url(#corners)"><path d="M0 0h290v500H0z"/></g>',
            '<text class="h1" x="30" y="70" font-size="14">',
            optionsKindUnicodeSymbol,
            " ",
            tokenPairName,
            "</text>",
            unicode'<text x="70" y="240" style="font-size:100px">🌻</text>',
            '<text x="30" y="400">ID: ',
            Strings.toString(tokenId),
            "</text>",
            '<text x="30" y="420">',
            baseAsset.symbol(),
            ": ",
            Strings.toString(tokenMetadata[tokenId].baseAssetAmount),
            "</text>",
            '<text x="30" y="440">',
            quoteAsset.symbol(),
            ": ",
            Strings.toString(tokenMetadata[tokenId].quoteAssetAmount),
            "</text>",
            "</svg>"
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
        _requireOwned(tokenId); // ensure token not burned

        return _createTokenURI(tokenId);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {OptionsNFT} from "../src/OptionsNFT.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract OptionsNFTTest is Test {
    OptionsNFT public nft;

    address public weth_address =
        address(0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9);
    address public usdc_address =
        address(0xFCAE2250864A678155f8F4A08fb557127053E59E);
    address public royalty_address =
        address(0x720aC46FdB6da28FA751bc60AfB8094290c2B4b7);

    function setUp() public {
        nft = new OptionsNFT(
            weth_address, // WETH
            usdc_address, // TESTUSDC
            royalty_address,
            "WETH-USDC Options",
            "WETHUSDC"
        );
    }

    function test_weth_mock_transfer() public {
        IERC20 weth = IERC20(weth_address);
        address msg_sender = address(
            0x7e727520B29773e7F23a8665649197aAf064CeF1
        );
        uint256 deposit_weth_amount = 1000000000000000000;

        vm.prank(msg_sender); // mock msg sender
        vm.mockCall(
            weth_address,
            abi.encodeWithSelector(
                weth.transferFrom.selector,
                msg_sender,
                weth_address,
                deposit_weth_amount
            ),
            abi.encode(true)
        ); // 只是mock，不会改变实际的balance
        bool result = weth.transferFrom(
            msg_sender,
            weth_address,
            deposit_weth_amount
        );
        assertEq(result, true);
    }

    function test_contract_Uri() public {
        assertEq(
            nft.contractURI(),
            "data:application/json;utf8,{\"name\": \"Deswap OptionsNFT\",\"description\":\"We are the first decentralized options as NFT trading platform.\",\"image\": \"https://deswap.org/logo.png\",\"external_link\": \"https://deswap.org\"}"
        );
    }

    function test_calls() public {
        uint256 deposit_weth_amount = 1000000000000000000;
        uint256 usdc_amount = 1000000;
        uint maturity_date = 1701820800; // 2023-12-06T00:00:00Z
        uint block_timestamp = 1701734400; // 2023-12-05T00:00:00Z
        address msg_sender = address(
            0x7e727520B29773e7F23a8665649197aAf064CeF1
        );
        vm.warp(block_timestamp); // warp time
        vm.mockCall(
            weth_address,
            abi.encodeWithSelector(
                nft.baseAsset().transferFrom.selector,
                msg_sender,
                address(nft),
                deposit_weth_amount
            ),
            abi.encode(true)
        ); // won't change the real targetAsset balance

        vm.prank(msg_sender); // mock msg sender
        uint256 token_id = nft.calls(
            deposit_weth_amount,
            usdc_amount,
            maturity_date
        );
        assertEq(token_id, 0);
        assertEq(nft.balanceOf(msg_sender), 1);
        assertEq(nft.isExercised(token_id), false);

        // 确保tokenMetadata里的数据正确
        (
            uint256 a,
            uint256 b,
            uint c,
            bool d,
            address e,
            OptionsNFT.OptionsKind f
        ) = nft.tokenMetadata(token_id);
        assertEq(a, usdc_amount);
        assertEq(b, deposit_weth_amount);
        assertEq(c, maturity_date);
        assertEq(d, false);
        assertEq(e, msg_sender);
        assertEq(uint(f), uint(OptionsNFT.OptionsKind.Call));

        // token 0 has the correct tokenURI
        vm.mockCall(
            weth_address,
            abi.encodeWithSelector(nft.baseAsset().symbol.selector),
            abi.encode("WETH")
        );
        vm.mockCall(
            usdc_address,
            abi.encodeWithSelector(nft.quoteAsset().symbol.selector),
            abi.encode("USDC")
        );
        assertEq(
            nft.tokenURI(token_id),
            "data:application/json;base64,eyJuYW1lIjogIiNEZXN3YXAgV0VUSC9VU0RDICMwIiwgImltYWdlIjogImRhdGE6aW1hZ2Uvc3ZnK3htbDtiYXNlNjQsUEhOMlp5QjNhV1IwYUQwaU1qa3dJaUJvWldsbmFIUTlJalV3TUNJZ2RtbGxkMEp2ZUQwaU1DQXdJREk1TUNBMU1EQWlJSGh0Ykc1elBTSm9kSFJ3T2k4dmQzZDNMbmN6TG05eVp5OHlNREF3TDNOMlp5SStQSE4wZVd4bFBuUmxlSFI3Wm05dWRDMXphWHBsT2pFeWNIZzdabWxzYkRvalptWm1mVHd2YzNSNWJHVStQR05zYVhCUVlYUm9JR2xrUFNKamIzSnVaWEp6SWo0OGNtVmpkQ0IzYVdSMGFEMGlNamt3SWlCb1pXbG5hSFE5SWpVd01DSWdjbmc5SWpReUlpQnllVDBpTkRJaUx6NDhMMk5zYVhCUVlYUm9QanhuSUdOc2FYQXRjR0YwYUQwaWRYSnNLQ05qYjNKdVpYSnpLU0krUEhCaGRHZ2daRDBpVFRBZ01HZ3lPVEIyTlRBd1NEQjZJaTgrUEM5blBqeDBaWGgwSUdOc1lYTnpQU0pvTVNJZ2VEMGlNekFpSUhrOUlqY3dJaUJtYjI1MExYTnBlbVU5SWpFMElqN3duNU9JSUZkRlZFZ3ZWVk5FUXp3dmRHVjRkRDQ4ZEdWNGRDQjRQU0kzTUNJZ2VUMGlNalF3SWlCemRIbHNaVDBpWm05dWRDMXphWHBsT2pFd01IQjRJajd3bjR5N1BDOTBaWGgwUGp4MFpYaDBJSGc5SWpNd0lpQjVQU0kwTURBaVBrbEVPaUF3UEM5MFpYaDBQangwWlhoMElIZzlJak13SWlCNVBTSTBNakFpUGxkRlZFZzZJREV3TURBd01EQXdNREF3TURBd01EQXdNREE4TDNSbGVIUStQSFJsZUhRZ2VEMGlNekFpSUhrOUlqUTBNQ0krVlZORVF6b2dNVEF3TURBd01Ed3ZkR1Y0ZEQ0OEwzTjJaejQ9IiwgImF0dHJpYnV0ZXMiOlt7InRyYWl0X3R5cGUiOiJtYXR1cml0eURhdGUiLCJ2YWx1ZSI6MTcwMTgyMDgwMCwiZGlzcGxheV90eXBlIjoiZGF0ZSJ9LHsidHJhaXRfdHlwZSI6InF1b3RlQXNzZXRBbW91bnQiLCJ2YWx1ZSI6MTAwMDAwMCwiZGlzcGxheV90eXBlIjoibnVtYmVyIn0seyJ0cmFpdF90eXBlIjoiYmFzZUFzc2V0QW1vdW50IiwidmFsdWUiOjEwMDAwMDAwMDAwMDAwMDAwMDAsImRpc3BsYXlfdHlwZSI6Im51bWJlciJ9LHsidHJhaXRfdHlwZSI6Im9wdGlvbnNLaW5kIiwidmFsdWUiOiJjYWxsIn0seyJ0cmFpdF90eXBlIjoid3JpdGVyIiwidmFsdWUiOiIweDdlNzI3NTIwYjI5NzczZTdmMjNhODY2NTY0OTE5N2FhZjA2NGNlZjEifV19"
        );

        // make sure token 0 has correct royalty info
        (address royaltyAddress, uint256 royaltyFee) = nft.royaltyInfo(
            token_id,
            1000000000000000000
        );
        assertEq(royaltyAddress, royalty_address);
        assertEq(royaltyFee, 5000000000000000);

        // token 1 not exist
        vm.expectRevert();
        nft.tokenURI(1);
    }

    function test_calls_exercise() public {
        address msg_sender = address(
            0x7e727520B29773e7F23a8665649197aAf064CeF1
        );
        assertEq(nft.balanceOf(msg_sender), 0);

        // do mint
        uint256 deposit_weth_amount = 1000000000000000000;
        uint256 usdc_amount = 1000000;
        uint maturity_date = 1701820800; // 2023-12-06T00:00:00Z
        uint mint_block_timestamp = 1701734400; // 2023-12-05T00:00:00Z
        vm.warp(mint_block_timestamp); // warp time
        vm.mockCall(
            weth_address,
            abi.encodeWithSelector(
                nft.baseAsset().transferFrom.selector,
                msg_sender,
                address(nft),
                deposit_weth_amount
            ),
            abi.encode(true)
        );

        vm.prank(msg_sender); // mock msg sender
        uint256 token_id = nft.calls(
            deposit_weth_amount,
            usdc_amount,
            maturity_date
        );
        assertEq(token_id, 0);
        assertEq(nft.balanceOf(msg_sender), 1);

        // change owner
        address new_owner = address(0xD226eb79Bfa519b51DADB9AA9Eab2E4357170B43);
        vm.prank(msg_sender);
        nft.transferFrom(msg_sender, new_owner, token_id);
        assertEq(nft.balanceOf(msg_sender), 0);
        assertEq(nft.balanceOf(new_owner), 1);
        assertEq(nft.ownerOf(token_id), new_owner);

        // new owner can exercise the token
        // mock usdc transfer success
        vm.mockCall(
            usdc_address,
            abi.encodeWithSelector(
                nft.quoteAsset().transferFrom.selector,
                new_owner,
                address(nft),
                usdc_amount
            ),
            abi.encode(true)
        );

        vm.mockCall(
            usdc_address,
            abi.encodeWithSelector(
                nft.quoteAsset().transferFrom.selector,
                address(nft),
                msg_sender,
                usdc_amount
            ),
            abi.encode(true)
        );

        vm.mockCall(
            weth_address,
            abi.encodeWithSelector(
                nft.baseAsset().transferFrom.selector,
                address(nft),
                new_owner,
                deposit_weth_amount
            ),
            abi.encode(true)
        );

        // do the real exercise
        uint exercise_block_timestamp = 1701820830; // 2023-12-05T00:00:30Z
        vm.warp(exercise_block_timestamp);
        vm.prank(new_owner);
        nft.exercise(token_id);

        // ensure the token is exercised
        (
            uint256 a,
            uint256 b,
            uint c,
            bool d,
            address e,
            OptionsNFT.OptionsKind f
        ) = nft.tokenMetadata(token_id);
        assertEq(a, usdc_amount);
        assertEq(b, deposit_weth_amount);
        assertEq(c, maturity_date);
        assertEq(d, true);
        assertEq(e, msg_sender);
        assertEq(uint(f), uint(OptionsNFT.OptionsKind.Call));

        // after exercised, token is burned
        assertEq(nft.balanceOf(msg_sender), 0);
        assertEq(nft.balanceOf(new_owner), 0);

        // TODO: 也许可以细化一下错误: https://book.getfoundry.sh/cheatcodes/expect-revert
        vm.expectRevert();
        assertEq(nft.ownerOf(token_id), address(0)); // burned token has no owner

        vm.mockCall(
            weth_address,
            abi.encodeWithSelector(nft.baseAsset().symbol.selector),
            abi.encode("WETH")
        );
        vm.mockCall(
            usdc_address,
            abi.encodeWithSelector(nft.quoteAsset().symbol.selector),
            abi.encode("USDC")
        );
        vm.expectRevert();
        nft.tokenURI(0);
    }

    function test_calls_redeem() public {
        address msg_sender = address(
            0x7e727520B29773e7F23a8665649197aAf064CeF1
        );
        assertEq(nft.balanceOf(msg_sender), 0);

        // do mint
        uint256 deposit_weth_amount = 1000000000000000000;
        uint256 usdc_amount = 1000000;
        uint maturity_date = 1701820800; // 2023-12-06T00:00:00Z
        uint mint_block_timestamp = 1701734400; // 2023-12-05T00:00:00Z
        vm.warp(mint_block_timestamp); // warp time
        vm.mockCall(
            weth_address,
            abi.encodeWithSelector(
                nft.baseAsset().transferFrom.selector,
                msg_sender,
                address(nft),
                deposit_weth_amount
            ),
            abi.encode(true)
        );

        vm.prank(msg_sender); // mock msg sender
        uint256 token_id = nft.calls(
            deposit_weth_amount,
            usdc_amount,
            maturity_date
        );
        assertEq(token_id, 0);
        assertEq(nft.balanceOf(msg_sender), 1);

        // change block time, but not reach maturity date
        uint redeem_block_timestamp = 1701820810; // 2023-12-06T00:00:10Z
        vm.warp(redeem_block_timestamp);

        assertEq(nft.ownerOf(token_id), msg_sender);
        vm.prank(msg_sender); // mock msg sender
        vm.expectRevert(); // should revert because not matured
        nft.burn(token_id);

        // change block time, reach maturity date
        redeem_block_timestamp = 1701907210; // 2023-12-07T00:00:10Z

        // mock weth transfer back to msg_sender
        vm.mockCall(
            weth_address,
            abi.encodeWithSelector(
                nft.baseAsset().transferFrom.selector,
                address(nft),
                msg_sender,
                deposit_weth_amount
            ),
            abi.encode(true)
        );

        vm.warp(redeem_block_timestamp);
        vm.prank(msg_sender);
        nft.burn(token_id);

        vm.expectRevert();
        nft.ownerOf(token_id); // token burned after redeemed
    }

    function test_puts() public {
        uint256 weth_amount = 1000000000000000000;
        uint256 usdc_amount = 1000000;
        uint maturity_date = 1701820900; // 2023-12-06T00:00:00Z
        uint block_timestamp = 1701734500; // 2023-12-05T00:00:00Z
        address msg_sender = address(
            0x7e727520B29773e7F23a8665649197aAf064CeF1
        );
        vm.warp(block_timestamp); // warp time
        vm.mockCall(
            usdc_address,
            abi.encodeWithSelector(
                nft.quoteAsset().transferFrom.selector,
                msg_sender,
                address(nft),
                usdc_amount
            ),
            abi.encode(true)
        ); // won't change the real targetAsset balance

        vm.prank(msg_sender); // mock msg sender
        uint256 token_id = nft.puts(weth_amount, usdc_amount, maturity_date);
        assertEq(token_id, 0);
        assertEq(nft.balanceOf(msg_sender), 1);
        assertEq(nft.isExercised(token_id), false);

        // 确保tokenMetadata里的数据正确
        (
            uint256 a,
            uint256 b,
            uint c,
            bool d,
            address e,
            OptionsNFT.OptionsKind f
        ) = nft.tokenMetadata(token_id);
        assertEq(a, usdc_amount);
        assertEq(b, weth_amount);
        assertEq(c, maturity_date);
        assertEq(d, false);
        assertEq(e, msg_sender);
        assertEq(uint(f), uint(OptionsNFT.OptionsKind.Put));

        // token 0 has the correct tokenURI
        vm.mockCall(
            weth_address,
            abi.encodeWithSelector(nft.baseAsset().symbol.selector),
            abi.encode("WETH")
        );
        vm.mockCall(
            usdc_address,
            abi.encodeWithSelector(nft.quoteAsset().symbol.selector),
            abi.encode("USDC")
        );
        assertEq(
            nft.tokenURI(token_id),
            "data:application/json;base64,eyJuYW1lIjogIiNEZXN3YXAgV0VUSC9VU0RDICMwIiwgImltYWdlIjogImRhdGE6aW1hZ2Uvc3ZnK3htbDtiYXNlNjQsUEhOMlp5QjNhV1IwYUQwaU1qa3dJaUJvWldsbmFIUTlJalV3TUNJZ2RtbGxkMEp2ZUQwaU1DQXdJREk1TUNBMU1EQWlJSGh0Ykc1elBTSm9kSFJ3T2k4dmQzZDNMbmN6TG05eVp5OHlNREF3TDNOMlp5SStQSE4wZVd4bFBuUmxlSFI3Wm05dWRDMXphWHBsT2pFeWNIZzdabWxzYkRvalptWm1mVHd2YzNSNWJHVStQR05zYVhCUVlYUm9JR2xrUFNKamIzSnVaWEp6SWo0OGNtVmpkQ0IzYVdSMGFEMGlNamt3SWlCb1pXbG5hSFE5SWpVd01DSWdjbmc5SWpReUlpQnllVDBpTkRJaUx6NDhMMk5zYVhCUVlYUm9QanhuSUdOc2FYQXRjR0YwYUQwaWRYSnNLQ05qYjNKdVpYSnpLU0krUEhCaGRHZ2daRDBpVFRBZ01HZ3lPVEIyTlRBd1NEQjZJaTgrUEM5blBqeDBaWGgwSUdOc1lYTnpQU0pvTVNJZ2VEMGlNekFpSUhrOUlqY3dJaUJtYjI1MExYTnBlbVU5SWpFMElqN3duNU9KSUZkRlZFZ3ZWVk5FUXp3dmRHVjRkRDQ4ZEdWNGRDQjRQU0kzTUNJZ2VUMGlNalF3SWlCemRIbHNaVDBpWm05dWRDMXphWHBsT2pFd01IQjRJajd3bjR5N1BDOTBaWGgwUGp4MFpYaDBJSGc5SWpNd0lpQjVQU0kwTURBaVBrbEVPaUF3UEM5MFpYaDBQangwWlhoMElIZzlJak13SWlCNVBTSTBNakFpUGxkRlZFZzZJREV3TURBd01EQXdNREF3TURBd01EQXdNREE4TDNSbGVIUStQSFJsZUhRZ2VEMGlNekFpSUhrOUlqUTBNQ0krVlZORVF6b2dNVEF3TURBd01Ed3ZkR1Y0ZEQ0OEwzTjJaejQ9IiwgImF0dHJpYnV0ZXMiOlt7InRyYWl0X3R5cGUiOiJtYXR1cml0eURhdGUiLCJ2YWx1ZSI6MTcwMTgyMDkwMCwiZGlzcGxheV90eXBlIjoiZGF0ZSJ9LHsidHJhaXRfdHlwZSI6InF1b3RlQXNzZXRBbW91bnQiLCJ2YWx1ZSI6MTAwMDAwMCwiZGlzcGxheV90eXBlIjoibnVtYmVyIn0seyJ0cmFpdF90eXBlIjoiYmFzZUFzc2V0QW1vdW50IiwidmFsdWUiOjEwMDAwMDAwMDAwMDAwMDAwMDAsImRpc3BsYXlfdHlwZSI6Im51bWJlciJ9LHsidHJhaXRfdHlwZSI6Im9wdGlvbnNLaW5kIiwidmFsdWUiOiJwdXQifSx7InRyYWl0X3R5cGUiOiJ3cml0ZXIiLCJ2YWx1ZSI6IjB4N2U3Mjc1MjBiMjk3NzNlN2YyM2E4NjY1NjQ5MTk3YWFmMDY0Y2VmMSJ9XX0="
        );

        // make sure token 0 has correct royalty info
        (address royaltyAddress, uint256 royaltyFee) = nft.royaltyInfo(
            token_id,
            1000000000000000000
        );
        assertEq(royaltyAddress, royalty_address);
        assertEq(royaltyFee, 5000000000000000);

        // token 1 not exist
        vm.expectRevert();
        nft.tokenURI(1);
    }

    function test_puts_exercise() public {
        address msg_sender = address(
            0x7e727520B29773e7F23a8665649197aAf064CeF1
        );
        assertEq(nft.balanceOf(msg_sender), 0);

        // do mint
        uint256 deposit_weth_amount = 1000000000000000000;
        uint256 usdc_amount = 1000000;
        uint maturity_date = 1701820800; // 2023-12-06T00:00:00Z
        uint mint_block_timestamp = 1701734400; // 2023-12-05T00:00:00Z
        vm.warp(mint_block_timestamp); // warp time
        vm.mockCall(
            usdc_address,
            abi.encodeWithSelector(
                nft.quoteAsset().transferFrom.selector,
                msg_sender,
                address(nft),
                usdc_amount
            ),
            abi.encode(true)
        );

        vm.prank(msg_sender); // mock msg sender
        uint256 token_id = nft.puts(
            deposit_weth_amount,
            usdc_amount,
            maturity_date
        );
        assertEq(token_id, 0);
        assertEq(nft.balanceOf(msg_sender), 1);

        // change owner
        address new_owner = address(0xD226eb79Bfa519b51DADB9AA9Eab2E4357170B43);
        vm.prank(msg_sender);
        nft.transferFrom(msg_sender, new_owner, token_id);
        assertEq(nft.balanceOf(msg_sender), 0);
        assertEq(nft.balanceOf(new_owner), 1);
        assertEq(nft.ownerOf(token_id), new_owner);

        // new owner can exercise the token
        // mock usdc transfer success
        vm.mockCall(
            weth_address,
            abi.encodeWithSelector(
                nft.baseAsset().transferFrom.selector,
                new_owner,
                address(nft),
                deposit_weth_amount
            ),
            abi.encode(true)
        );

        vm.mockCall(
            weth_address,
            abi.encodeWithSelector(
                nft.baseAsset().transferFrom.selector,
                address(nft),
                msg_sender,
                deposit_weth_amount
            ),
            abi.encode(true)
        );

        vm.mockCall(
            usdc_address,
            abi.encodeWithSelector(
                nft.quoteAsset().transferFrom.selector,
                address(nft),
                new_owner,
                usdc_amount
            ),
            abi.encode(true)
        );

        // do the real exercise
        uint exercise_block_timestamp = 1701820830; // 2023-12-05T00:00:30Z
        vm.warp(exercise_block_timestamp);
        vm.prank(new_owner);
        nft.exercise(token_id);

        // ensure the token is exercised
        (
            uint256 a,
            uint256 b,
            uint c,
            bool d,
            address e,
            OptionsNFT.OptionsKind f
        ) = nft.tokenMetadata(token_id);
        assertEq(a, usdc_amount);
        assertEq(b, deposit_weth_amount);
        assertEq(c, maturity_date);
        assertEq(d, true);
        assertEq(e, msg_sender);
        assertEq(uint(f), uint(OptionsNFT.OptionsKind.Put));

        // after exercised, token is burned
        assertEq(nft.balanceOf(msg_sender), 0);
        assertEq(nft.balanceOf(new_owner), 0);

        // TODO: 也许可以细化一下错误: https://book.getfoundry.sh/cheatcodes/expect-revert
        vm.expectRevert();
        assertEq(nft.ownerOf(token_id), address(0)); // burned token has no owner

        vm.mockCall(
            weth_address,
            abi.encodeWithSelector(nft.baseAsset().symbol.selector),
            abi.encode("WETH")
        );
        vm.mockCall(
            usdc_address,
            abi.encodeWithSelector(nft.quoteAsset().symbol.selector),
            abi.encode("USDC")
        );
        vm.expectRevert();
        nft.tokenURI(0);
    }

    function test_puts_redeem() public {
        address msg_sender = address(
            0x7e727520B29773e7F23a8665649197aAf064CeF1
        );
        assertEq(nft.balanceOf(msg_sender), 0);

        // do mint
        uint256 deposit_weth_amount = 1000000000000000000;
        uint256 usdc_amount = 1000000;
        uint maturity_date = 1701820800; // 2023-12-06T00:00:00Z
        uint mint_block_timestamp = 1701734400; // 2023-12-05T00:00:00Z
        vm.warp(mint_block_timestamp); // warp time
        vm.mockCall(
            usdc_address,
            abi.encodeWithSelector(
                nft.quoteAsset().transferFrom.selector,
                msg_sender,
                address(nft),
                usdc_amount
            ),
            abi.encode(true)
        );

        vm.prank(msg_sender); // mock msg sender
        uint256 token_id = nft.puts(
            deposit_weth_amount,
            usdc_amount,
            maturity_date
        );
        assertEq(token_id, 0);
        assertEq(nft.balanceOf(msg_sender), 1);

        // change block time, but not reach maturity date
        uint redeem_block_timestamp = 1701820810; // 2023-12-06T00:00:10Z
        vm.warp(redeem_block_timestamp);

        assertEq(nft.ownerOf(token_id), msg_sender);
        vm.prank(msg_sender); // mock msg sender
        vm.expectRevert(); // should revert because not matured
        nft.burn(token_id);

        // change block time, reach maturity date
        redeem_block_timestamp = 1701907210; // 2023-12-07T00:00:10Z

        // mock weth transfer back to msg_sender
        vm.mockCall(
            usdc_address,
            abi.encodeWithSelector(
                nft.quoteAsset().transferFrom.selector,
                address(nft),
                msg_sender,
                usdc_amount
            ),
            abi.encode(true)
        );

        vm.warp(redeem_block_timestamp);
        vm.prank(msg_sender);
        nft.burn(token_id);

        vm.expectRevert();
        nft.ownerOf(token_id); // token burned after redeemed
    }
}

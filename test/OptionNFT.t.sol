// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {CallOptionNFT} from "../src/OptionNFT.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract CallOptionNFTTest is Test {
    CallOptionNFT public nft;

    address public weth_address =
        address(0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9);
    address public usdc_address =
        address(0xFCAE2250864A678155f8F4A08fb557127053E59E);

    function setUp() public {
        nft = new CallOptionNFT(
            weth_address, // WETH
            usdc_address, // TESTUSDC
            "WETH-USDC Options",
            "WETHUSDC"
        );
    }

    function test_Mint() public {
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
                nft.targetAsset().transferFrom.selector,
                msg_sender,
                address(nft),
                deposit_weth_amount
            ),
            abi.encode(true)
        ); // won't change the real targetAsset balance

        vm.prank(msg_sender); // mock msg sender
        uint256 token_id = nft.mint(
            maturity_date,
            usdc_amount,
            deposit_weth_amount
        );
        assertEq(token_id, 0);
        assertEq(nft.balanceOf(msg_sender), 1);
        assertEq(nft.isExercised(token_id), false);

        // 确保tokenMetadata里的数据正确
        (uint256 a, address e, uint256 b, uint c, bool d) = nft.tokenMetadata(
            token_id
        );
        assertEq(a, usdc_amount);
        assertEq(b, deposit_weth_amount);
        assertEq(c, maturity_date);
        assertEq(d, false);
        assertEq(e, msg_sender);

        // token 0 has the correct tokenURI
        vm.mockCall(
            weth_address,
            abi.encodeWithSelector(
                nft.targetAsset().symbol.selector
            ),
            abi.encode("WETH")
        );
        vm.mockCall(
            usdc_address,
            abi.encodeWithSelector(
                nft.strikeAsset().symbol.selector
            ),
            abi.encode("USDC")
        );
        assertEq(
            nft.tokenURI(token_id),
            "data:application/json;base64,eyJuYW1lIjogIiNEZXJzd2FwIFdFVEgvVVNEQyAjMCIsICJpbWFnZSI6ICJkYXRhOmltYWdlL3N2Zyt4bWw7YmFzZTY0LFBITjJaeUIzYVdSMGFEMGlNamt3SWlCb1pXbG5hSFE5SWpVd01DSWdkbWxsZDBKdmVEMGlNQ0F3SURJNU1DQTFNREFpUGp4emRIbHNaVDUwWlhoMGUyWnZiblF0YzJsNlpUb3hNbkI0TzJacGJHdzZJMlptWm4wOEwzTjBlV3hsUGp4amJHbHdVR0YwYUNCcFpEMGlZMjl5Ym1WeWN5SStQSEpsWTNRZ2QybGtkR2c5SWpJNU1DSWdhR1ZwWjJoMFBTSTFNREFpSUhKNFBTSTBNaUlnY25rOUlqUXlJaTgrUEM5amJHbHdVR0YwYUQ0OFp5QmpiR2x3TFhCaGRHZzlJblZ5YkNnalkyOXlibVZ5Y3lraVBqeHdZWFJvSUdROUlrMHdJREJvTWprd2RqVXdNRWd3ZWlJdlBqd3ZaejQ4ZEdWNGRDQmpiR0Z6Y3owaWFERWlJSGc5SWpNd0lpQjVQU0kzTUNJZ1ptOXVkQzF6YVhwbFBTSXhOQ0krNHBheUlGZEZWRWd2VlZORVF6d3ZkR1Y0ZEQ0OGRHVjRkQ0I0UFNJM01DSWdlVDBpTWpRd0lpQnpkSGxzWlQwaVptOXVkQzF6YVhwbE9qRXdNSEI0SWo3d240eTdQQzkwWlhoMFBqeDBaWGgwSUhnOUlqTXdJaUI1UFNJME1EQWlQa2xFT2lBd1BDOTBaWGgwUGp4MFpYaDBJSGc5SWpNd0lpQjVQU0kwTWpBaVBsZEZWRWc2SURFd01EQXdNREF3TURBd01EQXdNREF3TURBOEwzUmxlSFErUEhSbGVIUWdlRDBpTXpBaUlIazlJalEwTUNJK1ZWTkVRem9nTVRBd01EQXdNRHd2ZEdWNGRENDhMM04yWno0PSIsICJhdHRyaWJ1dGVzIjpbeyJ0cmFpdF90eXBlIjoibWF0dXJpdHlEYXRlIiwidmFsdWUiOjE3MDE4MjA4MDAsImRpc3BsYXlfdHlwZSI6ImRhdGUifSx7InRyYWl0X3R5cGUiOiJzdHJpa2VBc3NldEFtb3VudCIsInZhbHVlIjoxMDAwMDAwLCJkaXNwbGF5X3R5cGUiOiJudW1iZXIifSx7InRyYWl0X3R5cGUiOiJ0YXJnZXRBc3NldEFtb3VudCIsInZhbHVlIjoxMDAwMDAwMDAwMDAwMDAwMDAwLCJkaXNwbGF5X3R5cGUiOiJudW1iZXIifV19"
        );

        // token 1 not exist
        vm.expectRevert();
        nft.tokenURI(1);
    }

    function test_exercise() public {
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
                nft.targetAsset().transferFrom.selector,
                msg_sender,
                address(nft),
                deposit_weth_amount
            ),
            abi.encode(true)
        );

        vm.prank(msg_sender); // mock msg sender
        uint256 token_id = nft.mint(
            maturity_date,
            usdc_amount,
            deposit_weth_amount
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
                nft.strikeAsset().transferFrom.selector,
                new_owner,
                msg_sender,
                usdc_amount
            ),
            abi.encode(true)
        );

        vm.mockCall(
            weth_address,
            abi.encodeWithSelector(
                nft.targetAsset().transferFrom.selector,
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
        (uint256 a, address e, uint256 b, uint c, bool d) = nft.tokenMetadata(
            token_id
        );
        assertEq(a, usdc_amount);
        assertEq(b, deposit_weth_amount);
        assertEq(c, maturity_date);
        assertEq(d, true);
        assertEq(e, msg_sender);

        // after exercised, token is burned
        assertEq(nft.balanceOf(msg_sender), 0);
        assertEq(nft.balanceOf(new_owner), 0);

        // TODO: 也许可以细化一下错误: https://book.getfoundry.sh/cheatcodes/expect-revert
        vm.expectRevert();
        assertEq(nft.ownerOf(token_id), address(0)); // burned token has no owner

        vm.mockCall(
            weth_address,
            abi.encodeWithSelector(
                nft.targetAsset().symbol.selector
            ),
            abi.encode("WETH")
        );
        vm.mockCall(
            usdc_address,
            abi.encodeWithSelector(
                nft.strikeAsset().symbol.selector
            ),
            abi.encode("USDC")
        );
        vm.expectRevert();
        nft.tokenURI(0);
    }

    function test_redeem() public {
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
                nft.targetAsset().transferFrom.selector,
                msg_sender,
                address(nft),
                deposit_weth_amount
            ),
            abi.encode(true)
        );

        vm.prank(msg_sender); // mock msg sender
        uint256 token_id = nft.mint(
            maturity_date,
            usdc_amount,
            deposit_weth_amount
        );
        assertEq(token_id, 0);
        assertEq(nft.balanceOf(msg_sender), 1);

        // change block time, but not reach maturity date
        uint redeem_block_timestamp = 1701820810; // 2023-12-06T00:00:10Z
        vm.warp(redeem_block_timestamp);

        assertEq(nft.ownerOf(token_id), msg_sender);
        vm.prank(msg_sender); // mock msg sender
        vm.expectRevert(); // should revert because not matured
        nft.redeem(token_id);

        // change block time, reach maturity date
        redeem_block_timestamp = 1701907210; // 2023-12-07T00:00:10Z

        // mock weth transfer back to msg_sender
        vm.mockCall(
            weth_address,
            abi.encodeWithSelector(
                nft.targetAsset().transferFrom.selector,
                address(nft),
                msg_sender,
                deposit_weth_amount
            ),
            abi.encode(true)
        );

        vm.warp(redeem_block_timestamp);
        vm.prank(msg_sender);
        nft.redeem(token_id);

        vm.expectRevert();
        nft.ownerOf(token_id); // token burned after redeemed
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
}

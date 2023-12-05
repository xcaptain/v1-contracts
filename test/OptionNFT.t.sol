// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

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
        uint maturity_date = 1000000000;
        address msg_sender = address(
            0x7e727520B29773e7F23a8665649197aAf064CeF1
        );
        vm.prank(msg_sender); // mock msg sender
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
        assertEq(nft.isExercised(token_id), false);

        // 确保tokenMetadata里的数据正确
        (uint256 a, uint256 b, uint c, bool d) = nft.tokenMetadata(token_id);
        assertEq(a, usdc_amount);
        assertEq(b, deposit_weth_amount);
        assertEq(c, maturity_date);
        assertEq(d, false);

        // tokenURI
        assertEq(
            nft.tokenURI(token_id),
            "data:application/json;base64,eyJuYW1lIjogIiNPcHRpb25ORlQgMCIsICJpbWFnZSI6ICJkYXRhOmltYWdlL3N2Zyt4bWw7YmFzZTY0LFBITjJaeUI0Yld4dWN6MGlhSFIwY0RvdkwzZDNkeTUzTXk1dmNtY3ZNakF3TUM5emRtY2lQangwWlhoMElIZzlJalV3SlNJZ2VUMGlOVEFsSWlCamJHRnpjejBpWW1GelpTSWdaRzl0YVc1aGJuUXRZbUZ6Wld4cGJtVTlJbTFwWkdSc1pTSWdkR1Y0ZEMxaGJtTm9iM0k5SW0xcFpHUnNaU0krSTA5d2RHbHZiazVHVkNBd1BDOTBaWGgwUGp3dmMzWm5QZz09IiwgImF0dHJpYnV0ZXMiOlt7InRyYWl0X3R5cGUiOiJtYXR1cml0eURhdGUiLCJ2YWx1ZSI6MTAwMDAwMDAwMCwiZGlzcGxheV90eXBlIjoiZGF0ZSJ9LHsidHJhaXRfdHlwZSI6InN0cmlrZUFzc2V0QW1vdW50IiwidmFsdWUiOjEwMDAwMDAsImRpc3BsYXlfdHlwZSI6Im51bWJlciJ9LHsidHJhaXRfdHlwZSI6InRhcmdldEFzc2V0QW1vdW50IiwidmFsdWUiOjEwMDAwMDAwMDAwMDAwMDAwMDAsImRpc3BsYXlfdHlwZSI6Im51bWJlciJ9XX0="
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
}

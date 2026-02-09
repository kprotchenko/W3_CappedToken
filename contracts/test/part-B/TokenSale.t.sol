// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import { CappedToken } from "../../src/part-A/CappedToken.sol";
import { TokenSale } from "../../src/part-B/TokenSale.sol";

contract TokenSaleTest is Test {
    CappedToken token;
    TokenSale sale;

    address tokenAdmin = payable(address(vm.envAddress("TOKEN_ADMIN")));
    address saleOwner = payable(address(vm.envAddress("TOKEN_SALE_ADMIN")));
    address buyer = payable(address(vm.envAddress("BUYER")));

    function setUp() public {
        vm.startPrank(tokenAdmin);
        token = new CappedToken("CappedToken", "CT", tokenAdmin, 10_000);
        vm.stopPrank();
        vm.startPrank(saleOwner);
        sale = new TokenSale(address(token), saleOwner, 0.0005 ether, 0.001 ether);
        vm.stopPrank();
        vm.startPrank(tokenAdmin);
        token.grantRole(token.MINTER_ROLE(), address(sale));
        vm.stopPrank();
        vm.deal(buyer, 1 ether);
    }

    function testBuyEmitsBuyMintAndUpdatesBalances() public {
        uint256 ethPaid = 0.001 ether;

        // tokensToAdd = msg.value * 10**decimals / buyPrice
        uint256 expected = ethPaid * (10 ** token.decimals()) / sale.sellPrice();
        vm.startPrank(buyer);
        // Expect TokenSale.BuyMint only (tokensInReserve starts at 0, so tokensToTransfer = 0)
        vm.expectEmit(address(sale));
        emit TokenSale.BuyMint(address(0), buyer, expected);


        sale.buy{ value: ethPaid }();
        vm.stopPrank();
        assertEq(sale.accounts(buyer), expected, "TokenSale accounts mapping updated");
        assertEq(token.balanceOf(buyer), expected, "buyer token balance");
        assertEq(token.totalSupply(), expected, "total supply updated");
        assertEq(token.balanceOf(address(sale)), 0, "sale contract token reserve should be 0");
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import {RewardsVault} from "../src/RewardsVault.sol";
import {CommunityToken} from "../src/CommunityToken.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";

contract RewardsVaultTest is Test {
    CommunityToken private communityToken;
    RewardsVault private rewardsVault;
    address payable private community;
    address payable private vaultAdmin;
    address payable private foundationWallet;
    address payable private donation;
    bytes32 public private treasureRole;

    event Donation(address sender, uint256 value);
    event Withdrawal(uint256 amount);

    event RewardsVaultCreated(address indexed vault, address indexed admin, address indexed foundation);

    function setUp() public {
        treasureRole = keccak256("TREASURER_ROLE");
        community = payable(address(vm.envAddress("COMMUNITY")));
        communityToken = new CommunityToken("CommunityTokenTest1", "CTT1", community);

        vaultAdmin = payable(address(vm.envAddress("VAULT_ADMIN")));
        foundationWallet = payable(address(vm.envAddress("FOUNDATION_WALLET")));

        vm.prank(community);
        address rewardsVaultAddr = communityToken.createRewardsVault(vaultAdmin, foundationWallet);
        rewardsVault = RewardsVault(payable(rewardsVaultAddr));

        donation = payable(address(vm.envAddress("DONATION")));
    }

    // donate mints the right token amount and emits Donation.
    function testDonate() public {
        vm.deal(donation, 1 ether); // Sets an address' balance.
        vm.txGasPrice(0); // optional: exact balance math
        uint256 balanceBeforeDonateForRewardsVault = address(rewardsVault).balance;
        uint256 balanceBeforeDonateForDonationAddr = donation.balance;
        uint256 tokenBalanceBeforeDonateForDonationAddr = communityToken.balanceOf(donation);
        vm.expectEmit(address(rewardsVault));
        emit Donation(donation, 1 wei); // expected Donation
        vm.prank(donation); // next call is from donation (has to be right next to function call)
        rewardsVault.donate{value: 1 wei}();
        uint256 balanceAfterDonateForRewardsVault = address(rewardsVault).balance;
        uint256 balanceAfterDonateForDonationAddr = donation.balance;
        uint256 tokenBalanceAfterDonateForDonationAddr = communityToken.balanceOf(donation);
        assertEq(balanceAfterDonateForRewardsVault - balanceBeforeDonateForRewardsVault, 1 wei);
        assertEq(balanceBeforeDonateForDonationAddr - balanceAfterDonateForDonationAddr, 1 wei);
        assertEq(tokenBalanceAfterDonateForDonationAddr - tokenBalanceBeforeDonateForDonationAddr, 100);
    }

    // withdraw works for TREASURER_ROLE and reverts for others.
    function testWithdrawWithoutTheRightAccess() public {

        vm.deal(address(rewardsVault), 1 wei);
        vm.txGasPrice(0); // optional: exact balance math
        vm.prank(vaultAdmin);
        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, vaultAdmin, treasureRole)
        );
        rewardsVault.withdraw(1 wei);
    }

    function testWithdrawWithoutTheRightAccess() public {
        treasureRole = keccak256("TREASURER_ROLE");
        vm.deal(address(rewardsVault), 1 wei);
        vm.txGasPrice(0); // optional: exact balance math
        vm.prank(vaultAdmin);
        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, vaultAdmin, treasureRole)
        );
        rewardsVault.withdraw(1 wei);
    }

    // When pause() is active, both donate and withdraw revert.
}

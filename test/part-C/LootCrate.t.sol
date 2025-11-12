// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import { Test } from "forge-std/Test.sol";
import { LootCrate } from "../../src/part-C/LootCrate.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

// Todo: Part-C: openCrate reverts with wrong ETH, pause blocks openCrate
contract LootCrateTest is Test {
    LootCrate public crate;
    string public baseURI;
    address public crateAdmin;
    address public cratePauser;
    address payable public crateGetter;

    event CratesOpened(address getter, uint256 count, uint256 price);

    /**
 * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    function setUp() public {
        vm.txGasPrice(0); // exact balance math
        baseURI = vm.envString("BASE_URI");
        crateAdmin = payable(address(vm.envAddress("CRATE_ADMIN")));
        cratePauser = payable(address(vm.envAddress("PAUSER")));
        crateGetter = payable(address(vm.envAddress("CRATE_GETTER")));
        vm.startPrank(crateAdmin);
        crate = new LootCrate(baseURI);
        crate.grantRole(crate.PAUSER_ROLE(), cratePauser);
        vm.stopPrank();
    }

    function testPausedOpenCrate() public {
        vm.startPrank(cratePauser);
        vm.expectEmit();
        emit Paused(cratePauser);
        crate.pause();
        vm.stopPrank();
        uint256 count = 3;
        uint256 payment = crate.price()*count;
        vm.deal(crateGetter, payment);
        vm.startPrank(crateGetter);
        vm.expectRevert(bytes("EnforcedPause()"));
        crate.openCrate{ value: payment }(count);
        vm.stopPrank();
    }
}

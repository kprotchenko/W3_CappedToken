// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import { Test } from "forge-std/Test.sol";
import { MetaverseItem } from "../../src/part-B/MetaverseItem.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MetaverseItemTest is Test {
    MetaverseItem public metaverseItem;
    string public baseURI;

    address public itemAdmin;

    function setUp() public {
        baseURI = vm.envString("BASE_URI");
        itemAdmin = payable(address(vm.envAddress("ITEM_ADMIN")));
        metaverseItem = new MetaverseItem("MetaverseItem1", "MI1", itemAdmin);
    }
    //mint increments id & respects cap tokenURI
    //returns expected IPFS link
    // ipfs://CID/
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import { Test } from "forge-std/Test.sol";
import { MetaverseItem } from "../../src/part-B/MetaverseItem.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MetaverseItemTest is Test {
    MetaverseItem public metaverseItem;

    function setUp() public {
    }
    //mint increments id & respects captokenURI
    //returns expected IPFS link

}

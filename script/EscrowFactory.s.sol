// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {Script} from "forge-std/Script.sol";
import {EscrowFactory} from "../src/EscrowFactory.sol";

contract EscrowFactoryScript is Script {
    EscrowFactory public factory;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        factory = new EscrowFactory(0xa0Ee7A142d267C1f36714E4a8F75612F20a79720);

        vm.stopBroadcast();
    }
}

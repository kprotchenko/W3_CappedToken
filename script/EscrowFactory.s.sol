// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {Script} from "forge-std/Script.sol";
import {EscrowFactory} from "../src/EscrowFactory.sol";

contract EscrowFactoryScript is Script {
    EscrowFactory public factory;

    function setUp() public {}

    function run() public {
        uint256 pk;
        address payable feeRecipient;
        if (block.chainid == 31337) {
            pk = uint256(vm.envBytes32("PK_FOR_ANVIL"));
            feeRecipient = payable(vm.envAddress("FEE_RECIPIENT_ADDR_ANVIL"));
        } else if (block.chainid == 11155111) {
            pk = uint256(vm.envBytes32("PK_FOR_SEPOLIA"));
            feeRecipient = payable(vm.envAddress("FEE_RECIPIENT_ADDR_SEPOLIA"));
        } else {
            revert("unsupported chain");
        }

        vm.startBroadcast(pk);
        factory = new EscrowFactory(feeRecipient);
        vm.stopBroadcast();
    }
}

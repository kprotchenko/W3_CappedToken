// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {CommunityToken} from "../src/CommunityToken.sol";

// RV-1: Inherit AccessControl, Pausable, ReentrancyGuard.
contract RewardsVault is AccessControl, Pausable, ReentrancyGuard {
    // bytes32 public constant PAUSER_ROLE = keccak256(abi.encodePacked("PAUSER_ROLE"));
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant TREASURER_ROLE = keccak256("TREASURER_ROLE");
    address public foundationWallet;

    event Donation(address sender, uint256 value);
    event Withdrawal(uint256 amount);

    // RV-2: Constructor (CommunityToken token, address admin, address foundationWallet)
    // grants DEFAULT_ADMIN_ROLE & PAUSER_ROLE to admin
    // grants MINTER_ROLE on token to address(this) so vault can mint.
    constructor(CommunityToken token, address admin, address _foundationWallet) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(PAUSER_ROLE, admin);
        token.grantMinteRole(address(this));
        token.grantRole(token.MINTER_ROLE(), address(this));
        foundationWallet = _foundationWallet;
    }

    bytes32 public constant AUDITOR_ROLE = PAUSER_ROLE;

    // RV-4: Public constants
    uint256 public constant RATE = 1e18 / 0.01 ether;

    // Todo: RV-5: donate() payable nonReentrant → mints msg.value * RATE / 1e18 tokens to sender; emits Donation(sender, value).
    function donate() external payable nonReentrant {
        // Todo: need to finish the work on donate() function
        emit Donation(msg.sender, msg.value);
    }

    // Todo: RV-6: withdraw(uint256 amount) — onlyRole(TREASURER_ROLE) nonReentrant; sends ETH to foundationWallet; emits Withdrawal(amount).
    function withdraw(uint256 amount) external onlyRole(TREASURER_ROLE) nonReentrant {
        // Todo: need to finish the work on withdraw(...) function
        emit Withdrawal(amount);
    }

    // Todo: RV-7: setFoundationWallet(address) — onlyRole(DEFAULT_ADMIN_ROLE); reverts on zero address.

    // RV-8: pause() / unpause() — onlyRole(PAUSER_ROLE) (or AUDITOR_ROLE).
    function pause() external onlyRole(PAUSER_ROLE) onlyRole(AUDITOR_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(PAUSER_ROLE) onlyRole(AUDITOR_ROLE) {
        _unpause();
    }

    // Todo: RV-9: receive() and fallback both revert() to block accidental transfers.

    // Todo: RV-10: Use low-level call for ETH transfer and custom errors for gas savings.
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;
import {EscrowFactory} from "../src/EscrowFactory.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
// import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
contract SimpleEscrow is ReentrancyGuard {
    event Funded(uint256 amount);
    event Released(address payee, uint256 amount);
    // E-1 Constructor args: (factory, depositor, payee, deadline, feePercent); mark as immutable where possible.
    address immutable depositor;
    address payable immutable payee;
    uint immutable deadline;
    uint immutable feePercent;
    bool private fundedAlready;
    EscrowFactory internal factory;

    // E-1 Constructor args: (factory, depositor, payee, deadline, feePercent); mark as immutable where possible.
    constructor(EscrowFactory _factory, address _depositor, address payable _payee, uint _deadline, uint _feePercent){
        factory = _factory;
        depositor = _depositor;
        payee = _payee;
        deadline = _deadline;
        feePercent = _feePercent;
        fundedAlready = false;
    }

    // E-2 fund() is payable, can be called once by depositor. Emit Funded(amount)
    function fund() public payable {
        require(depositor == msg.sender, "Only depositor can call this function.");
        require(!fundedAlready, "Function can only be called once");
        fundedAlready = true;
        emit Funded(msg.value);
    }

    function hashRelease(uint256 amount) public view returns (bytes32) {
        bytes32 messageHash = keccak256(abi.encodePacked("RELEASE", address(this), amount));
        //Todo: find out why the video tells me to do this additional part
        return messageHash;
    }

    function ethHashRelease(bytes32 messageHash) private pure returns (bytes32) {
        //Todo: find out why the video tells me to do this additional part
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32",messageHash));
    }

    function _split(bytes memory _sig) internal pure returns (bytes32 r, bytes32 s, uint8 v){
        require(_sig.length == 65, "invalid signature length");
        assembly {
            r := mload(add(_sig, 32))
            s := mload(add(_sig, 64))
            v := byte(0, mload(add(_sig, 96)))
        }
    }

    function recover(bytes32 msgSigned, bytes memory _sig) internal pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = _split(_sig);
        return ecrecover(msgSigned, v, r, s);
    }

    function verify(uint256 amount, bytes memory _sig) internal view returns (bool){
        // (address recovered, ECDSA.RecoverError err, bytes32 errArg) = ECDSA.tryRecover(hashRelease(amount), _sig);
        // require(err == ECDSA.RecoverError.NoError, "Something did not work during recovery attempt.");
        bytes32 signedMessage = ethHashRelease(hashRelease(amount));
        address recovered = recover(signedMessage, _sig);
        return recovered == depositor;
    }

    // E-3 release(amount, sig) sends (amount – fee) to payee if sig recovers depositor from keccak256(“RELEASE”, address(this), amount). Forward the fee to the factory, emit Released(payee, amountAfterFee).
    // Todo: still work in progress, need to finish deadline calculations
    function release(uint256 amount, bytes calldata _sig) external nonReentrant {
        // Checks
        require(fundedAlready, "The contruct is not funded yet");
        require(block.timestamp <= deadline, "expired");
        require(amount <= address(this).balance, "insufficient funds");
        bool isSignedByDepositor = verify(amount, _sig);
        require(isSignedByDepositor, "Signature is invalid");

        // Effects
        uint256 fee = (amount*feePercent)/100;
        uint256 amountAfterFee = amount - fee;

        // Interactions
        (bool success_for_payee, ) = payee.call{value: amountAfterFee}("");
        require(success_for_payee, "payee did not get the funds");
        (bool success_for_factory, ) = factory.feeRecipient().call{value: fee}("");
        require(success_for_factory, "factory did not get the funds");
        emit Released(payee, amountAfterFee);
    }
}
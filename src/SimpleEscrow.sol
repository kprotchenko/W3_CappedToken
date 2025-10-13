// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;
import {EscrowFactory} from "../src/EscrowFactory.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
contract SimpleEscrow {
    event Funded(uint256 amount);
    event Released(address payee, uint256 amount);
    // E-1 Constructor args: (factory, depositor, payee, deadline, feePercent); mark as immutable where possible.
    address immutable depositor;
    address immutable payee;
    uint immutable deadline;
    uint immutable feePercent;
    bool fundedAlready;
    EscrowFactory immutable factory;

    // E-1 Constructor args: (factory, depositor, payee, deadline, feePercent); mark as immutable where possible.
    constructor(EscrowFactory _factory, address _depositor, address _payee, uint _deadline, uint _feePercent){
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

    function hashRelease() private pure returns (bytes32) {
        bytes32 messageHash = keccak256(abi.encodePacked("RELEASE" ));
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

    function recover(bytes32 msgSigned, bytes memory _sig) private pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = _split(_sig);
        return ecrecover(msgSigned, v, r, s);
    }

    function verify(bytes memory _sig) private view returns (bool){
        return recover(hashRelease(), _sig) == depositor;
    }

    // E-3 release(amount, sig) sends (amount – fee) to payee if sig recovers depositor from keccak256(“RELEASE”, address(this), amount). Forward the fee to the factory, emit Released(payee, amountAfterFee).
    // Todo: still work in progress
    function release(uint256 amount, bytes memory _sig) public {
        require(fundedAlready, "The contruct is not dunded yet");
        uint256 amountAfterFee = amount - (amount*feePercent)/100;
        bool isSignedByDepositor = verify(_sig);
        require(isSignedByDepositor, "Signature is invalid");
        emit Released(payee, amountAfterFee);
    }
}
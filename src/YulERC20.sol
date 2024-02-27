// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

contract Cheatsheet {
    // opcodes ---------------------------------------------//
    // area, operation, params(location, value), output

    // memory ----------------------------------------------//

    // - memory structure
    // byte addressable but interaction in words (32 bytes from byte address )

    // - scratch space
    // 0x00 32 byte slot and 0x20 32 byte slot are reserved for solidity internal operations
    
    // - Free memory pointer
    // this points to a usable memory location
    
    // - mstore, mstore8, mload
    
    // storage ---------------------------------------------//
    // - storage structure
    // - sstore, sload

    // utils -----------------------------------------------//
    // - return
    // return can only read from memory, cant directly handle storage state vars
    
    uint256 internal _counter;

    function setCounter(uint256 val) public {
        assembly{
            // set the funds variable to amt
            sstore(0x00, val)
        }
    }
    function getCounter() view public returns(uint256) {
        uint256 val;
        assembly{
            val := sload(0)         
            let freeMemPtr := mload(0x40)
            mstore(freeMemPtr, val)

            return(freeMemPtr, 0x20)
        }
    }
    function increment() public {
        assembly{
            sstore(0,add(sload(0),1))
        }
    }

}
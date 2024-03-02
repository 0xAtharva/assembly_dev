/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////

// execution --------------------------------------------------------------------------//
// 1. opcodes
// - area, operation, params(location, value), output

// 2. area
// - storage, memory, stack, calldata
// - yul manages stack for us, devs manage memory and storage

// 3. operations
// - (load, return), (store, push), (arithmetic), (context)

// 4. params
// - 'location' is mostly provided 
// - 'value' is provided for write operations

// yul --------------------------------------------------------------------------------//
// 1. about
// - can be helpful for directly control over memory and storage
// - easily inlined with solidity
// - great for optimizing gas. 

// types ------------------------------------------------------------------------------//
// 1 native type
// - bytes32

// 2 supported abstractions
// - uint256 and derivatives
// - bool
// - string

// memory -----------------------------------------------------------------------------//
// 1 memory structure
// - byte addressable array but interaction in words (32 bytes from byte address )

// 2 scratch space 
// - 0x00 : a 32 byte slot 
// - 0x20 : a 32 byte slot 

// 3 Free memory pointer
// - 0x40 : this contains location to a free memory

// 4 zero slot
// - 0x60 : zero slot, used as default value for uninitialized variables

// storage ----------------------------------------------------------------------------//
// 1 storage structure
// - a series of mappings from 32-byte key(storage-slots) to a 32-byte value
// - Storage layout starts at slot 0.
// - The data is stored in the right-most byte(s).
// - If the next value can fit into the same slot (determined by type), 
//   it is right-aligned in the same slot, else it is stored in the next slot.
// - Immutable and constant values are not in storage, 
//   therefore they do not increment the storage slot count.
// - Storage slots of a parent contract precedes the child in the order of inheritance.

// 2 mapping value slot 
// - keccak256(abi.encode(key,declaration slot))

// 3 arrays 
// - A dynamically sized array stores the current length in its slot, 
//   then its elements are stored sequentially from Keccak-256 hash of the slot number.         

// 4 byte arrays and strings 
// - Byte arrays and strings are stored the same way as other dynamic arrays 
//   unless the length is 31 or less. Then it is packed into one slot 
//   and the right-most byte is occupied by two times the length.

// gas costs --------------------------------------------------------------------------//
// 1 optimization
// - Oftentimes, gas-optimization is about reducing the number of 
//   stack jugglings (push, pop, swap, duplicate etc), to achieve a given objective.
// - time and space complexity should be optimized for gas consumption
// - storage operations are the costliest

// 2 opcode gas costs
// - sload
// - store
// - mload : supports local variables
// - mstore
// - mstore8
// - calldataload
// - calldatacopy
// - create
// - create2
// - return
// - call
// - delegatecall
// - staticall
// - caller
// - add
// - sub
// - mul
// - div
// - lt
// - gt
// - eq
// - pushN
// - pop
// - dup
// - dupN
// - extcodesize

// components -------------------------------------------------------------------------//
// 1 data read write
// - read write from memory, storage, stack

// 2 events
// - Events have up to four indexed topics.
// - The first topic is always the Keccak-256 hash of the event signature.
// - Non-indexed topics are logged by storing them in memory and  
//   passing to the log instruction a pointer to the start of the data and  
//   the length of the data.

// 3 errors
// - consist of a four byte error selector and the error data.

// global -----------------------------------------------------------------------------//
// 1 return
// - return can only read from memory, cant directly handle storage state vars
// - returning strings: (ptr(0x20),length,data)

// 2 calldataload(offset bytes)
// - copy calldata bytes from the provided offset into memory

// calldatacopy

// call

// delegatecall

// extcodesize

// keccak256
// - start reading data from the address provided

// for 
// if
// switch

/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

contract Parent{
    /* slot: 0 */ bool internal _pause; 
    /* slot: 1 */ uint256 internal _counter; 
}

/// @author 0xAtharva
/// @notice practical usage cheatsheet of inline assembly (educational purposes only)
contract Cheatsheet is Parent {

    /* slot: 2 */ string internal _name = "counting now"; 
    /* slot: 3 */ uint256[] internal _a = [71,2,3];
    /* slot: 4 */ mapping(address => uint256) register;

    // reading bool from storage
    function status() view public returns(bool){
        assembly{
            let memptr := mload(0x40)
            mstore(memptr,sload(0))
            return(memptr,0x20)
        }
    }
    function toggle() public {
        bool x = !_pause;
        assembly{
            sstore(0,x)
        }
    }
    //storing uint256 in storage
    function setCounter(uint256 val) public {
        assembly{
            // set the funds variable to amt
            sstore(1, val)
        }
    }

    //reading and returning uint256 from storage
    function getCounter() view public returns(uint256) {
        uint256 val;
        assembly{
            val := sload(1)
            let freeMemPtr := mload(0x40)
            mstore(freeMemPtr, val)

            return(freeMemPtr, 0x20)
        }
    }

    //reading and returning strings from storage
    function name() view public returns(string memory) {
        string memory n;
        assembly{
            let memptr := mload(0x40)
            n := sload(2)
            mstore(memptr,0x20)
            mstore(add(memptr,0x20),12)
            mstore(add(memptr,0x40),n)
            return(memptr,0x60)
        }
    }

    // memory array sum (loops)
    // notice that memory arrays are fixed size
    function arraySum(uint256[] memory a) pure public returns(uint256) {
        uint256 sum;
        assembly {
            let l := mload(a)
            for { let i:= 0 } lt(i,l) { i := add(i,1) }{
                sum := add(sum, mload(add(add(a,0x20),mul(i,0x20))))
            }
        }
        return sum;
    }
}
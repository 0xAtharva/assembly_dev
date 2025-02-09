/*
1. bits 
    1. a single transistor thats on(1) or off(0)
    2. bit is the smallest piece of information in computer architecture 



2. bytes
    1. a group of 8 transistors
    2. this group of transistors together represent a certain character.
    3. byte is the fundamental unit of data in computers



3. words
    1. a group of 32 bytes
    2. EVM operates on words



4. endian formats
    1. the order in which bytes are arranged within larger datatypes in computer memory
    2. big-endian : english way  ,      little-endian : arabic way
    3. EVM operates on 32 byte words, which are stored in big-endian format



5. character encodings
    1. an encoding scheme to represent characters ASCII, UTF-8



6. datatypes
    1. strict containers for data that maintain sanity in the code
    2. a certain size
    3. a certain interpretation
    4. bundled methods



7. floating points in computers
            base 10 : 1000   100   10   1   1/10   1/100   1/1000
            base 2  :   8     4    2    1    1/2    1/4     1/8
    1. computers are naturally base 2 (transistors can only be On/Off)
    2. representing base 10 decimals with underlying as base 2 is tricky. Computers need to
    construct base 10 decimals using base 2 components and there are unexpected decimal
    arithmetic outputs in computers so solidity has got rid of floats.
    3. To mimic decimal behaviour just use scaled values by the required decimal places you need



8. overflow underflow
    1. valuation (in terms of binary values) : (base)**following
    2. this is a common problem that occurs when 
    the output is out of the limits of the datatype container size.



9. literals
    1. fixed values embedded in the code
    2. carry a certain interpretation
    3. types
        1. decimal literals : underscores allowed, NeX allowed
        2. hexadecimal literals : start with 0x
        3. address literals : hexadecimals that follow eip55 address checksum
        4. string literals : "....."
        5. boolean literal : true/false
        6. unicode literal : unicode"....."



10. inline assembly and opcodes
    1. execution 
        - opcodes : area, operation, params(location, value), output
        - yul manages stack for us, devs manage memory and storage
    2. memory 
        - structure : byte addressable array
        - scratch space 
            0x00 : a 32 byte slot 
            0x20 : a 32 byte slot 
        - Free memory pointer
            0x40 : this contains location to a free memory
        - zero slot
            0x60 : zero slot, used as default value for uninitialized variables
    3. storage 
        - structure
            - mapping of 32-byte keys(storage-slots) to a 32-byte values
            - storage slots start at slot 0
        - rules
            [1] If the next value can fit into the same slot (determined by type), it is right-aligned in the same slot, else it is stored in the next slot.
            2 Immutable and constant values are not written to storage, therefore they do not increment the storage slot count.
            3 Storage slots of a parent contract precedes the child in the order of inheritance.
            4 mapping value slot : keccak256(abi.encode(key,declaration slot))
            5 arrays : A dynamically sized array stores the current length in its slot, then its elements are stored sequentially from Keccak-256 hash of the slot number.         
            6 byte arrays and strings : Byte arrays and strings are stored the same way as other dynamic arrays unless the length is 31 or less. 
            Then it is packed into one slot and the right-most byte is occupied by two times the length.
    



11. Gas
    1. gas is a commodity like petrol is for bike
    2. gas has to be bought in ETH
    3.



12. accounts



13. txns and messages




14. mempool



15. blocks



16. consensus



17. L1, L2s and scalability trilemma


// types ------------------------------------------------------------------------------//
// 1 native type
// - bytes32

// 2 supported abstractions
// - uint256 and derivatives
// - bool
// - string
-----------------

// 3 opcode gas costs
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
// - reverts data only from the memory

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
*/

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
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Test, console} from "forge-std/Test.sol";
import "src/YulERC20.sol";

contract YulERC20Test is Test {
    Cheatsheet public c;

    function setUp() public {
        c = new Cheatsheet();
    }

    function test_getCounter() public {
        assertEq(c.getCounter(), 0);
        c.setCounter(101);
        assertEq(c.getCounter(), 101);
    }

    function test_increament() public {
        assertEq(c.getCounter(), 0);
        c.increment();
        assertEq(c.getCounter(), 1);
    }
}

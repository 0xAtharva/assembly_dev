// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Test, console} from "forge-std/Test.sol";
import "src/assembly_cheatsheet.sol";

contract YulERC20Test is Test {
    Cheatsheet public c;
    address public deployer = 0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496;
    address public alice = vm.addr(1);

    function setUp() public {
        c = new Cheatsheet();
    }

    function test_toggle_status() public {
        c.toggle();
        assertEq(c.status(), true);
    }
    function test_setCounter_getCounter() public {
        assertEq(c.getCounter(), 0);
        c.setCounter(101);
        assertEq(c.getCounter(), 101);
    }
    function test_name_c() public {
        assertEq(c.name(), "counting now");
    }
    function test_arraySum() public {
        // notice that memory arrays are fixed size
        uint256[] memory arr = new uint256[](3);
        arr[0] = 1;
        arr[1] = 2;
        arr[2] = 3;
        assertEq(c.arraySum(arr), 6);
    }
    
}

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

    function test_1getCounter_sol() public {
        assertEq(c.getCounter_sol(), 0);
    }
    
    function test_2getCounter_asm() public {
        assertEq(c.getCounter_asm(), 0);
    }

    function test_3setCounter_sol() public {
        c.setCounter_sol(1000);
    }
    
    function test_4setCounter_asm() public {
        c.setCounter_asm(1000);
    }



    function test_name() public {
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

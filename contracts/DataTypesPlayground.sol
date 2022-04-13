// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.13;

contract DataTypesPlaygroundContract {
    bool public someBool;
    uint public someNumber;
    string public someString = 'I am dummy variable!';
    
    function setSomeBool(bool _someBool) public {
        someBool = _someBool;
    }
    
    function setSomeNumber(uint _someNumber) public {
        someNumber = _someNumber;
    }
    
    function incrSomeNumber() public {
        someNumber++;
    }
    
    function decrSomeNumber() public {
        someNumber--;
    }
}

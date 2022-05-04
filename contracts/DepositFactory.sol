// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.13;

contract DepositFactory {
    uint public interestRate;
    uint public lockPeriod;

    struct Deposit {
        uint volume;
        uint date;
    }

    Deposit[] public deposits;

    mapping (uint => address) public depositToOwner;
    mapping (address => uint) ownerDepositsCount;

    function _createDeposit() internal {
        deposits.push(Deposit(msg.value, block.timestamp));
        uint id = deposits.length - 1;
        depositToOwner[id] = msg.sender;
        ownerDepositsCount[msg.sender]++;
    }

    function receiveDeposit() public payable {
        _createDeposit();
    }
}

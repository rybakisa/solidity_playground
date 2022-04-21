// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";


contract SillyDepositContract is Ownable {
    uint public depositVolume;
    uint public depositDate;
    uint public interestRate;
    uint public lockPeriod;
    address public depositOwner;

    constructor(uint _lockPeriod, uint _interestRate) {
        lockPeriod = _lockPeriod;
        interestRate = _interestRate;
    }

    function destroyContract() public onlyOwner {
        selfdestruct(payable(owner()));
    }

    function getBalance() public view returns(uint) {
        return address(this).balance;
    }

    function receiveDeposit() public payable {
        require(depositOwner == address(0), 'You cant refund this deposit!');
        depositOwner = payable(msg.sender);
        depositVolume = msg.value;
        depositDate = block.timestamp;
    }

    function receiveFunds() public payable {
        if (msg.sender != owner()) {
            receiveDeposit();
        }
    }

    function compoundInterest() private view returns(uint) {
        return depositVolume + depositVolume * interestRate / 100;
    }

    function withdrawDeposit(uint _withdrawAmount) public {
        require(block.timestamp - depositDate > lockPeriod, 'Your funds are still locked!');
        require(msg.sender == depositOwner, 'You are not owner of this deposit!');

        uint fullAmount = compoundInterest();
        require(fullAmount >= _withdrawAmount, 'Insufficient funds!');

        address payable to = payable(msg.sender);
        depositVolume = fullAmount - _withdrawAmount;
        to.transfer(_withdrawAmount);
    }

    receive () external payable {
        receiveFunds();
    }
}

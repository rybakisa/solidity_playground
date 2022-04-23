// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";


contract SillyDepositContract is Ownable {
    uint public interestRate;
    uint public lockPeriod;

    struct Deposit {
        uint volume;
        uint date;
    }

    Deposit[] public deposits;

    mapping (uint => address) public depositToOwner;
    mapping (address => uint) ownerDepositsCount;


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

    function _createDeposit() internal {
        deposits.push(Deposit(msg.value, block.timestamp));
        uint id = deposits.length - 1;
        depositToOwner[id] = msg.sender;
        ownerDepositsCount[msg.sender]++;
    }

    function receiveDeposit() public payable {
        _createDeposit();
    }

    function receiveFunds() public payable {
        if (msg.sender != owner()) {
            receiveDeposit();
        }
    }

    function compoundInterest(uint _depositVolume, uint _depositDate) private view returns(uint) {
        uint periods = block.timestamp - _depositDate / lockPeriod;
        uint result = _depositVolume;
        for (uint i = 0; i < periods; i++) {
            result += result * interestRate / 100;
        }
        return result;
    }

    function getDepositsByOwner(address _owner) external view returns(uint[] memory) {
        uint[] memory result = new uint[](ownerDepositsCount[_owner]);
        uint counter = 0;
        for (uint i = 0; i < deposits.length; i++) {
            if (depositToOwner[i] == _owner) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }

    function withdrawDeposit(uint _depositId, uint _withdrawAmount) public {
        require(msg.sender == depositToOwner[_depositId], 'You are not owner of this deposit!');

        Deposit storage deposit = deposits[_depositId]; 
        require(block.timestamp - deposit.date > lockPeriod, 'Your funds are still locked!');

        uint fullAmount = compoundInterest(deposit.volume, deposit.date);
        require(fullAmount >= _withdrawAmount, 'Insufficient funds!');
        deposit.volume = fullAmount - _withdrawAmount;

        address payable to = payable(msg.sender);
        to.transfer(_withdrawAmount);
    }

    receive () external payable {
        receiveFunds();
    }
}

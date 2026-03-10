// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Counter {
    uint256 public number;
    uint256 public errkat; // flag to emit via event

    // event that logs the current errkat flag value
    event Errkat(uint256 flag);

    function setNumber(uint256 newNumber) public {
        number = newNumber;
        errkat = newNumber;
        emit Errkat(errkat);
    }

    function increment() public {
        number++;
        errkat = number;
        emit Errkat(errkat);
    }
}

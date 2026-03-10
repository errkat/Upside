// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console2.sol";

interface IChallenge {
    function submit(bytes32 _submit, string calldata username) external;
    function submitted(address who) external view returns (bool);
}

contract SolveChallenge2 is Script {
    address constant TARGET = 0xb233e726F8DC8B3Ff27Ff7fB212966B251b6b156;

    function run() external {
        uint256 pk = vm.envUint("KEY");
        address eoa = vm.addr(pk);
        string memory username = vm.envString("USERNAME");

        bytes32 dim = vm.load(TARGET, bytes32(uint256(0)));
        console2.log("dimension =");
        console2.logUint(uint256(dim));

        bytes32 outer = keccak256(abi.encode(uint256(2), uint256(1)));
        bytes32 base = keccak256(abi.encode(uint256(2), outer));

        bytes32 packedXY = vm.load(TARGET, base);
        bytes32 zRaw = vm.load(TARGET, bytes32(uint256(base) + 1));

        console2.log("positions[2][2] slot(base) =");
        console2.logBytes32(base);

        console2.log("positions[2][2] packed x,y =");
        console2.logBytes32(packedXY);

        console2.log("positions[2][2].z =");
        console2.logBytes32(zRaw);
        console2.logUint(uint256(zRaw));

        bytes32 id = keccak256(abi.encode(username, eoa));
        bytes32 expected = keccak256(abi.encode(uint256(zRaw), id));

        console2.log("username = ", username);
        console2.log("solver   = ", eoa);
        console2.log("submit   =");
        console2.logBytes32(expected);

        vm.startBroadcast(pk);
        IChallenge(TARGET).submit(expected, username);
        vm.stopBroadcast();

        bool ok = IChallenge(TARGET).submitted(eoa);
        console2.log("submitted =", ok);
    }
}
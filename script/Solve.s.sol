// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console2.sol";

interface IChallenge {
    function submit(uint256[] calldata flags, string calldata username) external;
    function submitted(address who) external view returns (bool);
}

contract SolveChallenge is Script {
    address constant TARGET = 0x5F151DfEA40761022d3Da8deF8CA7724413c4e4C;

    function run() external {
        uint256 pk = vm.envUint("KEY");
        address eoa = vm.addr(pk);
        string memory username = vm.envString("USERNAME");

        bytes32 slot0 = vm.load(TARGET, bytes32(uint256(0))); // a
        bytes32 slot1 = vm.load(TARGET, bytes32(uint256(1))); // b
        bytes32 slot2 = vm.load(TARGET, bytes32(uint256(2))); // flag.length
        bytes32 slot3 = vm.load(TARGET, bytes32(uint256(3))); // c
        bytes32 slot4 = vm.load(TARGET, bytes32(uint256(4))); // d

        console2.log("a        =");
        console2.logBytes32(slot0);
        console2.log("b        =");
        console2.logBytes32(slot1);
        console2.log("flag.len =");
        console2.logUint(uint256(slot2));
        console2.log("c        =");
        console2.logBytes32(slot3);
        console2.log("d        =");
        console2.logBytes32(slot4);

        bytes32 base = keccak256(abi.encode(uint256(2)));

        bytes32 f0 = vm.load(TARGET, base);
        bytes32 f1 = vm.load(TARGET, bytes32(uint256(base) + 1));
        bytes32 f2 = vm.load(TARGET, bytes32(uint256(base) + 2));

        console2.log("flag[0] raw =");
        console2.logBytes32(f0);
        console2.log("flag[1] raw =");
        console2.logBytes32(f1);
        console2.log("flag[2] raw =");
        console2.logBytes32(f2);

        console2.log("flag[0] str =", _trimNulls(f0));
        console2.log("flag[1] str =", _trimNulls(f1));
        console2.log("flag[2] str =", _trimNulls(f2));

        bytes32 id = keccak256(abi.encode(username, eoa));
        bytes32 expected = keccak256(
            abi.encode(uint256(f0), uint256(f1), uint256(f2), id)
        );

        console2.log("username   =", username);
        console2.log("solver EOA =", eoa);
        console2.log("submit arg =");
        console2.logBytes32(expected);

        vm.startBroadcast(pk);
        uint256[] memory flags = new uint256[](3);
        flags[0] = uint256(f0);
        flags[1] = uint256(f1);
        flags[2] = uint256(f2);
        IChallenge(TARGET).submit(flags, username);
        vm.stopBroadcast();

        bool ok = IChallenge(TARGET).submitted(eoa);
        console2.log("submitted =", ok);
    }

    function _trimNulls(bytes32 data) internal pure returns (string memory) {
        uint256 len = 0;
        while (len < 32 && data[len] != 0) {
            len++;
        }

        bytes memory out = new bytes(len);
        for (uint256 i = 0; i < len; i++) {
            out[i] = data[i];
        }
        return string(out);
    }
}

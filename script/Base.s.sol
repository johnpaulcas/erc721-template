// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { Script } from "forge-std/Script.sol";

abstract contract BaseScript is Script {
    /// @dev The private key of the transaction broadcaster.
    uint256 internal broadcaster;

    constructor() {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        broadcaster = pk;
    }

    modifier broadcast() {
        vm.startBroadcast(broadcaster);
        _;
        vm.stopBroadcast();
    }
}

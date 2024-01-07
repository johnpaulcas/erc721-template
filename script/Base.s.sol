// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { Script } from "forge-std/Script.sol";

abstract contract BaseScript is Script {
    /// @dev The address of the transaction broadcaster.
    address internal broadcaster;

    constructor() {
        address from = vm.envOr({ name: "ETH_FROM", defaultValue: address(0) });
        broadcaster = from;
    }

    modifier broadcast() {
        vm.startBroadcast(broadcaster);
        _;
        vm.stopBroadcast();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

import "forge-std/Test.sol";
import { Users } from "./utils/Types.sol";

abstract contract Base_Test is Test {
    Users internal users;

    function setUp() public virtual {
        // Generate test users
        users = Users({
            admin: createUser("Admin"),
            alice: createUser("Alice"),
            eve: createUser("Eve")
        });

        // Label the contracts
        // vm.label(users.admin, "Admin"); // sample label
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Generates a user,labels its address, and funds it with 100 ether
    function createUser(string memory name) internal returns (address) {
        address payable user = payable(makeAddr(name));
        vm.label(user, name);
        deal(user, 100 ether);
        return user;
    }

    /// @dev Change contract `msg.sender` to `msgSender`
    function changePrank(address msgSender) internal override {
        vm.stopPrank();
        vm.startPrank(msgSender);
    }
}

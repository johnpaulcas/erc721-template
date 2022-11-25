// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;

import "forge-std/Test.sol";

import {ERC721Template} from "../src/ERC721Template.sol";

abstract contract HelperERC721Template {
    ERC721Template t_nft;

    address[] withdrawalAddresses;
    uint256[] withdrawalPercentage;
}

contract WithdrawalTest is Test, HelperERC721Template {
    function setUp() public {
        t_nft = new ERC721Template();

        withdrawalAddresses.push(address(0xBEEF));
        withdrawalAddresses.push(address(0xCAFE));

        withdrawalPercentage.push(50);
        withdrawalPercentage.push(50);
    }

    function testWithdrawalInfo() public {
        t_nft.grantRole(t_nft.ADMIN_ROLE(), address(this));
        t_nft.setWithdrawalInfo(withdrawalAddresses, withdrawalPercentage);

        for (uint i = 0; i < withdrawalAddresses.length; i++) {
            assertEq(t_nft.s_wallets(i), withdrawalAddresses[i]);
        }

        for (uint i = 0; i < withdrawalPercentage.length; i++) {
            assertEq(t_nft.s_walletsShares(i), withdrawalPercentage[i]);
        }
    }

    function testWithdraw() public {
        uint256 deposit = 1 ether;
        t_nft.grantRole(t_nft.ADMIN_ROLE(), address(this));
        t_nft.setWithdrawalInfo(withdrawalAddresses, withdrawalPercentage);

        // assert check withdrawal addresses doesnt have any eth balance
        for (uint n = 0; n < withdrawalAddresses.length; n++) {
            assertEq(withdrawalAddresses[n].balance, 0);
        }

        vm.deal(address(t_nft), deposit);
        assertEq(address(t_nft).balance, deposit);
    }
}

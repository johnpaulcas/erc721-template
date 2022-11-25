// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "erc721a/contracts/ERC721A.sol";

contract ERC721Template is ERC721A, AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    error Unauthorized(bytes32 role, address caller);

    // withdrawal accounts and shares
    address[] public s_wallets;
    uint256[] public s_walletsShares;
    uint256 public s_totalShares;

    modifier onlyHasRole(bytes32 _role) {
        if (!hasRole(_role, _msgSenderERC721A())) {
            revert Unauthorized({role: _role, caller: _msgSenderERC721A()});
        }
        _;
    }

    constructor() ERC721A("ERC721A Template", "ERC721A") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    receive() external payable {}

    // === Withdrawal ===

    /// @notice Set receiver of native token for this contract
    /// @param wallets The wallet where native token will be sent
    /// @param walletsShares The share per wallet address
    function setWithdrawalInfo(
        address[] memory wallets,
        uint256[] memory walletsShares
    ) public onlyHasRole(ADMIN_ROLE) {
        require(wallets.length == walletsShares.length, "not equal");
        s_wallets = wallets;
        s_walletsShares = walletsShares;

        s_totalShares = 0;
        for (uint256 i = 0; i < walletsShares.length; i++) {
            s_totalShares += walletsShares[i];
        }
    }

    /// @notice Withdraw contract native token balance
    function withdraw() public onlyHasRole(ADMIN_ROLE) {
        require(address(this).balance > 0, "no eth to withdraw");
        uint256 totalReceived = address(this).balance;
        for (uint256 i = 0; i < s_walletsShares.length; i++) {
            uint256 payment = (totalReceived * s_walletsShares[i]) /
                s_totalShares;
            Address.sendValue(payable(s_wallets[i]), payment);
        }
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721A, AccessControl) returns (bool) {
        return
            ERC721A.supportsInterface(interfaceId) ||
            AccessControl.supportsInterface(interfaceId);
    }
}

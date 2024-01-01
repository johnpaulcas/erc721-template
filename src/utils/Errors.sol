// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

library Errors {
    /// @dev Error thrown when the max supply is reached
    error MaxSupplyReached();

    /// @dev Error thrown when the user doesn't have enough funds to mint
    error NotEnoughFunds();

    /// @dev Error thrown when the transfer of funds to the treasury failed
    error TransferFundToTreasuryFailed();

    /// @dev Error thrown when the user has reached the premint limit
    error PremintLimitExceeded();

    /// @dev Error thrown when the user is not qualified for the premint phase
    error NotQualifiedForPremint();

    /// @dev Error thrown when the user doesn't have the required `role` to perform secure actions
    error UnauthorizedAccount(bytes32 role, address account);
}

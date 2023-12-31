// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

interface IBaseERC721Mint {
    /// @dev Event emitted when user mints a token
    event Mint(address indexed to, uint256 indexed totalMinted);

    /// @dev Event emitted when the treasury receives funds
    event TransferFundToTreasury(
        address indexed treasury,
        uint256 indexed amount
    );

    /**
     * @dev Mint a specified number of tokens to the caller.
     * @param _numberOfTokens The number of tokens to mint.
     * @notice The receiver of the tokens will be the `msg.sender`.
     */
    function mint(uint256 _numberOfTokens) external payable;
}

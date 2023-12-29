// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

interface IBaseERC721Mint {
    /// @dev Event emitted when user mints a token
    event Mint(address indexed to, uint256 indexed totalMinted);

    /**
     * @dev Function to mint a new ERC721 token.
     * @param _to The address to which the token will be minted.
     * @param _numberOfTokensToMint The number of tokens to mint.
     */
    function mint(address _to, uint256 _numberOfTokensToMint) external payable;
}

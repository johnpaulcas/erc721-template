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

    /**
     * @dev Mint a specified number of tokens to the caller.
     * @param _numberOfTokens The number of tokens to mint.
     * @param _merkleProof The merkle proof for the caller's address.
     * @notice The receiver of the tokens will be the `msg.sender`.
     */
    function premint(
        uint256 _numberOfTokens,
        bytes32[] calldata _merkleProof
    ) external payable;

    /**
     * @dev Checks if a user is qualified for the premint phase by verifying their merkle proof.
     * @param _merkleProof The merkle proof for the user's address.
     * @return A boolean indicating whether the user is qualified for the premint phase.
     */
    function isQualifiedForPremint(
        bytes32[] calldata _merkleProof
    ) external view returns (bool);

    /**
     * @dev Sets the pre-mint merkle root.
     * @param _merkleRoot The merkle root value to be set.
     * Requirements:
     * - The function can only be accessed by the caller who has `MANAGER_ROLE` access.
     */
    function setPremintMerkleRoot(bytes32 _merkleRoot) external;

    /**
     * @dev Sets the maximum number of tokens that can be minted per address during the premint phase.
     * @param _premintPerAddressLimit The maximum number of tokens that can be minted per address during the premint phase.
     * Requirements:
     * - The function can only be accessed by the caller who has `MANAGER_ROLE` access.
     */
    function setPremintPerAddressLimit(
        uint256 _premintPerAddressLimit
    ) external;
}

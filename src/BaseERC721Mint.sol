// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";

import { IBaseERC721Mint } from "./interfaces/IBaseERC721Mint.sol";
import { Errors } from "./utils/Errors.sol";

/**
 * @title BaseERC721Mint
 * @notice This contract defines the minting functionality for the ERC721 token.
 * @dev This contract extends the ERC721 contract and implements the IBaseERC721Mint interface.
 * It also includes the ReentrancyGuard modifier to prevent reentrancy attacks.
 * @author johnpaulcas
 */
abstract contract BaseERC721Mint is
    ERC721,
    ReentrancyGuard,
    AccessControl,
    IBaseERC721Mint
{
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    address public treasury;

    uint256 private nextTokenId;
    uint256 public totalSupply;

    // maximum number of tokens that can be minted per address during the premint phase.
    uint256 public premintPerAddressLimit;
    // keeps track of the number of tokens minted for each address during the premint phase.
    mapping(address => uint256) public premintLookup;
    // merkle root for the premint phase.
    bytes32 public premintMerkleRoot;

    /**
     * @dev Constructor function for ERC721Mint contract.
     * @param _name The name of the ERC721 token.
     * @param _symbol The symbol of the ERC721 token.
     * @param _treasury The address where the amount of eth to be sent.
     */
    constructor(
        string memory _name,
        string memory _symbol,
        address _treasury,
        address _initialAdmin
    ) ERC721(_name, _symbol) {
        treasury = _treasury;
        _grantRole(DEFAULT_ADMIN_ROLE, _initialAdmin);
    }

    modifier hasManagerRole() {
        /**
         * @dev Modifier to check if the caller has the MANAGER_ROLE.
         * If the caller does not have the MANAGER_ROLE, it reverts the transaction
         * with an "UnauthorizedAccount" error.
         */
        if (!hasRole(MANAGER_ROLE, _msgSender())) {
            revert Errors.UnauthorizedAccount(MANAGER_ROLE, _msgSender());
        }
        _;
    }

    function mint(
        uint256 _numberOfTokens
    ) public payable override nonReentrant {
        _mintTokens(_msgSender(), _numberOfTokens);
    }

    function premint(
        uint256 _numberOfTokens,
        bytes32[] calldata _merkleProof
    ) public payable override nonReentrant {
        // Checks if user is qualified for the premint phase.
        if (!isQualifiedForPremint(_merkleProof)) {
            revert Errors.NotQualifiedForPremint();
        }

        // Checks if the sender has exceeded the limit of tokens that can be minted during the premint phase.
        uint256 premintCount = premintLookup[_msgSender()];
        if (premintCount + _numberOfTokens > premintPerAddressLimit) {
            revert Errors.PremintLimitExceeded();
        }

        premintLookup[_msgSender()] += _numberOfTokens;

        _mintTokens(_msgSender(), _numberOfTokens);
    }

    function isQualifiedForPremint(
        bytes32[] calldata _merkleProof
    ) public view override returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(_msgSender()));
        return _verifyPremintMerkleProof(_merkleProof, leaf);
    }

    function setPremintMerkleRoot(
        bytes32 _merkleRoot
    ) external override hasManagerRole {
        premintMerkleRoot = _merkleRoot;
    }

    /**
     * @dev Sets the maximum number of tokens that can be minted per address during the premint phase.
     * @param _premintPerAddressLimit The maximum number of tokens that can be minted per address during the premint phase.
     */
    function setPremintPerAddressLimit(
        uint256 _premintPerAddressLimit
    ) external override hasManagerRole {
        premintPerAddressLimit = _premintPerAddressLimit;
    }

    /// Required override from ERC721.
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /// @dev Internal function to mint a specified number of tokens to a given address.
    /// @param _to The address to mint the tokens to.
    /// @param _numberOfTokens The number of tokens to mint.
    function _mintTokens(address _to, uint256 _numberOfTokens) private {
        // Checks if the sender has provided enough funds to mint the specified number of tokens.
        uint256 totalMintPrice = _numberOfTokens * _mintPriceInWei();
        if (msg.value < totalMintPrice) {
            revert Errors.NotEnoughFunds();
        }

        // Increases the total supply of tokens by `_numberOfTokens`.
        // If the total supply exceeds the maximum supply, it reverts with an error.
        totalSupply += _numberOfTokens;
        if (totalSupply > _maxSupply()) {
            revert Errors.MaxSupplyReached();
        }

        _transferFundToTreasury(totalMintPrice);

        emit Mint(_to, _numberOfTokens);

        uint256 mintCount = 0;
        for (mintCount; mintCount < _numberOfTokens; mintCount++) {
            _safeMint(_to, _getNextTokenId());
            _incrementNextTokenId();
        }
    }

    /**
     * @dev Verifies the merkle proof for the caller's address.
     * @param _merkleProof The merkle proof for the caller's address.
     * @param _leaf The leaf node for the caller's address.
     * @return `true` if the merkle proof is valid, otherwise `false`.
     */
    function _verifyPremintMerkleProof(
        bytes32[] memory _merkleProof,
        bytes32 _leaf
    ) internal view returns (bool) {
        return MerkleProof.verify(_merkleProof, premintMerkleRoot, _leaf);
    }

    /**
     * @dev Transfers the specified amount of funds to the treasury address. Emits a {TransferFundToTreasury} event.
     * @param _totalMintPrice The total amount to be transferred to the treasury.
     */
    function _transferFundToTreasury(uint256 _totalMintPrice) internal {
        (bool success, ) = payable(treasury).call{ value: _totalMintPrice }("");
        if (!success) {
            revert Errors.TransferFundToTreasuryFailed();
        }

        emit TransferFundToTreasury(treasury, _totalMintPrice);
    }

    /**
     * @dev Increments the token ID counter by 1.
     */
    function _incrementNextTokenId() internal {
        nextTokenId++;
    }

    /**
     * @dev Returns the next token ID to be minted.
     * @return The next token ID.
     */
    function _getNextTokenId() internal view returns (uint256) {
        return nextTokenId + 1;
    }

    /*//////////////////////////////////////////////////////////////////////////
        Internal Functions that need to Override by Imlpementing Contracts
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Returns the price in Wei for minting a token.
    /// @dev Overrides _mintPriceInWei() on implementing contracts.
    function _mintPriceInWei() internal view virtual returns (uint256);

    /// @notice Returns the maximum supply of tokens.
    /// @dev Overrides _maxSupply() on implementing contracts.
    function _maxSupply() internal view virtual returns (uint256);
}

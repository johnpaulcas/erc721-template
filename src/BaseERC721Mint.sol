// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import { IBaseERC721Mint } from "./interfaces/IBaseERC721Mint.sol";
import { Errors } from "./utils/Errors.sol";

/**
 * @title BaseERC721Mint
 * @notice This contract defines the minting functionality for the ERC721 token.
 * @dev This contract extends the ERC721 contract and implements the IBaseERC721Mint interface.
 * It also includes the ReentrancyGuard modifier to prevent reentrancy attacks.
 * @author johnpaulcas
 */
abstract contract BaseERC721Mint is ERC721, ReentrancyGuard, IBaseERC721Mint {
    uint256 public constant MAX_SUPPLY = 10000;

    address public treasury;
    uint256 public mintPriceInWei;

    uint256 private nextTokenId;
    uint256 public totalSupply;

    // maximum number of tokens that can be minted per address during the premint phase.
    uint256 public premintPerAddressLimit;
    // keeps track of the number of tokens minted for each address during the premint phase.
    mapping(address => uint256) public premintLookup;

    /**
     * @dev Constructor function for ERC721Mint contract.
     * @param _name The name of the ERC721 token.
     * @param _symbol The symbol of the ERC721 token.
     * @param _treasury The address where the amount of eth to be sent.
     * @param _mintPriceInWei The price in Wei for minting a token.
     */
    constructor(
        string memory _name,
        string memory _symbol,
        address _treasury,
        uint256 _mintPriceInWei
    ) ERC721(_name, _symbol) {
        treasury = _treasury;
        mintPriceInWei = _mintPriceInWei;
    }

    function mint(
        uint256 _numberOfTokens
    ) public payable override nonReentrant {
        // Checks if the sender has provided enough funds to mint the specified number of tokens.
        uint256 totalMintPrice = _numberOfTokens * mintPriceInWei;
        if (msg.value < totalMintPrice) {
            revert Errors.NotEnoughFunds();
        }

        // Increases the total supply of tokens by `_numberOfTokens`.
        // If the total supply exceeds the maximum supply, it reverts with an error.
        totalSupply += _numberOfTokens;
        if (totalSupply > MAX_SUPPLY) {
            revert Errors.MaxSupplyReached();
        }

        _transferFundToTreasury(totalMintPrice);

        emit Mint(_msgSender(), _numberOfTokens);

        uint256 mintCount = 0;
        for (mintCount; mintCount < _numberOfTokens; mintCount++) {
            _safeMint(_msgSender(), _getNextTokenId());
            _incrementNextTokenId();
        }
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
}

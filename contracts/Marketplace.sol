// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

/// @title A NFT Marketplace using ERC1155
/// @author Team Bramble
/// @notice Prosumers can use this contract to list NFT on Marketplace

contract Marketplace is ERC1155Holder {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _nftSold;
    IERC1155 private nftContract;
    address private owner;
    uint256 private platformFee = 20;
    uint256 private deno = 1000;

    constructor(address _nftContract) {
        nftContract = IERC1155(_nftContract);
    }

    struct PowerNFTMarketItem {
        uint256 tokenId;
        uint256 nftId;
        uint256 amount;
        uint256 price;
        address payable seller;
        address payable owner;
        bool sold;
    }

    mapping(uint256 => PowerNFTMarketItem) private marketItem;

    /// @notice It will list the NFT to marketplace.
    /// @dev It will list NFT minted from MFTMint contract.
    function listNft(
        uint256 nftId,
        uint256 amount,
        uint256 price
    ) external {
        require(nftId > 0, "Token doesnot exist");

        _tokenIds.increment();
        uint256 tokenId = _tokenIds.current();

        marketItem[tokenId] = PowerNFTMarketItem(
            tokenId,
            nftId,
            amount,
            price,
            payable(msg.sender),
            payable(msg.sender),
            false
        );

        IERC1155(nftContract).safeTransferFrom(
            msg.sender,
            address(this),
            nftId,
            amount,
            ""
        );
    }

    /// @notice It will buy the Power NFT from marketplace.
    /// @dev User will able to buy NFT and transfer to respectively

    function buyNFT(uint256 tokenId, uint256 amount) external payable {
        uint256 price = marketItem[tokenId].price;
        uint256 marketFee = (price * platformFee) / deno;

        nftContract.safeTransferFrom(msg.sender, address(this), 0, price, "");

        nftContract.safeTransferFrom(
            msg.sender,
            address(this),
            0,
            marketFee,
            ""
        );

        marketItem[tokenId].owner = payable(msg.sender);
        _nftSold.increment();

        onERC1155Received(address(this), msg.sender, tokenId, amount, "");
        nftContract.safeTransferFrom(address(this), msg.sender, tokenId, 1, "");
    }
}

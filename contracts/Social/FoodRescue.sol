// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FoodRescueNFT is ERC721URIStorage, Ownable {
    uint256 private _tokenIds;

    struct ProductBatch {
        string productType;
        uint256 expirationTimestamp;
        address farmer;
        uint256 weightKg;
        bool isClaimed;
    }

    mapping(uint256 => ProductBatch) public batches;

    event ProductBatchMinted(
        uint256 indexed tokenId,
        address indexed farmer,
        string productType,
        uint256 weightKg,
        uint256 expirationTimestamp
    );

    event ProductBatchClaimed(
        uint256 indexed tokenId,
        address indexed claimer
    );

    constructor() ERC721("Bloomex Food Batch", "BFB") Ownable(msg.sender) {}

    function mintProductBatch(
        string memory productType,
        uint256 expirationTimestamp,
        uint256 weightKg,
        string memory metadataURI
    ) external returns (uint256) {
        require(expirationTimestamp > block.timestamp, "Invalid expiration date");
        require(weightKg > 0, "Weight must be greater than 0");

        _tokenIds++;
        uint256 newTokenId = _tokenIds;

        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, metadataURI);

        batches[newTokenId] = ProductBatch({
            productType: productType,
            expirationTimestamp: expirationTimestamp,
            farmer: msg.sender,
            weightKg: weightKg,
            isClaimed: false
        });

        emit ProductBatchMinted(newTokenId, msg.sender, productType, weightKg, expirationTimestamp);
        return newTokenId;
    }

    function claimBatch(uint256 tokenId) external {
        require(tokenId <= _tokenIds && tokenId > 0, "Token does not exist");
        ProductBatch storage batch = batches[tokenId];
        require(!batch.isClaimed, "Already claimed");
        require(block.timestamp <= batch.expirationTimestamp, "Expired batch");

        batch.isClaimed = true;
        emit ProductBatchClaimed(tokenId, msg.sender);
    }

    function getBatch(uint256 tokenId) external view returns (ProductBatch memory) {
        require(tokenId <= _tokenIds && tokenId > 0, "Token does not exist");
        return batches[tokenId];
    }
}
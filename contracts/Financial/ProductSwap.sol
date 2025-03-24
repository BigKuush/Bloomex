// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ProductSwap is Ownable {
    IERC20 public stableToken;              // USDC или USDT
    IERC721 public foodNFT;                 // Контракт NFT-продукции
    uint256 public platformFeeBps = 200;    // Комиссия платформы (200 = 2%)

    enum SwapStatus { Open, Confirmed, Cancelled }

    struct Swap {
        address seller;
        address buyer;
        uint256 nftId;
        uint256 price;
        SwapStatus status;
    }

    mapping(uint256 => Swap) public swaps;
    uint256 public swapCount;

    event SwapCreated(uint256 indexed swapId, address seller, uint256 nftId, uint256 price);
    event SwapConfirmed(uint256 indexed swapId, address buyer);
    event SwapCancelled(uint256 indexed swapId);

    constructor(address _stableToken, address _foodNFT) {
        stableToken = IERC20(_stableToken);
        foodNFT = IERC721(_foodNFT);
    }

    function createSwap(uint256 nftId, uint256 price) external returns (uint256) {
        require(foodNFT.ownerOf(nftId) == msg.sender, "Not NFT owner");
        require(price > 0, "Invalid price");

        foodNFT.transferFrom(msg.sender, address(this), nftId); // Блокируем NFT

        swapCount++;
        uint256 swapId = swapCount;

        swaps[swapId] = Swap({
            seller: msg.sender,
            buyer: address(0),
            nftId: nftId,
            price: price,
            status: SwapStatus.Open
        });

        emit SwapCreated(swapId, msg.sender, nftId, price);
        return swapId;
    }

    function confirmSwap(uint256 swapId) external {
        Swap storage s = swaps[swapId];
        require(s.status == SwapStatus.Open, "Not open");
        require(s.buyer == address(0), "Already confirmed");

        uint256 fee = (s.price * platformFeeBps) / 10000;
        uint256 sellerAmount = s.price - fee;

        // Перевод стейблкоина на контракт
        require(stableToken.transferFrom(msg.sender, address(this), s.price), "Payment failed");

        // Перевод NFT покупателю
        foodNFT.transferFrom(address(this), msg.sender, s.nftId);

        // Оплата продавцу
        stableToken.transfer(s.seller, sellerAmount);

        // Платформа получает комиссию
        stableToken.transfer(owner(), fee);

        s.buyer = msg.sender;
        s.status = SwapStatus.Confirmed;

        emit SwapConfirmed(swapId, msg.sender);
    }

    function cancelSwap(uint256 swapId) external {
        Swap storage s = swaps[swapId];
        require(s.status == SwapStatus.Open, "Not open");
        require(s.seller == msg.sender, "Not your swap");

        s.status = SwapStatus.Cancelled;
        foodNFT.transferFrom(address(this), msg.sender, s.nftId);

        emit SwapCancelled(swapId);
    }

    function setPlatformFee(uint256 bps) external onlyOwner {
        require(bps <= 1000, "Max 10%");
        platformFeeBps = bps;
    }

    function withdrawTokens(address to, uint256 amount) external onlyOwner {
        stableToken.transfer(to, amount);
    }

    function getSwap(uint256 swapId) external view returns (
        address seller,
        address buyer,
        uint256 nftId,
        uint256 price,
        SwapStatus status
    ) {
        Swap storage s = swaps[swapId];
        return (s.seller, s.buyer, s.nftId, s.price, s.status);
    }
}

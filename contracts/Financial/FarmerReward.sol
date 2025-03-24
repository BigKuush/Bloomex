// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title FarmerReward
 * @dev Контракт для выплаты субсидий фермерам за участие в соц. программе
 */
contract FarmerReward is Ownable {
    IERC20 public stableToken;

    // Структура субсидии
    struct Reward {
        uint256 amount;
        bool claimed;
    }

    // Привязка: tokenId => reward
    mapping(uint256 => Reward) public nftRewards;

    // События
    event RewardSet(uint256 indexed tokenId, uint256 amount);
    event RewardClaimed(address indexed farmer, uint256 indexed tokenId, uint256 amount);

    constructor(address _stableToken) {
        stableToken = IERC20(_stableToken);
    }

    /**
     * @notice Назначает награду за NFT партии продукции
     * @dev Может вызываться после передачи продукции соцслужбам
     */
    function setReward(uint256 tokenId, uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be > 0");
        require(!nftRewards[tokenId].claimed, "Already claimed");

        nftRewards[tokenId] = Reward({
            amount: amount,
            claimed: false
        });

        emit RewardSet(tokenId, amount);
    }

    /**
     * @notice Фермер получает свою награду по ID NFT
     */
    function claimReward(uint256 tokenId) external {
        Reward storage reward = nftRewards[tokenId];
        require(reward.amount > 0, "No reward set");
        require(!reward.claimed, "Already claimed");

        reward.claimed = true;
        stableToken.transfer(msg.sender, reward.amount);

        emit RewardClaimed(msg.sender, tokenId, reward.amount);
    }

    /**
     * @notice Получить статус награды
     */
    function getReward(uint256 tokenId) external view returns (uint256 amount, bool claimed) {
        Reward storage r = nftRewards[tokenId];
        return (r.amount, r.claimed);
    }

    /**
     * @dev Позволяет владельцу контракта вывести оставшиеся средства
     */
    function withdraw(address to, uint256 amount) external onlyOwner {
        stableToken.transfer(to, amount);
    }
}

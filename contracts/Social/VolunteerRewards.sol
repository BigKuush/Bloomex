// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract VolunteerRewards is Ownable {
    using SafeMath for uint256;

    IERC20 public stableToken; // USDT или USDC

    struct Activity {
        uint256 nftId;
        uint256 timestamp;
        uint256 rewardAmount;
        bool claimed;
    }

    mapping(address => Activity[]) public volunteerActivities;
    mapping(address => uint256) public totalRewards;

    uint256 public baseReward = 5 * 10**6; // 5 USDC (если 6 знаков)

    event ActivityLogged(address indexed volunteer, uint256 indexed nftId, uint256 rewardAmount);
    event RewardClaimed(address indexed volunteer, uint256 amount);

    constructor(address _stableToken) {
        stableToken = IERC20(_stableToken);
    }

    function logActivity(address _volunteer, uint256 _nftId, uint256 _timestamp) external onlyOwner {
        uint256 reward = calculateReward(_timestamp);

        volunteerActivities[_volunteer].push(
            Activity({
                nftId: _nftId,
                timestamp: _timestamp,
                rewardAmount: reward,
                claimed: false
            })
        );

        totalRewards[_volunteer] = totalRewards[_volunteer].add(reward);
        emit ActivityLogged(_volunteer, _nftId, reward);
    }

    function calculateReward(uint256 _timestamp) internal view returns (uint256) {
        // Можно добавить более сложную логику (ночная доставка, срочность и т.п.)
        return baseReward;
    }

    function claimReward() external {
        uint256 totalToClaim = 0;
        Activity[] storage activities = volunteerActivities[msg.sender];

        for (uint256 i = 0; i < activities.length; i++) {
            if (!activities[i].claimed) {
                totalToClaim = totalToClaim.add(activities[i].rewardAmount);
                activities[i].claimed = true;
            }
        }

        require(totalToClaim > 0, "No rewards to claim");
        require(stableToken.balanceOf(address(this)) >= totalToClaim, "Insufficient contract balance");

        stableToken.transfer(msg.sender, totalToClaim);
        emit RewardClaimed(msg.sender, totalToClaim);
    }

    function setBaseReward(uint256 _amount) external onlyOwner {
        baseReward = _amount;
    }

    function withdrawTokens(address _to, uint256 _amount) external onlyOwner {
        stableToken.transfer(_to, _amount);
    }

    function getPendingReward(address _volunteer) external view returns (uint256) {
        uint256 pending = 0;
        Activity[] storage activities = volunteerActivities[_volunteer];

        for (uint256 i = 0; i < activities.length; i++) {
            if (!activities[i].claimed) {
                pending = pending.add(activities[i].rewardAmount);
            }
        }

        return pending;
    }
}
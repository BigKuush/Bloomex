// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract IDOInvestmentPool is Ownable {
    enum PoolStatus { Open, Funded, Successful, Failed }

    struct Pool {
        address farmer;
        uint256 targetAmount;
        uint256 totalInvested;
        uint256 deadline;
        PoolStatus status;
        mapping(address => uint256) contributions;
        address[] investors;
        uint256 rewardPercent; // 5 = 5% возврат инвестору
    }

    uint256 public poolCount;
    IERC20 public stableToken; // USDC / USDT

    mapping(uint256 => Pool) public pools;

    event PoolCreated(uint256 poolId, address farmer, uint256 targetAmount, uint256 deadline);
    event Invested(uint256 poolId, address investor, uint256 amount);
    event Finalized(uint256 poolId, bool success);

    constructor(address _stableToken) Ownable(msg.sender) {
        stableToken = IERC20(_stableToken);
    }

    function createPool(
        uint256 targetAmount,
        uint256 durationDays,
        uint256 rewardPercent
    ) external returns (uint256) {
        require(targetAmount > 0, "Invalid target");
        require(durationDays > 0, "Invalid duration");

        poolCount++;
        Pool storage p = pools[poolCount];
        p.farmer = msg.sender;
        p.targetAmount = targetAmount;
        p.deadline = block.timestamp + durationDays * 1 days;
        p.status = PoolStatus.Open;
        p.rewardPercent = rewardPercent;

        emit PoolCreated(poolCount, msg.sender, targetAmount, p.deadline);
        return poolCount;
    }

    function invest(uint256 poolId, uint256 amount) external {
        Pool storage p = pools[poolId];
        require(p.status == PoolStatus.Open, "Pool not open");
        require(block.timestamp < p.deadline, "Deadline passed");

        stableToken.transferFrom(msg.sender, address(this), amount);

        if (p.contributions[msg.sender] == 0) {
            p.investors.push(msg.sender);
        }

        p.contributions[msg.sender] += amount;
        p.totalInvested += amount;

        emit Invested(poolId, msg.sender, amount);

        if (p.totalInvested >= p.targetAmount) {
            p.status = PoolStatus.Funded;
        }
    }

    function finalizePool(uint256 poolId, bool isSuccess) external onlyOwner {
        Pool storage p = pools[poolId];
        require(
            p.status == PoolStatus.Funded || block.timestamp >= p.deadline,
            "Not ready to finalize"
        );

        if (isSuccess) {
            p.status = PoolStatus.Successful;

            uint256 totalReward = (p.totalInvested * p.rewardPercent) / 100;
            uint256 totalTransfer = p.totalInvested - totalReward;

            stableToken.transfer(p.farmer, totalTransfer);

            // Платформа или фермер возвращают награды отдельно
        } else {
            p.status = PoolStatus.Failed;

            // Возврат инвесторам
            for (uint256 i = 0; i < p.investors.length; i++) {
                address investor = p.investors[i];
                uint256 amount = p.contributions[investor];
                if (amount > 0) {
                    stableToken.transfer(investor, amount);
                    p.contributions[investor] = 0;
                }
            }
        }

        emit Finalized(poolId, isSuccess);
    }

    function getPool(
        uint256 poolId
    ) external view returns (
        address farmer,
        uint256 targetAmount,
        uint256 totalInvested,
        uint256 deadline,
        PoolStatus status,
        uint256 rewardPercent
    ) {
        Pool storage p = pools[poolId];
        return (
            p.farmer,
            p.targetAmount,
            p.totalInvested,
            p.deadline,
            p.status,
            p.rewardPercent
        );
    }

    function getContribution(uint256 poolId, address investor) external view returns (uint256) {
        return pools[poolId].contributions[investor];
    }
}

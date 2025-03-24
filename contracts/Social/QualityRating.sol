// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title QualityRating
 * @dev Контракт для учета и обновления рейтинга фермеров и волонтёров на основе успешных действий и фидбэков
 */
contract QualityRating {
    enum Role { Farmer, Volunteer }

    struct Rating {
        uint256 successfulActions;
        uint256 feedbackCount;
        uint256 feedbackSum;
        uint256 verifiedCount;
    }

    mapping(address => Rating) private farmerRatings;
    mapping(address => Rating) private volunteerRatings;

    event RatingUpdated(address indexed user, Role role, uint256 newScore);

    modifier validRole(Role role) {
        require(uint8(role) <= 1, "Invalid role");
        _;
    }

    /**
     * @dev Регистрирует успешное действие (передача, верификация и т.д.)
     */
    function recordSuccess(address user, Role role) external validRole(role) {
        Rating storage r = _getRating(user, role);
        r.successfulActions++;
        emit RatingUpdated(user, role, calculateScore(user, role));
    }

    /**
     * @dev Добавляет фидбэк (оценку от 1 до 5)
     */
    function submitFeedback(address user, Role role, uint8 score) external validRole(role) {
        require(score >= 1 && score <= 5, "Invalid score");
        Rating storage r = _getRating(user, role);
        r.feedbackCount++;
        r.feedbackSum += score;
        emit RatingUpdated(user, role, calculateScore(user, role));
    }

    /**
     * @dev Регистрирует успешную верификацию
     */
    function recordVerification(address user, Role role) external validRole(role) {
        Rating storage r = _getRating(user, role);
        r.verifiedCount++;
        emit RatingUpdated(user, role, calculateScore(user, role));
    }

    /**
     * @dev Возвращает итоговый рейтинг пользователя
     */
    function calculateScore(address user, Role role) public view returns (uint256) {
        Rating storage r = _getRating(user, role);
        if (r.feedbackCount == 0 && r.successfulActions == 0 && r.verifiedCount == 0) {
            return 0;
        }

        uint256 avgFeedback = r.feedbackCount > 0 ? (r.feedbackSum * 1e18) / r.feedbackCount : 0;
        return (r.successfulActions * 2 + r.verifiedCount * 3 + avgFeedback) / 6; // весовая формула
    }

    function _getRating(address user, Role role) internal view returns (Rating storage) {
        if (role == Role.Farmer) {
            return farmerRatings[user];
        } else {
            return volunteerRatings[user];
        }
    }

    /**
     * @dev Получить полную информацию по рейтингу
     */
    function getRating(address user, Role role) external view returns (
        uint256 successfulActions,
        uint256 feedbackCount,
        uint256 feedbackSum,
        uint256 verifiedCount,
        uint256 score
    ) {
        Rating storage r = _getRating(user, role);
        return (
            r.successfulActions,
            r.feedbackCount,
            r.feedbackSum,
            r.verifiedCount,
            calculateScore(user, role)
        );
    }
}

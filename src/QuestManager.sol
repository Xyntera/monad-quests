// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./QuestXP.sol";
import "./QuestBadges.sol";

/// @title QuestManager
/// @notice Manages quests (daily and one-time), mints XP rewards, tracks user stats,
///         and notifies the QuestBadges contract to award badges.
/// @dev The QuestXP contract should have its ownership transferred to this contract
///      so that `xpToken.mint(...)` can be called from `completeQuest`.
contract QuestManager is Ownable, ReentrancyGuard {
    /// @notice Represents a quest definition
    struct Quest {
        uint256 id;
        string title;
        string description;
        uint256 rewardXP; // 18 decimals; e.g. 10 XP = 10e18
        bool active;
        bool isDaily;
    }

    /// @notice XP token used for rewards (QuestXP)
    QuestXP public xpToken;

    /// @notice Badge contract (QuestBadges)
    QuestBadges public badges;

    /// @notice Next quest ID to assign (starts at 1)
    uint256 public nextQuestId = 1;

    /// @notice questId => Quest
    mapping(uint256 => Quest) public quests;

    /// @notice user => questId => completed (for non-daily quests where only once)
    mapping(address => mapping(uint256 => bool)) public completedOnce;

    /// @notice user => last daily check-in day index (timestamp / 1 days)
    mapping(address => uint256) public lastDailyCheckinDay;

    /// @notice user => current daily streak (in days)
    mapping(address => uint256) public currentStreak;

    /// @notice user => total quests completed (including daily completions)
    mapping(address => uint256) public totalCompleted;

    // ---------------- Events ----------------

    event QuestCreated(
        uint256 indexed questId,
        string title,
        uint256 rewardXP,
        bool isDaily
    );

    event QuestUpdated(
        uint256 indexed questId,
        string title,
        uint256 rewardXP,
        bool active,
        bool isDaily
    );

    event QuestCompleted(
        address indexed user,
        uint256 indexed questId,
        uint256 rewardXP
    );

    event DailyCheckin(
        address indexed user,
        uint256 dayIndex,
        uint256 newStreak
    );

    event XPTokenUpdated(address indexed newXPToken);
    event BadgesContractUpdated(address indexed newBadgesContract);

    // ---------------- Constructor ----------------

    /// @param xpToken_ Address of deployed QuestXP contract
    /// @param badges_ Address of deployed QuestBadges contract
    constructor(address xpToken_, address badges_) {
        require(xpToken_ != address(0), "QuestManager: xp token zero");
        require(badges_ != address(0), "QuestManager: badges zero");
        xpToken = QuestXP(xpToken_);
        badges = QuestBadges(badges_);
    }

    // ---------------- Admin / Config ----------------

    /// @notice Update the QuestXP token contract (for migrations)
    /// @param xpToken_ New QuestXP contract address
    function setXPToken(address xpToken_) external onlyOwner {
        require(xpToken_ != address(0), "QuestManager: xp token zero");
        xpToken = QuestXP(xpToken_);
        emit XPTokenUpdated(xpToken_);
    }

    /// @notice Update the QuestBadges contract address
    /// @param badges_ New QuestBadges contract address
    function setBadgesContract(address badges_) external onlyOwner {
        require(badges_ != address(0), "QuestManager: badges zero");
        badges = QuestBadges(badges_);
        emit BadgesContractUpdated(badges_);
    }

    /// @notice Create a new quest
    /// @dev Only owner (admin) can create quests
    /// @param title Short title for the quest
    /// @param description Longer description for the quest UI
    /// @param rewardXP XP reward in wei (18 decimals)
    /// @param isDaily Whether quest is a daily (once per day) quest
    /// @return questId Newly created quest ID
    function createQuest(
        string calldata title,
        string calldata description,
        uint256 rewardXP,
        bool isDaily
    ) external onlyOwner returns (uint256 questId) {
        require(bytes(title).length > 0, "QuestManager: title empty");
        require(rewardXP > 0, "QuestManager: reward zero");

        questId = nextQuestId++;
        quests[questId] = Quest({
            id: questId,
            title: title,
            description: description,
            rewardXP: rewardXP,
            active: true,
            isDaily: isDaily
        });

        emit QuestCreated(questId, title, rewardXP, isDaily);
    }

    /// @notice Update an existing quest
    /// @param questId Quest ID to update
    /// @param title New title
    /// @param description New description
    /// @param rewardXP New reward amount (in wei)
    /// @param active Whether the quest is active
    /// @param isDaily Whether the quest is daily
    function updateQuest(
        uint256 questId,
        string calldata title,
        string calldata description,
        uint256 rewardXP,
        bool active,
        bool isDaily
    ) external onlyOwner {
        Quest storage q = quests[questId];
        require(q.id != 0, "QuestManager: quest does not exist");
        require(bytes(title).length > 0, "QuestManager: title empty");
        require(rewardXP > 0, "QuestManager: reward zero");

        q.title = title;
        q.description = description;
        q.rewardXP = rewardXP;
        q.active = active;
        q.isDaily = isDaily;

        emit QuestUpdated(questId, title, rewardXP, active, isDaily);
    }

    /// @notice Activate or deactivate a quest
    /// @param questId Quest ID
    /// @param active True to activate, false to deactivate
    function setQuestActive(uint256 questId, bool active) external onlyOwner {
        Quest storage q = quests[questId];
        require(q.id != 0, "QuestManager: quest does not exist");
        q.active = active;

        emit QuestUpdated(questId, q.title, q.rewardXP, q.active, q.isDaily);
    }

    // ---------------- User Actions ----------------

    /// @notice Complete a quest and receive XP reward.
    /// @dev For daily quests: only once per day. For other quests: only once ever per user.
    ///      After minting XP, badges.awardBadges(...) is called to attempt awarding badges.
    /// @param questId Quest identifier
    function completeQuest(uint256 questId) external nonReentrant {
        Quest memory q = quests[questId];
        require(q.id != 0, "QuestManager: quest does not exist");
        require(q.active, "QuestManager: quest inactive");

        if (q.isDaily) {
            _handleDailyQuest(msg.sender);
        } else {
            _handleOneTimeQuest(msg.sender, questId);
        }

        // increment user's totalCompleted
        totalCompleted[msg.sender] += 1;

        // Mint XP to user - this contract is expected to be the owner/minter of xpToken
        xpToken.mint(msg.sender, q.rewardXP);

        emit QuestCompleted(msg.sender, questId, q.rewardXP);

        // Notify badges contract to try awarding badges using fresh stats
        uint256 xpBalance = xpToken.balanceOf(msg.sender);
        badges.awardBadges(
            msg.sender,
            currentStreak[msg.sender],
            totalCompleted[msg.sender],
            xpBalance
        );
    }

    /// @dev Internal logic for daily quest enforcement
    function _handleDailyQuest(address user) internal {
        uint256 today = block.timestamp / 1 days;
        uint256 lastDay = lastDailyCheckinDay[user];

        require(lastDay < today, "QuestManager: already checked in today");

        if (lastDay == today - 1) {
            // continued streak
            currentStreak[user] += 1;
        } else {
            // reset streak
            currentStreak[user] = 1;
        }

        lastDailyCheckinDay[user] = today;

        emit DailyCheckin(user, today, currentStreak[user]);
    }

    /// @dev Internal logic for one-time quests
    function _handleOneTimeQuest(address user, uint256 questId) internal {
        require(!completedOnce[user][questId], "QuestManager: quest already completed");
        completedOnce[user][questId] = true;
    }

    // ---------------- Views ----------------

    /// @notice Get simple user stats
    /// @param user Address to query
    /// @return xp XP balance (from QuestXP)
    /// @return streak Current daily streak
    /// @return total Total quests completed
    /// @return lastCheckinDay Last daily check-in day index
    function getUserStats(address user)
        external
        view
        returns (
            uint256 xp,
            uint256 streak,
            uint256 total,
            uint256 lastCheckinDay
        )
    {
        xp = xpToken.balanceOf(user);
        streak = currentStreak[user];
        total = totalCompleted[user];
        lastCheckinDay = lastDailyCheckinDay[user];
    }

    /// @notice Retrieve a quest by id
    /// @param questId Quest identifier
    /// @return Quest struct
    function getQuest(uint256 questId) external view returns (Quest memory) {
        require(quests[questId].id != 0, "QuestManager: quest does not exist");
        return quests[questId];
    }

    /// @notice Retrieve quests in a (inclusive) id range. Useful for pagination.
    /// @dev `start` and `end` are quest ids (1-based). Reverts if start == 0 or end < start.
    /// @param start Starting quest id (inclusive)
    /// @param end Ending quest id (inclusive)
    /// @return result Array of Quest structs for existing quests in the range
    function getQuestsInRange(uint256 start, uint256 end) external view returns (Quest[] memory result) {
        require(start > 0, "QuestManager: start must be > 0");
        require(end >= start, "QuestManager: end < start");

        // Determine actual upper bound (don't exceed nextQuestId - 1)
        uint256 upper = end;
        if (upper >= nextQuestId) {
            upper = nextQuestId - 1;
        }

        // Count how many existent quests in range
        uint256 count = 0;
        for (uint256 i = start; i <= upper; i++) {
            if (quests[i].id != 0) {
                count++;
            }
        }

        result = new Quest[](count);
        uint256 idx = 0;
        for (uint256 i = start; i <= upper; i++) {
            if (quests[i].id != 0) {
                result[idx++] = quests[i];
            }
        }
    }

    // ---------------- Emergency / Admin Helpers ----------------

    /// @notice Recover any ETH accidentally sent to this contract
    /// @param to Recipient address
    /// @param amount Amount in wei
    function recoverETH(address payable to, uint256 amount) external onlyOwner {
        require(to != address(0), "QuestManager: to zero");
        to.transfer(amount);
    }

    /// @notice Recover ERC20 tokens accidentally sent to this contract (except XP token)
    /// @param token Token contract address
    /// @param to Recipient address
    /// @param amount Amount to recover
    function recoverERC20(address token, address to, uint256 amount) external onlyOwner {
        require(to != address(0), "QuestManager: to zero");
        require(token != address(xpToken), "QuestManager: cannot recover XP token");
        // Using low-level transfer; token must conform to ERC20
        bool success = IERC20(token).transfer(to, amount);
        require(success, "QuestManager: transfer failed");
    }

    // Fallback / receive to allow ETH transfers if needed
    receive() external payable {}
    fallback() external payable {}
}


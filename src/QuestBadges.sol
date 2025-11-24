// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/// @title QuestBadges
/// @notice ERC721 NFT Badge Collection for Monad Quests and Game Achievements
/// @dev QuestManager is authorized to mint badges using the awardBadges function.
///      Badge rules define thresholds for XP, streak, and total quest completions.
contract QuestBadges is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    /// -----------------------------
    /// Enums & Data Structures
    /// -----------------------------

    /// @notice Supported badge types
    enum BadgeType {
        SevenDayStreak,
        ThirtyCompletions,
        HundredXP
    }

    /// @notice Rules that determine automatic badge awarding
    struct BadgeRule {
        bool active;                 // Whether this badge is currently awardable
        uint256 xpThreshold;         // XP requirement (0 = ignore)
        uint256 streakThreshold;     // Streak requirement (0 = ignore)
        uint256 totalQuestsThreshold;// Total completions requirement (0 = ignore)
        string metadataURI;          // Full IPFS/HTTPS metadata URI
    }

    /// -----------------------------
    /// State Variables
    /// -----------------------------

    /// @notice Rules for each badge type
    mapping(BadgeType => BadgeRule) public badgeRules;

    /// @notice Mapping: user -> badgeType -> hasBadge
    mapping(address => mapping(BadgeType => bool)) public hasBadge;

    /// @notice Mapping: tokenId -> badgeType
    mapping(uint256 => BadgeType) public badgeTypeOfTokenId;

    /// @notice Token ID counter (incremental)
    Counters.Counter private _tokenIdCounter;

    /// @notice Address allowed to mint badges (QuestManager)
    address public questManager;

    /// -----------------------------
    /// Events
    /// -----------------------------

    event QuestManagerUpdated(address indexed newManager);

    event BadgeRuleUpdated(
        BadgeType indexed badgeType,
        bool active,
        uint256 xpThreshold,
        uint256 streakThreshold,
        uint256 totalQuestsThreshold,
        string metadataURI
    );

    event BadgeMinted(
        address indexed user,
        uint256 indexed tokenId,
        BadgeType indexed badgeType
    );

    /// -----------------------------
    /// Modifiers
    /// -----------------------------

    /// @notice Restricts minting functions to QuestManager
    modifier onlyQuestManager() {
        require(msg.sender == questManager, "QuestBadges: not quest manager");
        _;
    }

    /// -----------------------------
    /// Constructor
    /// -----------------------------

    /// @param name_ ERC721 token name
    /// @param symbol_ ERC721 token symbol
    constructor(
        string memory name_,
        string memory symbol_
    ) ERC721(name_, symbol_) {}

    /// -----------------------------
    /// Admin Functions
    /// -----------------------------

    /// @notice Sets the QuestManager which is allowed to award badges
    /// @param _questManager Address of QuestManager
    function setQuestManager(address _questManager) external onlyOwner {
        require(_questManager != address(0), "QuestBadges: manager zero");
        questManager = _questManager;
        emit QuestManagerUpdated(_questManager);
    }

    /// @notice Defines and updates rules for each badge type
    function setBadgeRule(
        BadgeType badgeType,
        bool active,
        uint256 xpThreshold,
        uint256 streakThreshold,
        uint256 totalQuestsThreshold,
        string calldata metadataURI
    ) external onlyOwner {
        badgeRules[badgeType] = BadgeRule({
            active: active,
            xpThreshold: xpThreshold,
            streakThreshold: streakThreshold,
            totalQuestsThreshold: totalQuestsThreshold,
            metadataURI: metadataURI
        });

        emit BadgeRuleUpdated(
            badgeType,
            active,
            xpThreshold,
            streakThreshold,
            totalQuestsThreshold,
            metadataURI
        );
    }

    /// -----------------------------
    /// Award Logic (QuestManager only)
    /// -----------------------------

    /// @notice Automatically awards all eligible badges to a user
    /// @param user Player address
    /// @param streak Current streak (from QuestManager)
    /// @param totalCompleted Total quests completed
    /// @param userXP Current XP balance
    function awardBadges(
        address user,
        uint256 streak,
        uint256 totalCompleted,
        uint256 userXP
    ) external onlyQuestManager {
        require(user != address(0), "QuestBadges: user zero");

        _attemptAward(user, BadgeType.SevenDayStreak, streak, totalCompleted, userXP);
        _attemptAward(user, BadgeType.ThirtyCompletions, streak, totalCompleted, userXP);
        _attemptAward(user, BadgeType.HundredXP, streak, totalCompleted, userXP);
    }

    /// @dev Internal check + mint
    function _attemptAward(
        address user,
        BadgeType badgeType,
        uint256 streak,
        uint256 totalCompleted,
        uint256 userXP
    ) internal {
        if (hasBadge[user][badgeType]) return;

        BadgeRule memory rule = badgeRules[badgeType];
        if (!rule.active) return;

        bool meets = true;

        if (rule.streakThreshold > 0 && streak < rule.streakThreshold) {
            meets = false;
        }
        if (rule.totalQuestsThreshold > 0 && totalCompleted < rule.totalQuestsThreshold) {
            meets = false;
        }
        if (rule.xpThreshold > 0 && userXP < rule.xpThreshold) {
            meets = false;
        }

        if (!meets) return;

        _mintBadge(user, badgeType, rule.metadataURI);
    }

    /// -----------------------------
    /// Internal Minting
    /// -----------------------------

    function _mintBadge(
        address user,
        BadgeType badgeType,
        string memory metadataURI
    ) internal {
        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();

        hasBadge[user][badgeType] = true;
        badgeTypeOfTokenId[tokenId] = badgeType;

        _safeMint(user, tokenId);

        // Optional metadata URI
        if (bytes(metadataURI).length > 0) {
            _setTokenURI(tokenId, metadataURI);
        }

        emit BadgeMinted(user, tokenId, badgeType);
    }

    /// -----------------------------
    /// View Functions
    /// -----------------------------

    /// @notice Get total supply (current highest tokenId)
    function totalSupply() external view returns (uint256) {
        return _tokenIdCounter.current();
    }
}


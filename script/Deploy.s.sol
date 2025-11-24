// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

/*
Deploy.s.sol

Foundry deployment script for:
 - QuestXP (ERC20 XP token)
 - QuestBadges (ERC721 badges)
 - QuestManager (quest logic, mints XP & triggers badges)

Usage (example):
  export PRIVATE_KEY=0x...            # your deployer private key (avoid exposing this)
  forge script script/Deploy.s.sol:Deploy \
    --rpc-url https://testnet-rpc.monad.xyz \
    --broadcast \
    -vvvv

Notes:
 - The script expects PRIVATE_KEY as an environment variable (vm.envUint).
 - It will:
    1) Deploy QuestXP (owner = deployer)
    2) Deploy QuestBadges (owner = deployer)
    3) Deploy QuestManager (owner = deployer)
    4) Transfer ownership/minter rights of QuestXP to QuestManager
    5) Set QuestManager address in QuestBadges
    6) Seed a few badge rules (placeholders IPFS URIs)
    7) Create an initial daily check-in quest
 - After deployment, the QuestManager will be the only contract able to mint XP.
*/

import "forge-std/Script.sol";
import "forge-std/console2.sol";

import "../src/QuestXP.sol";
import "../src/QuestBadges.sol";
import "../src/QuestManager.sol";

contract Deploy is Script {
    function run() external {
        // Load deployer's private key from environment variable PRIVATE_KEY
        // (set as integer, e.g. export PRIVATE_KEY=0xabc... or use numeric)
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        require(deployerKey != 0, "PRIVATE_KEY env var not set or zero");

        // Start broadcasting transactions with the deployer key
        vm.startBroadcast(deployerKey);

        address deployer = vm.addr(deployerKey);
        console2.log("Deployer address:", deployer);

        // 1) Deploy QuestXP (initial owner = deployer)
        QuestXP xp = new QuestXP("Monad Quest XP", "MQXP", deployer);
        console2.log("QuestXP deployed at:", address(xp));

        // 2) Deploy QuestBadges (owner = deployer)
        QuestBadges badges = new QuestBadges("Monad Quest Badges", "MQB");
        console2.log("QuestBadges deployed at:", address(badges));

        // 3) Deploy QuestManager (points to xp & badges)
        QuestManager manager = new QuestManager(address(xp), address(badges));
        console2.log("QuestManager deployed at:", address(manager));

        // 4) Transfer ownership / permissions
        // Transfer QuestXP ownership to QuestManager so it can mint XP
        xp.transferOwnership(address(manager));
        console2.log("Transferred QuestXP ownership to QuestManager");

        // Set QuestManager in QuestBadges so QuestManager can award badges
        badges.setQuestManager(address(manager));
        console2.log("Set QuestManager in QuestBadges");

        // 5) Configure example badge rules (you can update these later via onlyOwner)
        // Seven-day streak badge
        try
            badges.setBadgeRule(
                QuestBadges.BadgeType.SevenDayStreak,
                true, // active
                0, // xpThreshold
                7, // streakThreshold
                0, // totalQuestsThreshold
                "ipfs://QmPlaceholderSevenDayStreakMetadata" // placeholder URI
            )
        {} catch {
            console2.log("Warning: setBadgeRule (SevenDayStreak) failed");
        }

        // 30 completions badge
        try
            badges.setBadgeRule(
                QuestBadges.BadgeType.ThirtyCompletions,
                true,
                0,
                0,
                30,
                "ipfs://QmPlaceholderThirtyCompletionsMetadata"
            )
        {} catch {
            console2.log("Warning: setBadgeRule (ThirtyCompletions) failed");
        }

        // 100 XP badge
        try
            badges.setBadgeRule(
                QuestBadges.BadgeType.HundredXP,
                true,
                100e18, // 100 XP, using 18 decimals
                0,
                0,
                "ipfs://QmPlaceholderHundredXPMetadata"
            )
        {} catch {
            console2.log("Warning: setBadgeRule (HundredXP) failed");
        }

        // 6) Seed a basic daily check-in quest (admin only)
        try
            manager.createQuest(
                "Daily check-in",
                "Return each day to collect XP and keep your streak.",
                10e18, // 10 XP
                true // isDaily
            )
        {} catch {
            console2.log("Warning: createQuest (Daily check-in) failed");
        }

        // You might want to add additional one-time quests for onboarding:
        // e.g. manager.createQuest("Complete first quest", "Do your first on-chain action", 20e18, false);

        vm.stopBroadcast();

        console2.log("=== Deployment Summary ===");
        console2.log("Deployer:", deployer);
        console2.log("QuestXP:", address(xp));
        console2.log("QuestBadges:", address(badges));
        console2.log("QuestManager:", address(manager));
        console2.log("=== End Summary ===");
    }
}


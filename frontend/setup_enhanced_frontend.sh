#!/bin/bash

# Enhanced Monad Quests Frontend Setup Script
echo "Creating enhanced frontend with Pixel Conquest game..."

# Create .env.local with deployed contract addresses
cat > .env.local << 'EOF'
NEXT_PUBLIC_MONAD_RPC=https://testnet-rpc.monad.xyz
NEXT_PUBLIC_MONAD_CHAIN_ID=10143
NEXT_PUBLIC_QUEST_MANAGER_ADDRESS=0x9da14b9ca1a11ca16e2a3e3ad4e3a19ae6663cc7
NEXT_PUBLIC_QUEST_XP_ADDRESS=0x649316D0c7b5988f8d36ab26917e92e625f20a5d
NEXT_PUBLIC_BADGES_ADDRESS=0x74db620b1dd72b7e5539fc5cff8ec7e4ebc60b22
NEXT_PUBLIC_EXPLORER=https://testnet.monadvision.com
NEXT_PUBLIC_PIXEL_GAME_ADDRESS=
EOF

echo "Created .env.local"

# Create lib/contracts.ts with all contract addresses and ABIs
mkdir -p lib
cat > lib/contracts.ts << 'EOF'
// File: lib/contracts.ts
import type { Abi } from "viem";
import type { Address } from "viem";

export const QUEST_MANAGER_ADDRESS = (process.env.NEXT_PUBLIC_QUEST_MANAGER_ADDRESS ??
  "0x9da14b9ca1a11ca16e2a3e3ad4e3a19ae6663cc7") as Address;

export const QUEST_XP_ADDRESS = (process.env.NEXT_PUBLIC_QUEST_XP_ADDRESS ??
  "0x649316D0c7b5988f8d36ab26917e92e625f20a5d") as Address;

export const BADGES_ADDRESS = (process.env.NEXT_PUBLIC_BADGES_ADDRESS ??
  "0x74db620b1dd72b7e5539fc5cff8ec7e4ebc60b22") as Address;

export const PIXEL_GAME_ADDRESS = (process.env.NEXT_PUBLIC_PIXEL_GAME_ADDRESS ??
  "") as Address;

// QuestManager ABI
export const questManagerAbi: Abi = [
  {
    type: "function",
    name: "completeQuest",
    stateMutability: "nonpayable",
    inputs: [{ name: "questId", type: "uint256" }],
    outputs: [],
  },
  {
    type: "function",
    name: "getUserStats",
    stateMutability: "view",
    inputs: [{ name: "user", type: "address" }],
    outputs: [
      { name: "xpBalance", type: "uint256" },
      { name: "streak", type: "uint256" },
      { name: "totalCompleted", type: "uint256" },
    ],
  },
  {
    type: "function",
    name: "quests",
    stateMutability: "view",
    inputs: [{ name: "questId", type: "uint256" }],
    outputs: [
      { name: "id", type: "uint256" },
      { name: "title", type: "string" },
      { name: "description", type: "string" },
      { name: "rewardXP", type: "uint256" },
      { name: "active", type: "bool" },
      { name: "isDaily", type: "bool" },
    ],
  },
  {
    type: "event",
    name: "QuestCompleted",
    inputs: [
      { name: "user", type: "address", indexed: true },
      { name: "questId", type: "uint256", indexed: true },
      { name: "rewardXP", type: "uint256", indexed: false },
    ],
  },
];

// QuestXP (ERC20) ABI
export const questXpAbi: Abi = [
  {
    type: "function",
    name: "balanceOf",
    stateMutability: "view",
    inputs: [{ name: "account", type: "address" }],
    outputs: [{ name: "", type: "uint256" }],
  },
  {
    type: "function",
    name: "totalSupply",
    stateMutability: "view",
    inputs: [],
    outputs: [{ name: "", type: "uint256" }],
  },
];

// QuestBadges (ERC721) ABI
export const badgesAbi: Abi = [
  {
    type: "function",
    name: "balanceOf",
    stateMutability: "view",
    inputs: [{ name: "owner", type: "address" }],
    outputs: [{ name: "", type: "uint256" }],
  },
  {
    type: "function",
    name: "tokenOfOwnerByIndex",
    stateMutability: "view",
    inputs: [
      { name: "owner", type: "address" },
      { name: "index", type: "uint256" },
    ],
    outputs: [{ name: "", type: "uint256" }],
  },
];

// PixelConquestGame minimal ABI
export const pixelGameAbi: Abi = [
  {
    type: "function",
    name: "width",
    stateMutability: "view",
    inputs: [],
    outputs: [{ type: "uint256" }],
  },
  {
    type: "function",
    name: "height",
    stateMutability: "view",
    inputs: [],
    outputs: [{ type: "uint256" }],
  },
  {
    type: "function",
    name: "tiles",
    stateMutability: "view",
    inputs: [{ name: "", type: "uint256" }],
    outputs: [
      { name: "owner", type: "address" },
      { name: "level", type: "uint32" },
      { name: "lastUpdated", type: "uint64" },
    ],
  },
  {
    type: "function",
    name: "playerScore",
    stateMutability: "view",
    inputs: [{ name: "player", type: "address" }],
    outputs: [{ type: "uint256" }],
  },
  {
    type: "function",
    name: "claimTile",
    stateMutability: "nonpayable",
    inputs: [{ name: "tileId", type: "uint256" }],
    outputs: [],
  },
  {
    type: "function",
    name: "conquerTile",
    stateMutability: "nonpayable",
    inputs: [{ name: "tileId", type: "uint256" }],
    outputs: [],
  },
  {
    type: "function",
    name: "topPlayersCount",
    stateMutability: "view",
    inputs: [],
    outputs: [{ type: "uint256" }],
  },
  {
    type: "function",
    name: "topPlayers",
    stateMutability: "view",
    inputs: [{ name: "i", type: "uint256" }],
    outputs: [{ type: "address" }],
  },
  {
    type: "event",
    name: "TileClaimed",
    inputs: [
      { name: "player", type: "address", indexed: true },
      { name: "tileId", type: "uint256", indexed: true },
    ],
    anonymous: false,
  },
  {
    type: "event",
    name: "TileConquered",
    inputs: [
      { name: "player", type: "address", indexed: true },
      { name: "tileId", type: "uint256", indexed: true },
      { name: "prevOwner", type: "address", indexed: true },
    ],
    anonymous: false,
  },
];
EOF

echo "Created lib/contracts.ts"

echo "\nAll files created successfully!"
echo "Next steps:"
echo "1. Review .env.local (contract addresses are already set)"
echo "2. Run 'npm run dev' to start the development server"
echo "3. Deploy to Vercel by pushing to GitHub"


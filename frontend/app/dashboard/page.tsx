"use client";

import React from "react";
import { useAccount, useReadContract } from "wagmi";
import { formatEther } from "viem";
import {
  QUEST_MANAGER_ADDRESS,
  QUEST_XP_ADDRESS,
  BADGES_ADDRESS,
  questManagerAbi,
  questXpAbi,
  badgesAbi
} from "@/lib/contracts";

export default function DashboardPage() {
  const { address, isConnected } = useAccount();

  // Read user's stats from QuestManager
  const {
    data: statsData,
    isLoading: statsLoading,
    error: statsError,
    refetch: refetchStats
  } = useReadContract({
    address: QUEST_MANAGER_ADDRESS,
    abi: questManagerAbi,
    functionName: "getUserStats",
    args: address ? [address] : undefined,
    query: {
      enabled: Boolean(address)
    }
  });

  // Read XP token balance
  const {
    data: xpBalanceData,
    isLoading: xpLoading,
    error: xpError
  } = useReadContract({
    address: QUEST_XP_ADDRESS,
    abi: questXpAbi,
    functionName: "balanceOf",
    args: address ? [address] : undefined,
    query: {
      enabled: Boolean(address)
    }
  });

  // Fetch badges for types 0, 1, 2
  const badgeTypes = [0, 1, 2];
  const badge0 = useReadContract({
    address: BADGES_ADDRESS,
    abi: badgesAbi,
    functionName: "hasBadge",
    args: address ? [address, 0] : undefined,
    query: { enabled: Boolean(address) }
  });
  
  const badge1 = useReadContract({
    address: BADGES_ADDRESS,
    abi: badgesAbi,
    functionName: "hasBadge",
    args: address ? [address, 1] : undefined,
    query: { enabled: Boolean(address) }
  });
  
  const badge2 = useReadContract({
    address: BADGES_ADDRESS,
    abi: badgesAbi,
    functionName: "hasBadge",
    args: address ? [address, 2] : undefined,
    query: { enabled: Boolean(address) }
  });

  const badgeReads = [badge0, badge1, badge2];

  // Parse data
  const xp = xpBalanceData ? BigInt(xpBalanceData as any) : 0n;
  const statsArray = statsData as any;
  const streak = statsArray ? BigInt(statsArray[1]) : 0n;
  const totalCompleted = statsArray ? BigInt(statsArray[2]) : 0n;

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-semibold">Dashboard</h1>
        <p className="text-sm text-slate-400 mt-1">
          Your XP, streak, and badges from QuestManager / QuestXP / QuestBadges.
        </p>
      </div>

      {!isConnected ? (
        <div className="card">
          <p className="text-sm text-slate-300">Connect your wallet to view on-chain stats.</p>
        </div>
      ) : (
        <>
          <div className="grid gap-4 md:grid-cols-3">
            <div className="card">
              <p className="text-xs text-slate-400">Total XP</p>
              <p className="text-2xl font-semibold mt-2">
                {xpLoading ? "Loading..." : `${formatEther(xp)} XP`}
              </p>
              {xpError && <p className="text-xs text-rose-400 mt-2">Failed to load XP balance</p>}
            </div>

            <div className="card">
              <p className="text-xs text-slate-400">Current Streak</p>
              <p className="text-2xl font-semibold mt-2">
                {statsLoading ? "Loading..." : `${streak?.toString() || "0"} days`}
              </p>
              {statsError && <p className="text-xs text-rose-400 mt-2">Failed to load streak</p>}
            </div>

            <div className="card">
              <p className="text-xs text-slate-400">Quests Completed</p>
              <p className="text-2xl font-semibold mt-2">
                {statsLoading ? "Loading..." : `${totalCompleted?.toString() || "0"}`}
              </p>
              {statsError && <p className="text-xs text-rose-400 mt-2">Failed to load completed count</p>}
            </div>
          </div>

          <div className="grid md:grid-cols-2 gap-4">
            <div className="card">
              <p className="text-sm font-semibold text-slate-100 mb-3">Badges</p>
              <div className="space-y-2">
                {badgeTypes.map((b, i) => {
                  const r = badgeReads[i];
                  return (
                    <div key={b} className="flex items-center justify-between">
                      <div>
                        <p className="text-sm">
                          {b === 0 ? "7-day Streak" : b === 1 ? "30 Completions" : "100 XP"}
                        </p>
                        <p className="text-xs text-slate-400">Badge type #{b}</p>
                      </div>
                      <div>
                        {r.isLoading ? (
                          <p className="text-xs text-slate-400">loading…</p>
                        ) : r.error ? (
                          <p className="text-xs text-rose-400">error</p>
                        ) : r.data ? (
                          <p className="text-xs text-emerald-400 font-medium">Unlocked</p>
                        ) : (
                          <p className="text-xs text-slate-500">Locked</p>
                        )}
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>

            <div className="card">
              <p className="text-sm font-semibold text-slate-100 mb-3">Quick Actions</p>
              <div className="space-y-2 text-sm text-slate-300">
                <button
                  className="btn-primary"
                  onClick={() => {
                    refetchStats();
                  }}
                >
                  Refresh Stats
                </button>
                <p className="text-xs text-slate-400 mt-2">
                  Tip: Visit Quests and click a quest to trigger completeQuest transactions that mint XP.
                </p>
              </div>
            </div>
          </div>
        </>
      )}
    </div>
  );
}

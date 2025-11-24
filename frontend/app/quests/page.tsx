"use client";

import React, { useEffect, useState } from "react";
import { useAccount, useReadContract, useWriteContract, useWaitForTransactionReceipt } from "wagmi";
import { QUEST_MANAGER_ADDRESS, questManagerAbi } from "@/lib/contracts";

export default function QuestsPage() {
  const { address, isConnected } = useAccount();
  const [quests, setQuests] = useState<any[]>([]);
  const [loading, setLoading] = useState(false);

  // Read nextQuestId
  const { data: nextQuestIdData } = useReadContract({
    address: QUEST_MANAGER_ADDRESS,
    abi: questManagerAbi,
    functionName: "nextQuestId",
  });

  const nextQuestId = nextQuestIdData ? Number(nextQuestIdData) : 1;

  // Write contract for completing quests
  const { writeContract, data: hash, error, isPending } = useWriteContract();

  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({
    hash,
  });

  useEffect(() => {
    async function loadQuests() {
      setLoading(true);
      const list: any[] = [];
      // For demo, just show quest ID 1 (daily check-in)
      list.push({
        id: 1,
        title: "Daily Check-in",
        description: "Come back every day and claim your XP.",
        rewardXP: "10",
        active: true,
        isDaily: true
      });
      setQuests(list);
      setLoading(false);
    }
    loadQuests();
  }, [nextQuestId]);

  function handleComplete(questId: number) {
    if (!isConnected) return alert("Connect wallet to complete a quest.");
    writeContract({
      address: QUEST_MANAGER_ADDRESS,
      abi: questManagerAbi,
      functionName: "completeQuest",
      args: [BigInt(questId)],
    });
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-semibold">Quests</h1>
        <p className="text-sm text-slate-400 mt-1">
          Complete daily and one-time quests to earn XP.
        </p>
      </div>

      {!isConnected ? (
        <div className="card">
          <p className="text-sm text-slate-300">Connect your wallet to complete quests.</p>
        </div>
      ) : null}

      {loading ? (
        <div className="card">Loading quests...</div>
      ) : quests.length === 0 ? (
        <div className="card text-slate-400">No quests available.</div>
      ) : (
        <div className="space-y-3">
          {quests.map((q) => (
            <div key={q.id} className="card flex flex-col md:flex-row md:items-center md:justify-between gap-3">
              <div>
                <div className="flex items-center gap-2">
                  <p className="font-semibold text-slate-100">{q.title}</p>
                  {q.isDaily && <span className="text-xs text-slate-400 px-2 py-0.5 rounded bg-slate-800">Daily</span>}
                </div>
                <p className="text-sm text-slate-400 mt-1">{q.description}</p>
              </div>
              <div className="flex flex-col items-start md:items-end gap-2">
                <p className="text-xs text-slate-400">
                  Reward: <span className="font-semibold">{q.rewardXP} XP</span>
                </p>
                <button
                  disabled={isPending || isConfirming}
                  onClick={() => handleComplete(q.id)}
                  className="btn-primary"
                >
                  {isPending || isConfirming ? "Processing..." : "Complete Quest"}
                </button>
                {isSuccess && <p className="text-xs text-emerald-400">Quest completed!</p>}
                {error && <p className="text-xs text-rose-400">Error: {error.message}</p>}
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

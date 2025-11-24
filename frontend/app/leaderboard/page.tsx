"use client";

import React, { useState } from "react";
import { useAccount } from "wagmi";

export default function LeaderboardPage() {
  const { address } = useAccount();
  
  // Demo leaderboard data
  const [top] = useState([
    { address: "0x1234...5678", score: 1250 },
    { address: "0xabcd...ef01", score: 980 },
    { address: "0x9876...5432", score: 750 },
    { address: "0xdef0...1234", score: 620 },
    { address: "0x5678...90ab", score: 450 },
  ]);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-semibold">Leaderboard</h1>
        <p className="text-sm text-slate-400 mt-1">
          Top players by XP. This shows a demo leaderboard.
        </p>
      </div>

      <div className="card">
        <p className="text-sm text-slate-300 mb-3">Demo Leaderboard</p>
        <p className="text-sm text-slate-400 mb-4">
          Note: A real global leaderboard requires either on-chain storage of top players or an off-chain indexer.
          This demo shows placeholder data.
        </p>
        <div className="space-y-2">
          {top.map((p, i) => (
            <div key={p.address} className="flex items-center justify-between p-3 rounded-lg bg-slate-800/50">
              <div className="flex items-center gap-3">
                <div className="h-8 w-8 rounded-md bg-slate-700 flex items-center justify-center text-xs font-semibold">
                  #{i + 1}
                </div>
                <p className="truncate max-w-xs font-mono text-sm">{p.address}</p>
              </div>
              <p className="text-sm text-slate-300 font-semibold">{p.score} XP</p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

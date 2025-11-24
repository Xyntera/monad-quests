export default function Home() {
  const contracts = [
    {
      name: 'QuestXP (ERC20)',
      address: '0x649316D0c7b5988f8d36ab26917e92e625f20a5d',
      desc: 'XP Token Contract',
      emoji: '💰'
    },
    {
      name: 'QuestBadges (ERC721)',
      address: '0x74db620b1dd72b7e5539fc5cff8ec7e4ebc60b22',
      desc: 'NFT Badge Contract',
      emoji: '🏆'
    },
    {
      name: 'QuestManager',
      address: '0x9da14b9ca1a11ca16e2a3e3ad4e3a19ae6663cc7',
      desc: 'Quest Logic Contract',
      emoji: '⚙️'
    }
  ]

  return (
    <main className="min-h-screen p-8">
      <div className="max-w-4xl mx-auto">
        <div className="bg-white/10 backdrop-blur-lg rounded-3xl p-8 shadow-2xl">
          <h1 className="text-5xl font-bold text-center mb-4">🚀 Monad Quests</h1>
          <p className="text-center text-xl mb-8 opacity-90">Daily Quest & XP System with NFT Badges</p>
          
          <div className="bg-green-500/20 rounded-2xl p-6 mb-8 text-center">
            <div className="text-6xl mb-4">✅</div>
            <h2 className="text-3xl font-bold">Project is LIVE on Monad Testnet!</h2>
          </div>

          <div className="grid md:grid-cols-3 gap-6 mb-8">
            <div className="bg-white/5 rounded-xl p-6 text-center">
              <div className="text-4xl mb-3">💪</div>
              <h3 className="font-bold text-lg mb-2">Daily Quests</h3>
              <p className="text-sm opacity-80">Complete challenges</p>
            </div>
            <div className="bg-white/5 rounded-xl p-6 text-center">
              <div className="text-4xl mb-3">⭐</div>
              <h3 className="font-bold text-lg mb-2">Earn XP</h3>
              <p className="text-sm opacity-80">ERC20 tokens</p>
            </div>
            <div className="bg-white/5 rounded-xl p-6 text-center">
              <div className="text-4xl mb-3">🏆</div>
              <h3 className="font-bold text-lg mb-2">NFT Badges</h3>
              <p className="text-sm opacity-80">Achievement rewards</p>
            </div>
          </div>

          <div className="bg-white/5 rounded-2xl p-6 mb-8">
            <h2 className="text-2xl font-bold mb-6 flex items-center gap-2">
              <span>📜</span> Deployed Smart Contracts
            </h2>
            
            {contracts.map((contract, i) => (
              <div key={i} className="bg-black/20 rounded-xl p-4 mb-4 last:mb-0">
                <h3 className="font-bold text-lg mb-2 flex items-center gap-2">
                  <span>{contract.emoji}</span> {contract.name}
                </h3>
                <p className="text-sm opacity-70 mb-2">{contract.desc}</p>
                <code className="block bg-black/30 p-3 rounded-lg text-sm break-all">
                  {contract.address}
                </code>
              </div>
            ))}
          </div>

          <div className="bg-white/5 rounded-2xl p-6 mb-8">
            <h2 className="text-2xl font-bold mb-4 flex items-center gap-2">
              <span>🌐</span> Network Information
            </h2>
            <div className="space-y-2">
              <p><strong>Network:</strong> Monad Testnet</p>
              <p><strong>Chain ID:</strong> 10143</p>
              <p><strong>RPC URL:</strong> https://testnet-rpc.monad.xyz</p>
            </div>
          </div>

          <div className="text-center opacity-80">
            <p className="mb-2">Built with Solidity | Foundry | Deployed on Monad</p>
            <a 
              href="https://github.com/Xyntera/monad-quests" 
              target="_blank"
              rel="noopener noreferrer"
              className="text-yellow-300 hover:text-yellow-100 transition-colors"
            >
              View on GitHub →
            </a>
          </div>
        </div>
      </div>
    </main>
  )
}

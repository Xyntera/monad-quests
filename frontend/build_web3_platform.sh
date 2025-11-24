#!/bin/bash

echo "🚀 Building Complete Web3 Platform for Monad Quests..."

# Create lib/wagmi.ts - Wagmi configuration with Monad testnet
cat > lib/wagmi.ts << 'WAGMI_EOF'
import { getDefaultConfig } from '@rainbow-me/rainbowkit';
import { Chain } from 'wagmi/chains';

export const monadTestnet: Chain = {
  id: 10143,
  name: 'Monad Testnet',
  nativeCurrency: {
    decimals: 18,
    name: 'Monad',
    symbol: 'MON',
  },
  rpcUrls: {
    default: {
      http: ['https://testnet-rpc.monad.xyz'],
    },
    public: {
      http: ['https://testnet-rpc.monad.xyz'],
    },
  },
  blockExplorers: {
    default: { name: 'MonadVision', url: 'https://testnet.monadvision.com' },
  },
  testnet: true,
};

export const config = getDefaultConfig({
  appName: 'Monad Quests',
  projectId: 'YOUR_PROJECT_ID', // Get from WalletConnect Cloud
  chains: [monadTestnet],
  ssr: true,
});
WAGMI_EOF

echo "✅ Created lib/wagmi.ts"

# Update app/layout.tsx with providers
cat > app/layout.tsx << 'LAYOUT_EOF'
import './globals.css';
import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import { Providers } from './providers';

const inter = Inter({ subsets: ['latin'] });

export const metadata: Metadata = {
  title: 'Monad Quests',
  description: 'Daily quest and XP system with NFT badges on Monad testnet',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className={inter.className}>
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
LAYOUT_EOF

echo "✅ Updated app/layout.tsx"

# Create app/providers.tsx with RainbowKit
cat > app/providers.tsx << 'PROVIDERS_EOF'
'use client';

import '@rainbow-me/rainbowkit/styles.css';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { WagmiProvider } from 'wagmi';
import { RainbowKitProvider } from '@rainbow-me/rainbowkit';
import { config } from '@/lib/wagmi';

const queryClient = new QueryClient();

export function Providers({ children }: { children: React.ReactNode }) {
  return (
    <WagmiProvider config={config}>
      <QueryClientProvider client={queryClient}>
        <RainbowKitProvider>
          {children}
        </RainbowKitProvider>
      </QueryClientProvider>
    </WagmiProvider>
  );
}
PROVIDERS_EOF

echo "✅ Created app/providers.tsx"

echo ""
echo "🎉 Web3 Platform Foundation Complete!"
echo "📦 RainbowKit wallet connection ready"
echo "⛓️  Monad testnet configured (Chain ID: 10143)"
echo ""
echo "Next: Update your pages to use wallet connection!"


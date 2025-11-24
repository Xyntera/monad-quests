import './globals.css';
import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import { Providers } from './providers';
import Link from 'next/link';
import ConnectWallet from '@/components/ConnectWallet';

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
        <Providers>
          <div className="min-h-screen bg-gradient-to-br from-indigo-900 via-purple-900 to-pink-900">
            {/* Navigation Header */}
            <header className="border-b border-white/10 backdrop-blur-sm bg-black/20">
              <div className="container mx-auto px-4 py-4">
                <div className="flex items-center justify-between">
                  {/* Logo */}
                  <Link href="/" className="flex items-center gap-2 text-2xl font-bold text-white hover:opacity-80">
                    <span className="text-3xl">🚀</span>
                    <span>Monad Quests</span>
                  </Link>

                  {/* Navigation Links */}
                  <nav className="hidden md:flex items-center gap-6">
                    <Link href="/dashboard" className="text-slate-200 hover:text-white transition">
                      Dashboard
                    </Link>
                    <Link href="/quests" className="text-slate-200 hover:text-white transition">
                      Quests
                    </Link>
                    <Link href="/leaderboard" className="text-slate-200 hover:text-white transition">
                      Leaderboard
                    </Link>
                  </nav>

                  {/* Wallet Connection */}
                  <ConnectWallet />
                </div>
              </div>
            </header>

            {/* Main Content */}
            <main className="container mx-auto px-4 py-8">
              {children}
            </main>
          </div>
        </Providers>
      </body>
    </html>
  );
}

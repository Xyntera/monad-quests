import './globals.css'
import type { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'Monad Quests - Live on Testnet',
  description: 'Daily quest and XP system with NFT badges on Monad testnet',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  )
}

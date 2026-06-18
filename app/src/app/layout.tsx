import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";
import Link from "next/link";
import { CartIcon } from "@/components/CartIcon";
import { CartSidebar } from "@/components/CartSidebar";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "Wrought Works - Artisan Furniture",
  description: "Premium handcrafted furniture with unmatched durability and deep glass aesthetics.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html
      lang="en"
      className={`${geistSans.variable} ${geistMono.variable} h-full antialiased`}
    >
      <body className="min-h-full flex flex-col selection:bg-primary/30 selection:text-primary">
        
        {/* Global Navigation Header (Glassmorphism) */}
        <header className="sticky top-0 z-50 glass-panel border-b border-glass-border">
          <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
            <div className="flex h-20 items-center justify-between">
              {/* Logo / Brand */}
              <div className="flex-shrink-0">
                <Link href="/" className="text-2xl font-light tracking-widest text-primary transition-colors hover:text-white">
                  WROUGHT<span className="font-bold text-white">WORKS</span>
                </Link>
              </div>

              {/* Primary Navigation */}
              <nav className="hidden md:flex space-x-10">
                <Link href="/catalog" className="text-sm font-medium tracking-wide text-gray-300 hover:text-white transition-colors">
                  COLLECTIONS
                </Link>
                <Link href="/custom" className="text-sm font-medium tracking-wide text-gray-300 hover:text-white transition-colors">
                  CUSTOM
                </Link>
                <Link href="/about" className="text-sm font-medium tracking-wide text-gray-300 hover:text-white transition-colors">
                  ABOUT
                </Link>
                <Link href="/contact" className="text-sm font-medium tracking-wide text-gray-300 hover:text-white transition-colors">
                  CONTACT
                </Link>
              </nav>

              {/* Action Buttons */}
              <div className="flex items-center space-x-6">
                <button className="text-gray-300 hover:text-white transition-colors">
                  <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                  </svg>
                </button>
                <CartIcon />
              </div>
            </div>
          </div>
        </header>

        <CartSidebar />

        {/* Main Content Area */}
        <main className="flex-1 flex flex-col relative z-10">
          {children}
        </main>

        {/* Global Footer */}
        <footer className="border-t border-glass-border bg-black/40 mt-auto relative z-10">
          <div className="mx-auto max-w-7xl px-4 py-12 sm:px-6 lg:px-8">
            <div className="flex flex-col md:flex-row justify-between items-center">
              <div className="mb-6 md:mb-0">
                <span className="text-xl font-light tracking-widest text-gray-500">
                  WROUGHT<span className="font-bold text-gray-400">WORKS</span>
                </span>
                <p className="mt-2 text-sm text-gray-500">Premium artisan furniture, crafted to last generations.</p>
              </div>
              <div className="flex space-x-6">
                <Link href="/terms" className="text-sm text-gray-500 hover:text-gray-300 transition-colors">Terms of Service</Link>
                <Link href="/privacy" className="text-sm text-gray-500 hover:text-gray-300 transition-colors">Privacy Policy</Link>
                <Link href="/shipping" className="text-sm text-gray-500 hover:text-gray-300 transition-colors">Shipping Info</Link>
              </div>
            </div>
            <div className="mt-8 border-t border-white/5 pt-8 flex justify-center">
              <p className="text-sm text-gray-600">
                &copy; {new Date().getFullYear()} Wrought Works. All rights reserved.
              </p>
            </div>
          </div>
        </footer>

      </body>
    </html>
  );
}

"use client";

import { useEffect, useState, Suspense } from "react";
import Link from "next/link";
import { useCartStore } from "@/lib/store";
import { useSearchParams } from "next/navigation";

function SuccessContent() {
  const clearCart = useCartStore((state) => state.clearCart);
  const searchParams = useSearchParams();
  const sessionId = searchParams.get("session_id");
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
    if (sessionId) {
      clearCart();
    }
  }, [sessionId, clearCart]);

  if (!mounted) return null;

  return (
    <div className="flex-1 flex items-center justify-center py-24 px-4 sm:px-6 lg:px-8">
      <div className="glass-panel max-w-lg w-full p-10 text-center space-y-6">
        <div className="mx-auto w-16 h-16 bg-primary/20 text-primary rounded-full flex items-center justify-center mb-6">
          <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
          </svg>
        </div>
        <h1 className="text-3xl font-light text-white tracking-wide">Thank You</h1>
        <p className="text-gray-400">
          Your payment was successful and your order has been received. We will be in contact shortly regarding shipping and delivery details.
        </p>
        <div className="pt-6 border-t border-white/10 mt-8">
          <Link 
            href="/catalog" 
            className="text-primary hover:text-white uppercase tracking-widest text-sm transition-colors"
          >
            &larr; Return to Catalog
          </Link>
        </div>
      </div>
    </div>
  );
}

export default function SuccessPage() {
  return (
    <Suspense fallback={<div className="p-24 text-center text-gray-500">Loading...</div>}>
      <SuccessContent />
    </Suspense>
  );
}

"use client";

import { useCartStore } from "@/lib/store";
import { useEffect, useState } from "react";

export function CartIcon() {
  const items = useCartStore((state) => state.items);
  const toggleCart = useCartStore((state) => state.toggleCart);
  
  // Prevent hydration mismatch by only showing the count after mount
  const [mounted, setMounted] = useState(false);
  useEffect(() => setMounted(true), []);

  return (
    <button 
      onClick={toggleCart}
      className="text-gray-300 hover:text-white transition-colors relative flex items-center p-2 -m-2"
      aria-label="Open cart"
    >
      <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z" />
      </svg>
      {mounted && items.length > 0 && (
        <span className="absolute top-0 right-0 -mt-1 -mr-1 flex h-4 w-4 items-center justify-center rounded-full bg-primary text-[10px] font-bold text-primary-foreground">
          {items.length}
        </span>
      )}
    </button>
  );
}

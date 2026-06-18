"use client";

import { useCartStore } from "@/lib/store";
import { useEffect, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";

export function CartSidebar() {
  const { items, isOpen, setIsOpen, removeItem } = useCartStore();
  const [mounted, setMounted] = useState(false);
  const router = useRouter();

  useEffect(() => {
    setMounted(true);
  }, []);

  if (!mounted) return null;

  const total = items.reduce((acc, item) => acc + item.price, 0);

  const handleCheckout = async () => {
    try {
      const response = await fetch('/api/checkout', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ items }),
      });
      
      const data = await response.json();
      if (data.url) {
        window.location.href = data.url;
      } else {
        console.error("No checkout URL returned");
      }
    } catch (error) {
      console.error("Checkout failed", error);
    }
  };

  return (
    <>
      {/* Backdrop */}
      {isOpen && (
        <div 
          className="fixed inset-0 bg-black/60 backdrop-blur-sm z-[100] transition-opacity"
          onClick={() => setIsOpen(false)}
        />
      )}

      {/* Sidebar */}
      <div 
        className={`fixed inset-y-0 right-0 w-full md:w-[450px] bg-zinc-950 border-l border-white/10 z-[101] transform transition-transform duration-300 ease-in-out flex flex-col ${
          isOpen ? 'translate-x-0' : 'translate-x-full'
        }`}
      >
        <div className="flex items-center justify-between p-6 border-b border-white/10">
          <h2 className="text-xl font-light tracking-wide text-white">Your Cart</h2>
          <button 
            onClick={() => setIsOpen(false)}
            className="text-gray-400 hover:text-white p-2 -mr-2"
          >
            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        <div className="flex-1 overflow-y-auto p-6">
          {items.length === 0 ? (
            <div className="flex flex-col items-center justify-center h-full text-center space-y-4">
              <svg className="w-12 h-12 text-zinc-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1} d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z" />
              </svg>
              <p className="text-gray-400">Your cart is empty.</p>
              <button 
                onClick={() => {
                  setIsOpen(false);
                  router.push('/catalog');
                }}
                className="text-primary hover:text-white uppercase tracking-widest text-xs transition-colors"
              >
                Browse Collection &rarr;
              </button>
            </div>
          ) : (
            <div className="space-y-6">
              {items.map((item) => (
                <div key={item.id} className="flex gap-4">
                  <div className="h-24 w-24 bg-zinc-900 rounded-sm overflow-hidden relative flex-shrink-0">
                    {/* Fallback image */}
                    <div className="absolute inset-0 flex items-center justify-center text-zinc-800">
                      <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" /></svg>
                    </div>
                  </div>
                  <div className="flex-1 flex flex-col">
                    <h3 className="text-white text-sm font-medium mb-1">{item.title}</h3>
                    <p className="text-primary text-sm mb-auto">
                      ${item.price.toLocaleString('en-US')}
                    </p>
                    <button 
                      onClick={() => removeItem(item.id)}
                      className="text-xs text-gray-500 hover:text-red-400 uppercase tracking-widest text-left mt-2 transition-colors w-max"
                    >
                      Remove
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        {items.length > 0 && (
          <div className="p-6 border-t border-white/10 bg-zinc-950">
            <div className="flex justify-between text-white mb-6">
              <span className="font-medium tracking-wide">Subtotal</span>
              <span className="font-medium">${total.toLocaleString('en-US')}</span>
            </div>
            <p className="text-xs text-gray-500 mb-6 text-center">
              Shipping and taxes calculated at checkout.
            </p>
            <button 
              onClick={handleCheckout}
              className="w-full py-4 bg-primary text-primary-foreground font-medium tracking-wide uppercase text-sm rounded-sm hover:bg-white transition-colors duration-300"
            >
              Secure Checkout
            </button>
          </div>
        )}
      </div>
    </>
  );
}

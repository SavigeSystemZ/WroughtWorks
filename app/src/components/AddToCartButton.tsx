"use client";

import { useCartStore } from "@/lib/store";

interface AddToCartButtonProps {
  product: {
    id: string;
    title: string;
    slug: string;
    price: number;
    image?: string;
    status: string;
  };
}

export function AddToCartButton({ product }: AddToCartButtonProps) {
  const addItem = useCartStore((state) => state.addItem);
  const items = useCartStore((state) => state.items);
  
  const inCart = items.some((item) => item.id === product.id);

  if (product.status !== 'AVAILABLE') {
    return (
      <div className="w-full py-4 glass-panel text-center text-gray-400 font-medium tracking-wide uppercase text-sm rounded-sm">
        {product.status === 'SOLD' ? 'Sold Out' : 'Currently Reserved'}
      </div>
    );
  }

  if (inCart) {
    return (
      <button 
        disabled
        className="w-full py-4 bg-zinc-800 text-gray-400 font-medium tracking-wide uppercase text-sm rounded-sm transition-colors duration-300 cursor-not-allowed"
      >
        Already in Cart
      </button>
    );
  }

  return (
    <button 
      onClick={() => addItem({
        id: product.id,
        title: product.title,
        slug: product.slug,
        price: Number(product.price),
        image: product.image,
      })}
      className="w-full py-4 bg-primary text-primary-foreground font-medium tracking-wide uppercase text-sm rounded-sm hover:bg-white transition-colors duration-300"
    >
      Add to Cart
    </button>
  );
}

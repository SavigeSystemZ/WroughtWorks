import { create } from 'zustand';
import { persist } from 'zustand/middleware';

export interface CartItem {
  id: string; // product id
  title: string;
  slug: string;
  price: number;
  image?: string;
}

interface CartState {
  items: CartItem[];
  addItem: (item: CartItem) => void;
  removeItem: (id: string) => void;
  clearCart: () => void;
  isOpen: boolean;
  setIsOpen: (isOpen: boolean) => void;
  toggleCart: () => void;
}

export const useCartStore = create<CartState>()(
  persist(
    (set) => ({
      items: [],
      isOpen: false,
      addItem: (item) => set((state) => {
        // Since artisan furniture is generally 1-of-1, we check if it's already in the cart
        const exists = state.items.find(i => i.id === item.id);
        if (exists) return state; // Don't add duplicates
        
        // Open the cart when adding an item
        return { items: [...state.items, item], isOpen: true };
      }),
      removeItem: (id) => set((state) => ({
        items: state.items.filter((item) => item.id !== id)
      })),
      clearCart: () => set({ items: [] }),
      setIsOpen: (isOpen) => set({ isOpen }),
      toggleCart: () => set((state) => ({ isOpen: !state.isOpen })),
    }),
    {
      name: 'wroughtworks-cart',
      // We only want to persist the items, not the open/close state
      partialize: (state) => ({ items: state.items }),
    }
  )
);

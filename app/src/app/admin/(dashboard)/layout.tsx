import Link from "next/link";

export default function AdminDashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="min-h-screen bg-zinc-950 flex flex-col md:flex-row">
      {/* Sidebar */}
      <aside className="w-full md:w-64 glass-panel border-r border-b md:border-b-0 border-glass-border flex-shrink-0 z-20 sticky top-20 md:top-0 h-auto md:h-[calc(100vh-5rem)]">
        <div className="p-6">
          <h2 className="text-sm font-semibold text-white uppercase tracking-widest mb-6">Admin Panel</h2>
          <nav className="space-y-2">
            <Link 
              href="/admin/orders" 
              className="block px-4 py-3 text-sm text-gray-400 hover:text-white hover:bg-white/5 rounded-sm transition-colors"
            >
              Orders
            </Link>
            <Link 
              href="/admin/products" 
              className="block px-4 py-3 text-sm text-gray-400 hover:text-white hover:bg-white/5 rounded-sm transition-colors"
            >
              Products
            </Link>
            <Link 
              href="/admin/inquiries" 
              className="block px-4 py-3 text-sm text-gray-400 hover:text-white hover:bg-white/5 rounded-sm transition-colors"
            >
              Inquiries
            </Link>
          </nav>
        </div>
      </aside>

      {/* Main Content */}
      <main className="flex-1 p-6 md:p-10 overflow-y-auto z-10 relative">
        <div className="max-w-6xl mx-auto">
          {children}
        </div>
      </main>
    </div>
  );
}

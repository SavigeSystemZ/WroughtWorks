import Link from "next/link";
import Image from "next/image";

export default function Home() {
  return (
    <div className="flex flex-col min-h-[calc(100vh-5rem)]">
      {/* Hero Section */}
      <section className="relative flex-1 flex items-center justify-center py-32 overflow-hidden">
        {/* Background ambient glow specific to hero */}
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[800px] h-[800px] bg-primary/10 rounded-full blur-[120px] pointer-events-none" />
        
        <div className="relative z-10 max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h1 className="text-5xl md:text-7xl font-extralight tracking-tight mb-8">
            Furniture that <span className="font-semibold text-primary italic">outlasts</span> trends.
          </h1>
          <p className="mt-6 text-xl text-gray-400 max-w-2xl mx-auto leading-relaxed mb-12">
            Handcrafted with uncompromising quality. We fuse raw organic materials with modern precision to create statement pieces for your space.
          </p>
          
          <div className="flex flex-col sm:flex-row justify-center items-center gap-6">
            <Link 
              href="/catalog" 
              className="px-8 py-4 bg-primary text-primary-foreground font-medium tracking-wide uppercase text-sm rounded-sm hover:bg-white transition-colors duration-300 w-full sm:w-auto"
            >
              Explore Collection
            </Link>
            <Link 
              href="/custom" 
              className="px-8 py-4 glass-panel text-white font-medium tracking-wide uppercase text-sm rounded-sm hover:bg-white/10 transition-colors duration-300 w-full sm:w-auto"
            >
              Custom Commissions
            </Link>
          </div>
        </div>
      </section>

      {/* Featured Pieces (Glass Cards) */}
      <section className="py-24 relative z-10">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-end mb-12">
            <div>
              <h2 className="text-3xl font-light tracking-wide text-white mb-2">Featured Pieces</h2>
              <p className="text-gray-400">Our most requested artisan works.</p>
            </div>
            <Link href="/catalog" className="hidden sm:block text-primary hover:text-white uppercase text-sm tracking-widest transition-colors pb-1 border-b border-primary/30 hover:border-white">
              View All
            </Link>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {/* Mock Product 1 */}
            <div className="glass-card group overflow-hidden flex flex-col h-full">
              <div className="relative w-full aspect-[4/3] bg-zinc-900/50">
                {/* Fallback box if no image */}
                <div className="absolute inset-0 flex items-center justify-center text-zinc-700">
                  <svg className="w-12 h-12" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" /></svg>
                </div>
              </div>
              <div className="p-6 flex-1 flex flex-col justify-between border-t border-glass-border">
                <div>
                  <h3 className="text-lg font-medium text-white mb-1">Live Edge Burl Table</h3>
                  <p className="text-sm text-gray-400 mb-4 line-clamp-2">Reclaimed walnut with a hand-rubbed oil finish. Each piece features a unique organic edge.</p>
                </div>
                <div className="flex justify-between items-center mt-4">
                  <span className="text-primary font-medium">$4,200</span>
                  <button className="text-xs uppercase tracking-widest text-white hover:text-primary transition-colors">Details &rarr;</button>
                </div>
              </div>
            </div>

            {/* Mock Product 2 */}
            <div className="glass-card group overflow-hidden flex flex-col h-full">
              <div className="relative w-full aspect-[4/3] bg-zinc-900/50">
                <div className="absolute inset-0 flex items-center justify-center text-zinc-700">
                  <svg className="w-12 h-12" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" /></svg>
                </div>
              </div>
              <div className="p-6 flex-1 flex flex-col justify-between border-t border-glass-border">
                <div>
                  <h3 className="text-lg font-medium text-white mb-1">Ebonized Oak Console</h3>
                  <p className="text-sm text-gray-400 mb-4 line-clamp-2">Sleek, brutalist-inspired console table. Charred oak finish with solid brass hardware.</p>
                </div>
                <div className="flex justify-between items-center mt-4">
                  <span className="text-primary font-medium">$2,850</span>
                  <button className="text-xs uppercase tracking-widest text-white hover:text-primary transition-colors">Details &rarr;</button>
                </div>
              </div>
            </div>

            {/* Mock Product 3 */}
            <div className="glass-card group overflow-hidden flex flex-col h-full">
              <div className="relative w-full aspect-[4/3] bg-zinc-900/50">
                <div className="absolute inset-0 flex items-center justify-center text-zinc-700">
                  <svg className="w-12 h-12" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" /></svg>
                </div>
              </div>
              <div className="p-6 flex-1 flex flex-col justify-between border-t border-glass-border">
                <div>
                  <h3 className="text-lg font-medium text-white mb-1">Sculptural Lounge Chair</h3>
                  <p className="text-sm text-gray-400 mb-4 line-clamp-2">Ergonomic seating meets art. Carved ash wood frame with premium Italian leather upholstery.</p>
                </div>
                <div className="flex justify-between items-center mt-4">
                  <span className="text-primary font-medium">$3,400</span>
                  <button className="text-xs uppercase tracking-widest text-white hover:text-primary transition-colors">Details &rarr;</button>
                </div>
              </div>
            </div>
          </div>
          
          <div className="mt-8 text-center sm:hidden">
            <Link href="/catalog" className="inline-block px-6 py-3 border border-glass-border rounded-sm text-sm uppercase tracking-widest hover:bg-white/5 transition-colors">
              View All Pieces
            </Link>
          </div>
        </div>
      </section>
    </div>
  );
}

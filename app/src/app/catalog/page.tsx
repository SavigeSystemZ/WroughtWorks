import { db } from "@/lib/db";
import Link from "next/link";
import Image from "next/image";

export const metadata = {
  title: "Catalog | Wrought Works",
  description: "Browse our collection of handcrafted artisan furniture.",
};

export default async function CatalogPage() {
  const products = await db.product.findMany({
    where: {
      status: {
        not: 'HIDDEN'
      }
    },
    include: {
      category: true,
      images: {
        where: { isPrimary: true },
        take: 1
      }
    },
    orderBy: {
      createdAt: 'desc'
    }
  });

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-24">
      <div className="mb-16">
        <h1 className="text-4xl md:text-5xl font-extralight tracking-tight text-white mb-4">
          The <span className="font-semibold text-primary italic">Collection</span>
        </h1>
        <p className="text-gray-400 max-w-2xl text-lg">
          Each piece is uniquely handcrafted, bearing the marks of its material&apos;s history and the maker&apos;s intent.
        </p>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-10">
        {products.map((product) => (
          <Link href={`/catalog/${product.slug}`} key={product.id} className="group flex flex-col h-full">
            <div className="glass-card overflow-hidden flex flex-col h-full">
              <div className="relative w-full aspect-[4/3] bg-zinc-900/50 overflow-hidden">
                {product.images[0]?.url ? (
                  /* We would normally use next/image here, but since these are mock paths, we use a standard img or a fallback */
                  <div className="w-full h-full object-cover transition-transform duration-700 group-hover:scale-105 bg-zinc-800" />
                ) : (
                  <div className="absolute inset-0 flex items-center justify-center text-zinc-700">
                    <svg className="w-12 h-12" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" /></svg>
                  </div>
                )}
                
                {/* Status Badge */}
                {product.status !== 'AVAILABLE' && (
                  <div className="absolute top-4 right-4 px-3 py-1 bg-black/70 backdrop-blur-md text-xs font-medium tracking-widest uppercase text-white border border-white/10 rounded-sm">
                    {product.status}
                  </div>
                )}
              </div>
              
              <div className="p-6 flex-1 flex flex-col justify-between border-t border-glass-border">
                <div>
                  <div className="text-xs uppercase tracking-widest text-primary mb-2">{product.category.name}</div>
                  <h3 className="text-xl font-medium text-white mb-2 group-hover:text-primary transition-colors">{product.title}</h3>
                  <p className="text-sm text-gray-400 mb-6 line-clamp-2">{product.description}</p>
                </div>
                <div className="flex justify-between items-center mt-auto">
                  <span className="text-white font-medium tracking-wide">
                    ${Number(product.price).toLocaleString('en-US', { minimumFractionDigits: 0 })}
                  </span>
                  <span className="text-xs uppercase tracking-widest text-gray-500 group-hover:text-primary transition-colors">
                    View Details &rarr;
                  </span>
                </div>
              </div>
            </div>
          </Link>
        ))}
      </div>
      
      {products.length === 0 && (
        <div className="text-center py-24 glass-panel rounded-lg">
          <p className="text-gray-400 text-lg">Our collection is currently being updated with new pieces.</p>
        </div>
      )}
    </div>
  );
}

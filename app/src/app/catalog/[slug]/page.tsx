import { db } from "@/lib/db";
import { notFound } from "next/navigation";
import Link from "next/link";
import { AddToCartButton } from "@/components/AddToCartButton";

interface ProductPageProps {
  params: Promise<{
    slug: string;
  }>;
}

export async function generateMetadata({ params }: ProductPageProps) {
  const resolvedParams = await params;
  const product = await db.product.findUnique({
    where: { slug: resolvedParams.slug },
  });

  if (!product) return { title: "Not Found | Wrought Works" };

  return {
    title: `${product.title} | Wrought Works`,
    description: product.description.substring(0, 160),
  };
}

export default async function ProductPage({ params }: ProductPageProps) {
  const resolvedParams = await params;
  const product = await db.product.findUnique({
    where: { slug: resolvedParams.slug },
    include: {
      category: true,
      materialSource: true,
      images: {
        orderBy: { sortOrder: 'asc' }
      }
    }
  });

  if (!product) {
    notFound();
  }

  const primaryImage = product.images.find(img => img.isPrimary) || product.images[0];
  const secondaryImages = product.images.filter(img => img.id !== primaryImage?.id);

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16 md:py-24">
      {/* Breadcrumbs */}
      <nav className="mb-12 flex text-sm uppercase tracking-widest text-gray-500">
        <Link href="/catalog" className="hover:text-primary transition-colors">Catalog</Link>
        <span className="mx-3">/</span>
        <span className="text-gray-300">{product.category.name}</span>
        <span className="mx-3">/</span>
        <span className="text-primary truncate max-w-[200px] sm:max-w-none">{product.title}</span>
      </nav>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-16">
        {/* Image Gallery */}
        <div className="space-y-6">
          <div className="glass-panel overflow-hidden relative aspect-[4/5] w-full">
            {primaryImage ? (
              <div className="w-full h-full bg-zinc-800" />
            ) : (
              <div className="w-full h-full flex items-center justify-center text-zinc-700 bg-zinc-900/50">
                <svg className="w-16 h-16" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" /></svg>
              </div>
            )}
          </div>
          
          {secondaryImages.length > 0 && (
            <div className="grid grid-cols-2 gap-6">
              {secondaryImages.map(img => (
                <div key={img.id} className="glass-panel overflow-hidden relative aspect-square w-full">
                   <div className="w-full h-full bg-zinc-800" />
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Product Details */}
        <div className="flex flex-col">
          <div className="mb-8">
            <h1 className="text-4xl md:text-5xl font-light text-white mb-4">{product.title}</h1>
            <p className="text-2xl font-medium text-primary mb-6">
              ${Number(product.price).toLocaleString('en-US', { minimumFractionDigits: 0 })}
            </p>
            
            <div className="prose prose-invert prose-p:text-gray-400 prose-p:leading-relaxed max-w-none">
              <p>{product.description}</p>
            </div>
          </div>

          {/* Action Area */}
          <div className="mb-12 pb-12 border-b border-glass-border">
            <AddToCartButton 
              product={{
                id: product.id,
                title: product.title,
                slug: product.slug,
                price: Number(product.price),
                image: primaryImage?.url,
                status: product.status
              }} 
            />
            
            <p className="mt-4 text-sm text-center text-gray-500">
              Free freight shipping on all domestic orders over $5,000.
            </p>
          </div>

          {/* Specifications Grid */}
          <div className="space-y-8">
            <h3 className="text-xl font-light text-white tracking-wide uppercase">Specifications</h3>
            
            <dl className="grid grid-cols-1 sm:grid-cols-2 gap-x-6 gap-y-8">
              {product.dimensions && (
                <div className="glass-card p-5">
                  <dt className="text-xs uppercase tracking-widest text-gray-500 mb-1">Dimensions</dt>
                  <dd className="text-sm text-gray-300">{product.dimensions}</dd>
                </div>
              )}
              
              {product.finish && (
                <div className="glass-card p-5">
                  <dt className="text-xs uppercase tracking-widest text-gray-500 mb-1">Finish</dt>
                  <dd className="text-sm text-gray-300">{product.finish}</dd>
                </div>
              )}
              
              {product.materialSource && (
                <div className="glass-card p-5 sm:col-span-2">
                  <dt className="text-xs uppercase tracking-widest text-gray-500 mb-1">Material Provenance</dt>
                  <dd className="text-sm text-gray-300 mb-2 font-medium">{product.materialSource.woodType}</dd>
                  <dd className="text-sm text-gray-400 leading-relaxed">{product.materialSource.provenanceNotes}</dd>
                </div>
              )}
              
              {product.weightEstimate && (
                <div className="glass-card p-5">
                  <dt className="text-xs uppercase tracking-widest text-gray-500 mb-1">Est. Weight</dt>
                  <dd className="text-sm text-gray-300">{product.weightEstimate}</dd>
                </div>
              )}
              
              <div className="glass-card p-5">
                <dt className="text-xs uppercase tracking-widest text-gray-500 mb-1">Shipping</dt>
                <dd className="text-sm text-gray-300">{product.shippingMode.replace(/_/g, ' ')}</dd>
              </div>
            </dl>
          </div>
          
        </div>
      </div>
    </div>
  );
}

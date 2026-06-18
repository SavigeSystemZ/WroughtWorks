import { db } from "@/lib/db";
import Link from "next/link";

export const metadata = {
  title: "Admin | Products",
};

export default async function AdminProductsPage() {
  const products = await db.product.findMany({
    orderBy: { createdAt: 'desc' },
    include: {
      category: true
    }
  });

  return (
    <div>
      <div className="flex justify-between items-end mb-8">
        <div>
          <h1 className="text-3xl font-light text-white tracking-widest uppercase">Products</h1>
          <p className="text-gray-400 mt-2">Manage your catalog inventory and statuses.</p>
        </div>
        <Link href="/admin/products/new" className="px-6 py-3 bg-primary text-primary-foreground text-xs uppercase tracking-widest font-medium rounded-sm hover:bg-white transition-colors inline-block">
          + New Product
        </Link>
      </div>

      <div className="glass-panel overflow-hidden rounded-lg">
        <table className="w-full text-left text-sm text-gray-300">
          <thead className="bg-white/5 text-xs uppercase tracking-widest text-gray-400 border-b border-glass-border">
            <tr>
              <th className="px-6 py-4 font-medium">Title</th>
              <th className="px-6 py-4 font-medium">Category</th>
              <th className="px-6 py-4 font-medium">Price</th>
              <th className="px-6 py-4 font-medium">Status</th>
              <th className="px-6 py-4 font-medium text-right">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-glass-border">
            {products.length === 0 ? (
              <tr>
                <td colSpan={5} className="px-6 py-12 text-center text-gray-500">
                  No products found.
                </td>
              </tr>
            ) : (
              products.map((product) => (
                <tr key={product.id} className="hover:bg-white/[0.02] transition-colors">
                  <td className="px-6 py-4">
                    <div className="text-white font-medium">{product.title}</div>
                    <div className="text-gray-500 text-xs font-mono">{product.slug}</div>
                  </td>
                  <td className="px-6 py-4 text-gray-400">
                    {product.category.name}
                  </td>
                  <td className="px-6 py-4 text-white font-medium">
                    ${Number(product.price).toLocaleString('en-US')}
                  </td>
                  <td className="px-6 py-4">
                    <span className={`px-2 py-1 text-[10px] font-bold tracking-widest uppercase rounded-sm border ${
                      product.status === 'AVAILABLE' ? 'bg-green-500/10 text-green-400 border-green-500/20' :
                      product.status === 'SOLD' ? 'bg-gray-500/10 text-gray-400 border-gray-500/20' :
                      'bg-orange-500/10 text-orange-400 border-orange-500/20'
                    }`}>
                      {product.status}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-right">
                    <button className="text-xs uppercase tracking-widest text-gray-400 hover:text-white transition-colors">
                      Edit
                    </button>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}

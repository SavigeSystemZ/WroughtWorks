import { db } from "@/lib/db";
import { revalidatePath } from "next/cache";

export const metadata = {
  title: "Admin | Orders",
};

export default async function AdminOrdersPage() {
  const orders = await db.order.findMany({
    orderBy: { createdAt: 'desc' },
    include: {
      items: {
        include: {
          product: true
        }
      }
    }
  });

  async function markAsFulfilled(formData: FormData) {
    "use server";
    const orderId = formData.get("orderId") as string;
    if (orderId) {
      await db.order.update({
        where: { id: orderId },
        data: { status: 'FULFILLED' }
      });
      revalidatePath('/admin/orders');
    }
  }

  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-light text-white tracking-widest uppercase">Orders</h1>
        <p className="text-gray-400 mt-2">Manage incoming purchases and fulfillment.</p>
      </div>

      <div className="glass-panel overflow-hidden rounded-lg">
        <table className="w-full text-left text-sm text-gray-300">
          <thead className="bg-white/5 text-xs uppercase tracking-widest text-gray-400 border-b border-glass-border">
            <tr>
              <th className="px-6 py-4 font-medium">Order ID</th>
              <th className="px-6 py-4 font-medium">Customer</th>
              <th className="px-6 py-4 font-medium">Items</th>
              <th className="px-6 py-4 font-medium">Total</th>
              <th className="px-6 py-4 font-medium">Status</th>
              <th className="px-6 py-4 font-medium text-right">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-glass-border">
            {orders.length === 0 ? (
              <tr>
                <td colSpan={6} className="px-6 py-12 text-center text-gray-500">
                  No orders found.
                </td>
              </tr>
            ) : (
              orders.map((order) => (
                <tr key={order.id} className="hover:bg-white/[0.02] transition-colors">
                  <td className="px-6 py-4 font-mono text-xs text-gray-500">{order.id.split('-')[0]}...</td>
                  <td className="px-6 py-4">
                    <div className="text-white font-medium">{order.customerName}</div>
                    <div className="text-gray-500 text-xs">{order.customerEmail}</div>
                  </td>
                  <td className="px-6 py-4">
                    <ul className="list-disc list-inside text-gray-400">
                      {order.items.map(item => (
                        <li key={item.id}>{item.product.title}</li>
                      ))}
                    </ul>
                  </td>
                  <td className="px-6 py-4 text-white font-medium">
                    ${Number(order.totalAmount).toLocaleString('en-US')}
                  </td>
                  <td className="px-6 py-4">
                    <span className={`px-2 py-1 text-[10px] font-bold tracking-widest uppercase rounded-sm border ${
                      order.status === 'PAID' ? 'bg-green-500/10 text-green-400 border-green-500/20' :
                      order.status === 'FULFILLED' ? 'bg-primary/10 text-primary border-primary/20' :
                      'bg-gray-500/10 text-gray-400 border-gray-500/20'
                    }`}>
                      {order.status}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-right">
                    {order.status === 'PAID' && (
                      <form action={markAsFulfilled}>
                        <input type="hidden" name="orderId" value={order.id} />
                        <button type="submit" className="text-xs uppercase tracking-widest text-primary hover:text-white transition-colors">
                          Mark Fulfilled
                        </button>
                      </form>
                    )}
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

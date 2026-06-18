import { db } from "@/lib/db";

export const metadata = {
  title: "Admin | Inquiries",
};

export default async function AdminInquiriesPage() {
  const inquiries = await db.inquiry.findMany({
    orderBy: { createdAt: 'desc' }
  });

  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-light text-white tracking-widest uppercase">Inquiries</h1>
        <p className="text-gray-400 mt-2">Manage custom commission requests and questions.</p>
      </div>

      <div className="glass-panel overflow-hidden rounded-lg">
        <table className="w-full text-left text-sm text-gray-300">
          <thead className="bg-white/5 text-xs uppercase tracking-widest text-gray-400 border-b border-glass-border">
            <tr>
              <th className="px-6 py-4 font-medium">Date</th>
              <th className="px-6 py-4 font-medium">Client</th>
              <th className="px-6 py-4 font-medium">Type</th>
              <th className="px-6 py-4 font-medium">Status</th>
              <th className="px-6 py-4 font-medium text-right">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-glass-border">
            {inquiries.length === 0 ? (
              <tr>
                <td colSpan={5} className="px-6 py-12 text-center text-gray-500">
                  No inquiries found.
                </td>
              </tr>
            ) : (
              inquiries.map((inquiry) => (
                <tr key={inquiry.id} className="hover:bg-white/[0.02] transition-colors">
                  <td className="px-6 py-4 text-gray-400">
                    {new Date(inquiry.createdAt).toLocaleDateString()}
                  </td>
                  <td className="px-6 py-4">
                    <div className="text-white font-medium">{inquiry.customerName}</div>
                    <div className="text-gray-500 text-xs">{inquiry.customerEmail}</div>
                  </td>
                  <td className="px-6 py-4 text-gray-400">
                    {inquiry.type}
                  </td>
                  <td className="px-6 py-4">
                    <span className={`px-2 py-1 text-[10px] font-bold tracking-widest uppercase rounded-sm border ${
                      inquiry.status === 'OPEN' ? 'bg-orange-500/10 text-orange-400 border-orange-500/20' :
                      'bg-gray-500/10 text-gray-400 border-gray-500/20'
                    }`}>
                      {inquiry.status}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-right">
                    <button className="text-xs uppercase tracking-widest text-primary hover:text-white transition-colors">
                      View
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

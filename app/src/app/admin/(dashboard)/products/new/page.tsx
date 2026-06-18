import { db } from "@/lib/db";
import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { writeFile, mkdir } from "fs/promises";
import { join } from "path";
import { existsSync } from "fs";

export const metadata = {
  title: "Admin | New Product",
};

export default async function NewProductPage() {
  const categories = await db.category.findMany();

  async function createProduct(formData: FormData) {
    "use server";
    
    const title = formData.get("title") as string;
    const slug = formData.get("slug") as string;
    const description = formData.get("description") as string;
    const price = parseFloat(formData.get("price") as string);
    const categoryId = formData.get("categoryId") as string;
    const status = formData.get("status") as any;
    const image = formData.get("image") as File;

    let imageUrl = "";

    // MVP Local File Upload Fallback
    if (image && image.size > 0) {
      const bytes = await image.arrayBuffer();
      const buffer = Buffer.from(bytes);

      const uploadDir = join(process.cwd(), "public", "uploads");
      
      // Ensure upload directory exists
      if (!existsSync(uploadDir)) {
        await mkdir(uploadDir, { recursive: true });
      }

      const fileName = `${Date.now()}-${image.name.replace(/\s+/g, '-')}`;
      const filePath = join(uploadDir, fileName);
      
      await writeFile(filePath, buffer);
      imageUrl = `/uploads/${fileName}`;
    }

    const newProduct = await db.product.create({
      data: {
        title,
        slug,
        description,
        price,
        categoryId,
        status,
        images: imageUrl ? {
          create: [{
            url: imageUrl,
            isPrimary: true,
            altText: title
          }]
        } : undefined
      }
    });

    revalidatePath("/admin/products");
    revalidatePath("/catalog");
    redirect("/admin/products");
  }

  return (
    <div className="max-w-2xl mx-auto pb-12">
      <div className="mb-8">
        <h1 className="text-3xl font-light text-white tracking-widest uppercase">New Product</h1>
        <p className="text-gray-400 mt-2">Add a new handcrafted piece to the Wrought Works catalog.</p>
      </div>

      <div className="glass-panel p-8 rounded-lg">
        <form action={createProduct} className="space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="space-y-2">
              <label htmlFor="title" className="text-xs uppercase tracking-widest text-gray-400">Title</label>
              <input 
                type="text" 
                id="title"
                name="title"
                required
                className="w-full bg-zinc-900/50 border border-glass-border rounded-sm px-4 py-3 text-white focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-colors"
                placeholder="e.g. The monolithic coffee table"
              />
            </div>
            <div className="space-y-2">
              <label htmlFor="slug" className="text-xs uppercase tracking-widest text-gray-400">Slug</label>
              <input 
                type="text" 
                id="slug"
                name="slug"
                required
                className="w-full bg-zinc-900/50 border border-glass-border rounded-sm px-4 py-3 text-white focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-colors"
                placeholder="e.g. monolithic-coffee-table"
              />
            </div>
          </div>

          <div className="space-y-2">
            <label htmlFor="description" className="text-xs uppercase tracking-widest text-gray-400">Description</label>
            <textarea 
              id="description"
              name="description"
              required
              rows={4}
              className="w-full bg-zinc-900/50 border border-glass-border rounded-sm px-4 py-3 text-white focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-colors"
            ></textarea>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div className="space-y-2">
              <label htmlFor="price" className="text-xs uppercase tracking-widest text-gray-400">Price (USD)</label>
              <input 
                type="number" 
                id="price"
                name="price"
                step="0.01"
                required
                className="w-full bg-zinc-900/50 border border-glass-border rounded-sm px-4 py-3 text-white focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-colors"
                placeholder="2400.00"
              />
            </div>
            
            <div className="space-y-2">
              <label htmlFor="categoryId" className="text-xs uppercase tracking-widest text-gray-400">Category</label>
              <select 
                id="categoryId"
                name="categoryId"
                required
                className="w-full bg-zinc-900/50 border border-glass-border rounded-sm px-4 py-3 text-white focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-colors appearance-none"
              >
                {categories.map(cat => (
                  <option key={cat.id} value={cat.id}>{cat.name}</option>
                ))}
              </select>
            </div>

            <div className="space-y-2">
              <label htmlFor="status" className="text-xs uppercase tracking-widest text-gray-400">Status</label>
              <select 
                id="status"
                name="status"
                required
                className="w-full bg-zinc-900/50 border border-glass-border rounded-sm px-4 py-3 text-white focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-colors appearance-none"
              >
                <option value="DRAFT">Draft</option>
                <option value="AVAILABLE">Available</option>
                <option value="RESERVED">Reserved</option>
                <option value="SOLD">Sold</option>
                <option value="HIDDEN">Hidden</option>
              </select>
            </div>
          </div>

          <div className="space-y-2 border-t border-glass-border pt-6 mt-6">
            <label htmlFor="image" className="text-xs uppercase tracking-widest text-gray-400">Product Image (Primary)</label>
            <input 
              type="file" 
              id="image"
              name="image"
              accept="image/*"
              className="w-full bg-zinc-900/50 border border-glass-border rounded-sm px-4 py-3 text-gray-400 file:bg-primary file:text-primary-foreground file:border-0 file:px-4 file:py-2 file:rounded-sm file:mr-4 file:text-xs file:uppercase file:tracking-widest file:font-medium hover:file:bg-white hover:file:text-black transition-colors"
            />
            <p className="text-xs text-gray-500 mt-2">
              For this local MVP, images will be uploaded to the `public/uploads` directory. In production, connect an S3 or Vercel Blob adapter in the server action.
            </p>
          </div>

          <div className="pt-6">
            <button 
              type="submit" 
              className="w-full py-4 bg-primary text-primary-foreground font-medium tracking-wide uppercase text-sm rounded-sm hover:bg-white transition-colors duration-300"
            >
              Create Product
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

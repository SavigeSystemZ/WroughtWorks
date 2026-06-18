import { db as prisma } from '../src/lib/db'

async function main() {
  console.log('Seeding database...')

  // Clean up existing data to ensure idempotent seeding
  await prisma.productImage.deleteMany()
  await prisma.product.deleteMany()
  await prisma.category.deleteMany()
  await prisma.materialSource.deleteMany()

  // 1. Create Categories
  const tablesCat = await prisma.category.create({
    data: { name: 'Tables', slug: 'tables' },
  })
  
  const seatingCat = await prisma.category.create({
    data: { name: 'Seating', slug: 'seating' },
  })

  const storageCat = await prisma.category.create({
    data: { name: 'Storage', slug: 'storage' },
  })

  const decorCat = await prisma.category.create({
    data: { name: 'Decor', slug: 'decor' },
  })

  // 2. Create Material Sources
  const walnutSource = await prisma.materialSource.create({
    data: {
      woodType: 'Black Walnut',
      sourceRegion: 'Pacific Northwest',
      isReclaimed: true,
      provenanceNotes: 'Reclaimed from a fallen 120-year-old tree after a storm.',
    },
  })

  const oakSource = await prisma.materialSource.create({
    data: {
      woodType: 'White Oak',
      sourceRegion: 'Appalachian Mountains',
      isReclaimed: false,
      provenanceNotes: 'Sustainably harvested from certified managed forests.',
    },
  })

  const mapleSource = await prisma.materialSource.create({
    data: {
      woodType: 'Ambrosia Maple',
      sourceRegion: 'New England',
      isReclaimed: true,
      provenanceNotes: 'Salvaged from an old barn built in the late 1800s.',
    },
  })

  // 3. Create Products
  const tableProduct = await prisma.product.create({
    data: {
      title: 'Live Edge Burl Table',
      slug: 'live-edge-burl-table',
      description: 'Reclaimed walnut with a hand-rubbed oil finish. Each piece features a unique organic edge that respects the natural contour of the tree. Set on a custom forged steel base with a blackened patina.',
      status: 'AVAILABLE',
      categoryId: tablesCat.id,
      price: 4200.00,
      dimensions: '84" L x 40" W x 30" H',
      weightEstimate: '250 lbs',
      materialSourceId: walnutSource.id,
      finish: 'Hand-rubbed Tung Oil',
      shippingMode: 'FREIGHT',
      featured: true,
      images: {
        create: [
          { url: '/assets/products/burl-table-1.jpg', isPrimary: true, altText: 'Live Edge Burl Table Top' },
          { url: '/assets/products/burl-table-2.jpg', sortOrder: 1, altText: 'Burl Table Edge Detail' }
        ]
      }
    }
  })

  const consoleProduct = await prisma.product.create({
    data: {
      title: 'Ebonized Oak Console',
      slug: 'ebonized-oak-console',
      description: 'Sleek, brutalist-inspired console table. Charred oak finish with solid brass hardware. Perfect for an entryway or behind a sofa. Features two seamless drawers with soft-close mechanisms.',
      status: 'AVAILABLE',
      categoryId: storageCat.id,
      price: 2850.00,
      dimensions: '60" L x 16" W x 32" H',
      weightEstimate: '90 lbs',
      materialSourceId: oakSource.id,
      finish: 'Ebonized (Shou Sugi Ban inspired) with clear matte sealer',
      shippingMode: 'OVERSIZED',
      featured: true,
      images: {
        create: [
          { url: '/assets/products/oak-console-1.jpg', isPrimary: true, altText: 'Ebonized Oak Console Front View' }
        ]
      }
    }
  })

  const loungeChair = await prisma.product.create({
    data: {
      title: 'Sculptural Lounge Chair',
      slug: 'sculptural-lounge-chair',
      description: 'Ergonomic seating meets art. Carved maple wood frame with premium Italian leather upholstery. The suspension system is hand-tied, ensuring decades of comfortable use.',
      status: 'RESERVED',
      categoryId: seatingCat.id,
      price: 3400.00,
      dimensions: '32" W x 36" D x 34" H',
      weightEstimate: '65 lbs',
      materialSourceId: mapleSource.id,
      finish: 'Clear Satin Varnish',
      shippingMode: 'SHIPPABLE',
      featured: true,
      images: {
        create: [
          { url: '/assets/products/lounge-chair-1.jpg', isPrimary: true, altText: 'Sculptural Lounge Chair Side View' }
        ]
      }
    }
  })

  const sideTable = await prisma.product.create({
    data: {
      title: 'Geometric Walnut Side Table',
      slug: 'geometric-walnut-side-table',
      description: 'A striking asymmetric design that challenges conventional balance. Hand-cut dovetail joints showcase the craftsmanship. Ideal as a bedside table or living room accent.',
      status: 'AVAILABLE',
      categoryId: tablesCat.id,
      price: 1200.00,
      dimensions: '18" W x 18" D x 22" H',
      weightEstimate: '30 lbs',
      materialSourceId: walnutSource.id,
      finish: 'Danish Oil',
      shippingMode: 'SHIPPABLE',
      featured: false,
    }
  })

  const wallArt = await prisma.product.create({
    data: {
      title: 'Abstract End-Grain Panel',
      slug: 'abstract-end-grain-panel',
      description: 'A mosaic of reclaimed oak offcuts arranged to highlight the intricate rings and rays of the wood. Framed in blackened steel.',
      status: 'SOLD',
      categoryId: decorCat.id,
      price: 950.00,
      dimensions: '48" W x 36" H',
      weightEstimate: '45 lbs',
      materialSourceId: oakSource.id,
      finish: 'Natural Wax',
      shippingMode: 'SHIPPABLE',
      featured: false,
    }
  })

  console.log('Seeding completed successfully!')
}

main()
  .catch((e) => {
    console.error(e)
    process.exit(1)
  })
  .finally(async () => {
    await prisma.$disconnect()
  })

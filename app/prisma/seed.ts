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

  console.log('Seeding foundation complete! (No mock products added)')
}

main()
  .catch((e) => {
    console.error(e)
    process.exit(1)
  })
  .finally(async () => {
    await prisma.$disconnect()
  })

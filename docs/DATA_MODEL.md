# Data Model

The database schema will be managed by Prisma using PostgreSQL for production.

## Core Entities

### User
Represents admin identities and roles.
- `id`: String (UUID)
- `email`: String (Unique)
- `passwordHash`: String
- `role`: Enum (ADMIN)
- `createdAt`, `updatedAt`: DateTime

### Product
The main sellable piece.
- `id`: String (UUID)
- `title`: String
- `slug`: String (Unique)
- `description`: Text
- `status`: Enum (AVAILABLE, RESERVED, SOLD, HIDDEN, DRAFT)
- `categoryId`: String (FK to Category)
- `price`: Decimal
- `currency`: String (default "USD")
- `dimensions`: String
- `weightEstimate`: String
- `materialSourceId`: String (FK to MaterialSource)
- `finish`: String
- `careNotes`: Text
- `shippingMode`: Enum (SHIPPABLE, OVERSIZED, FREIGHT, LOCAL_PICKUP_ONLY)
- `pickupAvailable`: Boolean
- `featured`: Boolean
- `uniquenessFlag`: Boolean (default true)
- `createdAt`, `updatedAt`: DateTime

### ProductImage
Gallery and media records for products.
- `id`: String (UUID)
- `productId`: String (FK to Product)
- `url`: String
- `altText`: String
- `sortOrder`: Integer
- `isPrimary`: Boolean
- `dimensions`: String
- `createdAt`: DateTime

### Category
e.g., Stump table, burl art, wall decor.
- `id`: String (UUID)
- `name`: String
- `slug`: String (Unique)

### MaterialSource
Provenance details for wood and materials.
- `id`: String (UUID)
- `woodType`: String
- `sourceRegion`: String
- `isReclaimed`: Boolean
- `provenanceNotes`: Text

### Order
Purchase record.
- `id`: String (UUID)
- `customerEmail`: String
- `customerName`: String
- `status`: Enum (PENDING, PAID, FULFILLED, CANCELLED)
- `paymentStatus`: Enum (UNPAID, PAID, REFUNDED)
- `fulfillmentMode`: Enum (SHIPPED, PICKUP)
- `stripeCheckoutSessionId`: String?
- `stripePaymentIntentId`: String?
- `totalAmount`: Decimal
- `createdAt`, `updatedAt`: DateTime

### OrderItem
Snapshot of purchased product/price.
- `id`: String (UUID)
- `orderId`: String (FK to Order)
- `productId`: String (FK to Product)
- `priceSnapshot`: Decimal
- `quantity`: Integer

### Inquiry
Quote, reserve, custom request, or product question.
- `id`: String (UUID)
- `type`: Enum (QUOTE, RESERVE, CUSTOM, QUESTION)
- `productId`: String? (FK to Product, if applicable)
- `customerName`: String
- `customerEmail`: String
- `message`: Text
- `dimensionsNotes`: Text?
- `status`: Enum (OPEN, IN_PROGRESS, CLOSED)
- `createdAt`, `updatedAt`: DateTime

### AuditLog
Admin activity history for security and tracking.
- `id`: String (UUID)
- `userId`: String (FK to User)
- `action`: String (e.g., "PRODUCT_UPDATE")
- `entityId`: String
- `entityType`: String
- `beforeSnapshot`: JSON
- `afterSnapshot`: JSON
- `createdAt`: DateTime

### SiteSettings
Brand copy, contact, social links, and featured products.
- `id`: String (singleton)
- `brandCopy`: Text
- `contactEmail`: String
- `socialLinks`: JSON
- `policySnippets`: JSON
- `updatedAt`: DateTime

# System Architecture

## Overview
Wrought Works is built as a **Modular Monolith** using Next.js. This simplifies testing, deployment, and operational overhead while remaining highly scalable for a single-brand artisan ecommerce store.

## Tech Stack
- **Framework**: Next.js App Router (React)
- **Language**: TypeScript
- **Styling**: Tailwind CSS + shadcn/ui components
- **Database**: PostgreSQL (Production) / SQLite (Development)
- **ORM**: Prisma
- **Data Validation**: Zod
- **Authentication**: Custom admin-only authentication (or NextAuth for admin)
- **Payments**: Stripe Checkout
- **Email**: SMTP or Resend
- **Media Storage**: Local storage for MVP/dev, S3-compatible for production
- **Deployment**: Vercel, Render, Fly, or Netlify
- **Testing**: Playwright (E2E), Vitest/Jest (Unit)

## Component Layers

### 1. Presentation Layer (App Router)
- React Server Components (RSC) to handle data fetching for product catalogs and details directly from the database without API overhead.
- Client Components where interactivity is required (e.g., image carousels, shopping cart state).
- Admin dashboard utilizing Server Actions for forms.

### 2. Business Logic Layer
- Handled largely via Next.js Server Actions to securely process mutations like cart checkouts, inquiries, and admin product updates.
- Validation logic centralized via Zod schemas.

### 3. Data Access Layer
- Prisma Client abstracting database operations.
- Migrations managed via Prisma CLI.

### 4. Integration Layer
- **Stripe**: Handles payment intents, checkouts, and webhooks for order fulfillment updates.
- **Resend/SMTP**: Sends transactional emails for quotes and admin notifications.

## Deployment Architecture
A standard PaaS deployment strategy where Next.js handles server-side rendering, API routes, and static asset serving. The database is hosted on a managed PostgreSQL provider. Media files are uploaded to an S3-compatible object store, serving via a CDN.

# Test Strategy

## Project Identity
- **Repository:** `WroughtWorks`
- **Stack:** Next.js 16 (App Router), TypeScript, Prisma, PostgreSQL, Tailwind CSS v4, Zustand, Stripe.

## Validation Lanes

### Lane 1: Fast Feedback (Local Developer)
- **Command:** `npm run dev`
- **Objective:** Ensure HMR (Hot Module Replacement) and immediate visual feedback loop works without database connection exhaustion.
- **Constraints:** 
  - Requires a local PostgreSQL container (or a `.env` database URL).
  - Stripe Checkout requires `STRIPE_SECRET_KEY` for API requests to succeed. Without it, the cart will throw an error on checkout.
  - Image uploads for new products fall back to the `public/uploads` directory.

### Lane 2: Build Confidence (Pre-Deployment)
- **Command:** `npm run build`
- **Objective:** Catch all TypeScript errors, Next.js static generation failures, and layout issues before deploying to production.
- **Rules:** 
  - A clean build (`exit code 0`) is strictly required before any code merges to `main`.
  - Prisma Client must be successfully generated (`npx prisma generate`).

### Lane 3: Database & Schema Synchronization
- **Command:** `npx prisma db push` & `npm run seed`
- **Objective:** Sync the Prisma schema with the Postgres database and seed it with realistic store mock data (categories, material sources, products) to ensure the UI behaves predictably.

### Lane 4: Stripe Webhook Local Validation
- **Command:** `stripe listen --forward-to localhost:3000/api/webhook/stripe`
- **Objective:** Ensures that after a successful payment on Stripe, the local environment can receive the `checkout.session.completed` event, mark the order as `PAID`, and flip the product status to `SOLD`.
- **Note:** The CLI output provides a Webhook Secret, which must be added to `.env` as `STRIPE_WEBHOOK_SECRET` for the signature verification to pass.

## Current Test Status
- **Next.js App Router Compilation:** PASSED (2026-06-18)
- **Database Connection via Prisma Singleton:** PASSED (2026-06-18)
- **Stripe Checkout API Type Checks:** PASSED (2026-06-18)
- **Admin Dashboard Auth Middleware:** PASSED (2026-06-18)

---
*Last Updated: 2026-06-18*

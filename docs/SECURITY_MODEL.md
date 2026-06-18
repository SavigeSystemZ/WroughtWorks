# Security Model

## 1. Authentication and Authorization
- **MVP Constraint**: Only the owner/admin requires authentication. There are no customer user accounts in the MVP.
- **Implementation**: Custom authentication or NextAuth utilizing HTTP-only cookies for session management.
- **Authorization**: All `/admin/*` routes and administrative Server Actions must perform server-side session validation to ensure the requesting user has the `ADMIN` role.

## 2. Payments Security
- **Stripe Checkout**: Payment information is never processed or stored on Wrought Works servers. Customers are redirected to Stripe-hosted checkout pages.
- **Webhook Integrity**: The `/api/webhooks/stripe` endpoint must cryptographically verify the `Stripe-Signature` header against the `STRIPE_WEBHOOK_SECRET` before processing any state changes (e.g., marking a product as sold).
- **Idempotency**: Webhook processing must be idempotent to prevent duplicate order creations in the event of Stripe sending duplicate events.

## 3. Data Protection and Validation
- **Input Validation**: All incoming requests and Server Action payloads must be strictly validated against Zod schemas before interacting with the database.
- **SQL Injection**: Prevented by the use of Prisma ORM, which uses parameterized queries.
- **XSS Prevention**: Next.js automatically escapes data rendered in React components. Markdown or rich text descriptions must be sanitized before rendering.

## 4. Media Upload Security
- Image uploads are restricted to authenticated admins.
- Upload endpoints must validate:
  - MIME Type (only `image/jpeg`, `image/png`, `image/webp`).
  - File Size (e.g., max 5MB per image).
- Filenames must be sanitized or replaced with UUIDs to prevent directory traversal attacks.

## 5. Rate Limiting
- Apply rate limiting to the public Inquiry/Quote submission form to prevent spam or DoS attacks.

## 6. Secrets Management
- No secrets (API keys, database URLs, etc.) are committed to the repository.
- Use `.env.local` for local development.
- Production secrets are managed via the hosting provider's environment variable interface.

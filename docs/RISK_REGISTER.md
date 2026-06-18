# Risk Register

## Product Risks
- **Inventory Mismatch**: A one-of-a-kind item is purchased online while simultaneously being sold locally.
  - *Mitigation*: The artisan must immediately mark items as "Reserved" or "Sold" via the admin dashboard when a local sale occurs. In the future, a fast-action mobile view for inventory management will be prioritized.
- **Shipping Estimates for Large Items**: Automated shipping calculators fail on heavily oversized or exceptionally heavy solid wood pieces.
  - *Mitigation*: Only standard-sized items will use direct checkout. Oversized/heavy items are explicitly flagged as `OVERSIZED` or `FREIGHT` and require a manual quote workflow.

## Technical Risks
- **Stripe Webhook Failures**: If webhooks fail to deliver, orders may not be marked as paid.
  - *Mitigation*: Implement robust logging around webhooks. Ensure idempotency so Stripe can safely retry failed deliveries. Include a manual sync/re-check button in the admin order dashboard.
- **Image Hosting Costs**: High-resolution imagery required for premium presentation could bloat storage or bandwidth costs.
  - *Mitigation*: Implement strict upload size limits and automatic image optimization via Next.js `next/image` component to serve WebP/AVIF formats based on device capability. Use an S3-compatible object store (e.g., Cloudflare R2) to minimize egress fees.
- **Admin Authentication Compromise**: Unauthorized access to the admin dashboard could lead to fraudulent product alterations or exposed customer data.
  - *Mitigation*: Enforce strong passwords or passwordless login (magic links). Do not store credit card data.

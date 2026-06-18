# API & Server Actions Design

In Next.js App Router, most mutations will be handled via Server Actions rather than traditional REST API endpoints. API endpoints (`/api/*`) are reserved for webhooks and external integrations.

## Server Actions

Server actions run securely on the server and are called directly from client or server components.

### Admin Actions
- `createProduct(data: ProductCreateInput)`: Creates a new product. Requires admin auth.
- `updateProduct(id: string, data: ProductUpdateInput)`: Updates an existing product. Requires admin auth.
- `deleteProduct(id: string)`: Archives/Hides a product. Requires admin auth.
- `updateSiteSettings(data: SiteSettingsUpdateInput)`: Updates global site settings. Requires admin auth.

### Customer Actions
- `submitInquiry(data: InquirySubmitInput)`: Submits a custom quote or product question. Sends an email to the admin and creates a database record.
- `createCheckoutSession(productId: string)`: Generates a Stripe Checkout session URL for a shippable product and redirects the user.

## Route Handlers (API Endpoints)

### `POST /api/webhooks/stripe`
Handles asynchronous events from Stripe.
- Validates the Stripe signature using `STRIPE_WEBHOOK_SECRET`.
- Processes `checkout.session.completed`:
  - Updates the `Order` status to `PAID`.
  - Marks the corresponding `Product` status as `SOLD`.
  - Sends a confirmation email to the customer.
  - Sends a notification email to the admin.

### `POST /api/upload`
Handles media uploads.
- Validates admin session.
- Validates file type (images only) and size.
- Uploads the file to local storage (dev) or an S3-compatible provider (production).
- Returns the URL of the uploaded image.

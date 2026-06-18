# Runbook

## Local Development Setup

1. **Install Dependencies**:
   ```bash
   npm install
   ```

2. **Environment Variables**:
   Copy the example environment file and fill in local values.
   ```bash
   cp .env.example .env.local
   ```
   *Note: For local development with SQLite, `DATABASE_URL` should point to `file:./dev.db`.*

3. **Database Setup**:
   Generate the Prisma client and push the schema to the local database.
   ```bash
   npx prisma generate
   npx prisma db push
   ```

4. **Seed the Database**:
   Populate the database with test admin users and sample products.
   ```bash
   npm run db:seed
   ```

5. **Start the Dev Server**:
   ```bash
   npm run dev
   ```
   The site will be available at `http://localhost:3000`.

## Database Migrations
When the `prisma/schema.prisma` file is updated:
1. Generate a new migration:
   ```bash
   npx prisma migrate dev --name <descriptive_name>
   ```
2. Apply migrations in production:
   ```bash
   npx prisma migrate deploy
   ```

## Testing
- **Unit/Component Tests**: `npm run test`
- **E2E Smoke Tests**: `npx playwright test`

## Stripe Webhook Testing (Local)
To test webhooks locally, use the Stripe CLI:
1. `stripe login`
2. `stripe listen --forward-to localhost:3000/api/webhooks/stripe`
3. Copy the webhook signing secret provided by the CLI into your `.env.local` as `STRIPE_WEBHOOK_SECRET`.

## Deployment
- Code merged to the `main` branch triggers an automatic build and deployment.
- Ensure production environment variables are correctly configured in the deployment dashboard before promoting a release.

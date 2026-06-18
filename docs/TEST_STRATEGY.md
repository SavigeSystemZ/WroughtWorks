# Test Strategy

## 1. Overview
The Wrought Works testing strategy prioritizes core user flows (browsing and checkout) and admin integrity (managing products without data loss). Given the Next.js App Router architecture, tests are split between unit/component tests and end-to-end (E2E) smoke tests.

## 2. Unit and Component Testing
**Tool**: Vitest or Jest
**Focus**:
- Isolated utility functions (e.g., currency formatting, dimension parsing).
- Core Zod validation schemas (ensuring products cannot be created with invalid prices or missing titles).
- Complex UI components (e.g., image gallery state management) in isolation using React Testing Library.

## 3. End-to-End (E2E) Smoke Testing
**Tool**: Playwright
**Focus**:
- **Public Catalog**: Navigating the homepage, filtering products, and successfully viewing a product detail page.
- **Checkout Handoff**: Adding a shippable product to the cart and verifying the Stripe Checkout redirect URL is generated correctly.
- **Inquiry Flow**: Submitting a custom quote form and verifying success state.
- **Admin Dashboard**: Logging in as an admin, navigating to the products list, and successfully submitting a new product form.

## 4. Manual QA
Before major releases, manual QA will be performed against a staging environment to verify:
- Cross-browser styling compatibility (especially Safari/iOS).
- Responsive layout scaling.
- The "Deep Glass" visual aesthetic renders correctly.
- Real Stripe webhook delivery processing.

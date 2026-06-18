# Product Brief

Use this file to capture the product idea, intended user value, and chosen build shape for this repo.

## Product frame

- Product name: WroughtWorks
- Product category: Premium Artisan Ecommerce Storefront
- One-line summary: A premium ecommerce platform for displaying and selling one-of-a-kind handmade natural wood and burl furniture, with direct purchase and custom quote flows.
- Why it should exist: To provide a story-rich, natural-material commerce experience where each unique handmade item has clear provenance, dimensions, and custom shipping constraints, unlike generic furniture stores.
- Primary users: Buyers of high-end, custom, or unique rustic home decor and furniture; and the admin/maker managing inventory and inquiries.
- Primary workflows: Browsing the gallery, filtering by material/size, purchasing shippable items, requesting quotes/reserves for oversized items, and admin CRUD for products.
- Success indicators: Successful end-to-end checkout flow via Stripe, and successful inquiry flow for a custom or oversized piece.
- Non-goals: Multi-seller marketplace, complex inventory sync with Etsy/Shopify, AI valuation, auction/bidding system.

## Experience bar

- Visual direction: "Deep Glass" aesthetics, tailored, premium, story-focused.
- Interaction bar: Fast, clear, low-friction flows with designed loading, empty, error, and success states.
- Performance bar: Excellent Lighthouse scores; fast image loading; snappy client-side navigation.
- Reliability bar: Clear degraded states, explicit error handling, robust payment idempotency.
- Trust and safety bar: Secure admin authentication, Stripe-validated payments, safe media upload handling.

## Build shape

- Recommended starter blueprint: Next.js App Router Monolith
- Recommendation confidence: High
- Recommendation rationale: The user has explicitly selected the Next.js App Router + TypeScript + Tailwind + Prisma stack.
- Selected starter blueprint: Next.js App Router Monolith
- Why this blueprint fits: Modular, shippable, excellent for SEO and rich product galleries.
- Planned repo shape: `/app`, `/components`, `/lib`, `/server`, `/prisma`, `/docs`.
- First milestone: M1 (Canonical docs and app blueprint).
- Initial validation focus: Typecheck, lint, build, and basic unit test execution.
- Next decision gates: M2 (App skeleton and design system).

## Usage rules

- Keep this aligned with `_system/PROJECT_PROFILE.md`, `PLAN.md`, `ROADMAP.md`, `DESIGN_NOTES.md`, and `ARCHITECTURE_NOTES.md`.
- Keep this factual and product-specific; do not turn it into vague aspiration or marketing filler.

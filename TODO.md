# TODO

**Scope:** This file is the **installable template’s** default execution queue for **new application repos** that copy `TEMPLATE/`. Unchecked items are **expected** until the product team fills them in. **Master AIAST source-repo** maintainer backlog lives under `_META_AGENT_SYSTEM/` (`TODO.md`, `COMPLETION_SHEET.md`, `AIAST_CAPABILITY_STATUS.md`)—do not confuse the two.

This is the active execution queue. Keep it tight, factual, and ordered.
Use priority signals: **CRITICAL**, **HIGH**, **MEDIUM**, **LOW** (see
`_system/HANDOFF_PROTOCOL.md` for definitions).

## Current Priority

- [ ] LOW: Search and filtering functionality on `/catalog`.

## Immediate Queue

- [ ] LOW: Keep design, architecture, research, risk, and release surfaces aligned with repo reality.

## Next Queue

- [ ] LOW: Gather product team feedback.

## Completed

- [x] MEDIUM: Record the repo's real validation lane in `TEST_STRATEGY.md` after the first successful repo-local check.

- [x] LOW: Wire up email notifications (mocked) for Custom Commission forms.
- [x] MEDIUM: Add image upload capabilities (Local FS MVP fallback) to Admin for creating new products.
- [x] MEDIUM: Create `/about` and `/contact` static pages.
- [x] HIGH: Set up admin dashboard for managing products, tracking orders, and seeing customer inquiries.
- [x] HIGH: Implement basic authentication for the Admin panel.
- [x] HIGH: Implement the cart state management and UI (Slide-over).
- [x] HIGH: Implement Stripe checkout integration for purchasing available pieces.
- [x] HIGH: Implement the custom commission inquiry form (`/custom`).
- [x] HIGH: Implement detailed individual product display pages (`/catalog/[slug]`).
- [x] HIGH: Implement the product catalog grid (`/catalog`).
- [x] HIGH: Create a database seed script (`prisma/seed.ts`) and populate mock data.
- [x] HIGH: Scaffold the Next.js App Router application in `app/`.
- [x] HIGH: Setup Prisma schema and PostgreSQL database connectivity.
- [x] HIGH: Establish the basic Tailwind CSS configuration with the "Deep Glass" aesthetic.
- [x] MEDIUM: Create the foundational UI layout (Header, Footer, Navigation).
- [x] HIGH: Establish the first validated baseline for WroughtWorks (Milestone 1 completed 2026-06-18)

## Usage rules

- Keep this file current enough that another tool can pick up immediately.
- Use priority signals so the next agent knows what to work on first.
- Mark items `[x]` only when fully done, not "mostly done."
- Add discovered work before handoff even if it is low priority.
- Keep product framing in `PRODUCT_BRIEF.md`, product sequencing in `ROADMAP.md`, and active execution structure in `PLAN.md`.

---

*Template baseline reviewed: 2026-06-18.*

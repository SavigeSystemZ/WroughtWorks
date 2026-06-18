# Project Profile

Fill this file in immediately after copying the operating system into a real repo. The stronger and more specific this file is, the better every agent will perform.

## After scaffold (customize for your app)

1. Replace every `- App name:` / `- Repo purpose:` style blank with **your** product truth.
2. Keep `_system/` as the agent operating layer; put runtime code outside it (see `AGENTS.md`).
3. If you use governed ports, follow `_system/ports/PORT_POLICY.md` and record bindings under `registry/`.
4. Re-run `bootstrap/validate-system.sh . --strict` after meaningful edits.
5. See `_system/INSTALLER_AND_UPGRADE_CONTRACT.md` for how installs and upgrades preserve app-owned state.
6. Copy `_system/PROJECT_DOMAIN_MANIFEST.template.json` to `_system/PROJECT_DOMAIN_MANIFEST.json` if missing, then set `product_summary`, `primary_domains`, and `instruction_mismatch_guards` so agents can reject prompts meant for other products (see `_system/INSTRUCTION_DOMAIN_ALIGNMENT_PROTOCOL.md`).

## Completion status

- [x] Identity filled
- [x] Runtime boundaries filled
- [x] Stack filled
- [x] Components filled
- [x] Build, packaging, and install filled
- [x] Mobile and AI filled
- [x] Validation commands filled
- [x] Operations and deployment filled
- [x] Security and compliance filled
- [x] Observability filled
- [x] Constraints filled
- [x] MCP plan filled
- [x] Canonical docs filled
- [x] Experience targets filled
- [x] Release model filled

## Identity

- App name: WroughtWorks
- App id: io.aiaast.wroughtworks
- Desktop entry id: io.aiaast.wroughtworks
- Android application id: io.aiaast.wroughtworks
- Repo purpose: A premium ecommerce platform for artisan natural wood furniture.
- Product category: Ecommerce / Retail
- Primary users: Buyers of high-end rustic furniture and the admin managing the store.
- Main workflows: Browsing products, filtering, purchasing, requesting quotes, admin product management.
- Primary success criteria: Successful checkout and quote inquiry flows.
- Non-goals: Marketplace, AI valuation, auction system.

## Runtime boundaries

- Runtime code roots: app/, components/, lib/, server/, prisma/
- Test roots: tests/
- Scripts / tooling roots: tools/, ops/
- Packaging / deploy roots: ops/, packaging/, mobile/, ai/
- Infrastructure roots:  TBD
- Agent-system root: `_system/`
- No-touch zones: `.git/`, `_system/` (for runtime code)

## Stack

- Primary languages: TypeScript, CSS
- Primary frameworks: Next.js (App Router), React
- Components: Tailwind CSS, shadcn/ui
- Datastores: PostgreSQL (production), SQLite (dev)
- Package managers: npm or pnpm
- Build tools: Next.js build
- Runtime environments: Node.js
- Supported environments: Modern web browsers
- Deployment targets: Vercel / Render / Fly

## Build and packaging

- Packaging targets: Web application
- Native package targets: N/A
- Universal package targets: Docker (optional)
- Packaging manifest paths: packaging/flatpak-manifest.json, packaging/appimage.yml, packaging/snapcraft.yaml
- Installer commands: ops/install/install.sh
- Signing identity:  TBD
- Minimum runtime versions: Node.js 18+
- System dependencies:  TBD
- Build entrypoints:  TBD
- Release artifacts: Next.js build output

## Validation commands

- Format: Prettier
- Lint: ESLint
- Typecheck: tsc --noEmit
- Unit tests: Vitest or Jest
- Integration tests: Playwright
- End-to-end or smoke: Playwright
- Build: npm run build
- Install / launch verification: npm run dev
- Packaging verification:  TBD
- Visual regression or design smoke: Playwright
- Security or policy checks: bootstrap/scan-security.sh /home/whyte/.MyAppZ/WroughtWorks

## Mobile and AI

- Mobile targets: Responsive Web (no native mobile app MVP)
- Android module path: mobile/flutter/android
- Mobile release artifacts:  TBD
- Mobile build flavors:  TBD
- LLM config path: ai/llm_config.yaml
- Default LLM provider:  TBD
- Chatbot surfaces:  TBD
- Command bus or action registry:  TBD
- Local documentation sources: docs/

## Operations and deployment

- Default ports: 3000 (dev)
- Default port range:  TBD
- Bind model:  TBD
- Required background services: Database (PostgreSQL)
- Service model: Web Server
- Migration model: Prisma Migrate
- Database mode: Relational
- Container runtime preference: Docker (if used)
- Service account model:  TBD
- Required env vars: DATABASE_URL, STRIPE_SECRET_KEY, NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY, RESEND_API_KEY
- Optional providers:  TBD
- Known degraded modes: Read-only catalog if Stripe is down
- Backup location:  TBD
- Filesystem layout:  TBD
- Environment files: .env.local
- Reverse proxy or ingress:  TBD

## Security and compliance

- Safety / compliance: PCI compliance handled via Stripe Checkout
- Security: Admin routes require authentication
- Secret handling: Environment variables only, never committed
- Data classification: Customer PII (emails, addresses) treated as sensitive
- Audit or retention requirements: Admin actions logged to AuditLog table
- Threat model doc: docs/SECURITY_MODEL.md

## Observability

- Structured logging surface: Console / Vercel Logs
- Metrics surface:  TBD
- Health or readiness surface: /api/health
- Tracing or profiling surface:  TBD
- Alerting or dashboards:  TBD

## Constraints

- Performance: Fast LCP for product images
- UI / design: "Deep Glass" aesthetics, responsive
- Accessibility expectations: WCAG AA
- Data integrity: Strong foreign keys via Prisma
- Release / packaging:  TBD
- Repo workflow: Main branch deployments
- Compatibility requirements: Evergreen browsers

## MCP plan

- Project-scoped servers:  TBD
- User-level shared servers:  TBD
- Isolation boundary:  TBD
- State/cache location:  TBD
- Read-only defaults:  TBD
- Elevation rules:  TBD
- Servers to avoid:  TBD

## Canonical docs

- Product spec: docs/PRD.md
- Architecture: docs/ARCHITECTURE.md
- Data model: docs/DATA_MODEL.md
- Runbook: docs/RUNBOOK.md
- Standards: docs/UX_SYSTEM.md, docs/NFR.md
- Threat model: docs/SECURITY_MODEL.md
- Additional design docs: docs/API_DESIGN.md, docs/TEST_STRATEGY.md, docs/RISK_REGISTER.md

## Experience targets

- Visual quality bar: High (Premium, Artisan, Deep Glass)
- Interaction quality bar: Smooth, responsive, no jank
- Performance quality bar: < 2.5s LCP
- Accessibility expectations: Semantic HTML, aria labels
- Device targets: Mobile, Tablet, Desktop
- Brand or tone constraints: Authentic, high-quality, natural

## Release model

- Environments: Development, Production
- Branch strategy: main for runtime code, system for copied AIAST updates
- Rollout method: Vercel standard rollout
- Backout method: Vercel instant rollback
- Release signoff: Owner validation
- Post-release verification: Playwright smoke tests

## High-value conventions

- Naming conventions: PascalCase for components, camelCase for functions
- Module boundary rules: UI components stay in components/, business logic in server/ or lib/
- Logging rules: Never log PII or payment details
- Testing rules: E2E for critical flows (checkout, admin)
- Handoff expectations:  TBD
- Documentation update expectations: Keep canonical docs in sync with PRs

# Your Project-Owned Meta-System — what you may improve, and how

**Read this if you are working in a `downstream-app` repo.** Resolve your role
first via `_system/.aiast-role.json` (or `bootstrap/check-app-definition-state.sh`).
If `role = parent-template`, this guide does not apply to you — see
`SELF_IMPROVEMENT_PROTOCOL.md` (the maintainer loop) instead.

## The one thing to understand

The `_system/` and `bootstrap/` in **this** repository are **a copy of the
AIAST meta-system that this project now owns.** They were installed here so you
can build *one specific application* in `app/`. This copy is **yours to tailor
for this project's needs** — you are encouraged to expand, add to, and adapt it
so it serves *this* app better.

This is the **positive complement** to the drift disclosure at the top of
`AGENTS.md`. That disclosure says: never reach out and modify the *parent*
`_AI_AGENT_SYSTEM_TEMPLATE` template, or another app's `_system/`. This guide
says: the copy **inside this repo** is a different thing — it is project-owned,
and improving it in place is expected and safe when you follow the loop below.

So the boundary is simple:

- ✅ Improve **this repo's own** meta-system copy, in place, for this project.
- 🚫 Never modify the parent template or any other repo's meta-system.
- 🚫 Never let app-specific facts flow *back* into the parent template except as
  a sanitized, maintainer-gated promotion candidate (see the end of this guide).

> Note on `APP_REPO_IDENTITY.md`: when it says "do not edit/extend `_system/`
> as if improving the meta-system," it means **do not re-develop or re-scaffold
> the meta-system as if it were the product**, and do not start before the app
> is defined. It does **not** forbid tailoring your own copy for this app. Once
> the app is defined, project-local improvements are welcome — via this guide
> and `PROJECT_LOCAL_SELF_IMPROVEMENT_PROTOCOL.md`.

## What to expand / add / change / alter — by intent

Surfaces fall into three buckets. Knowing which is which keeps your changes safe
and keeps future template updates painless.

### 1. Customize freely — these are project-owned and meant to change

Fill these in and keep them current as the app evolves. No proposal needed;
this is just doing the work.

- **Working files:** `PRODUCT_BRIEF.md`, `PLAN.md`, `ROADMAP.md`, `TODO.md`,
  `FIXME.md`, `WHERE_LEFT_OFF.md`, `DESIGN_NOTES.md`, `ARCHITECTURE_NOTES.md`,
  `RESEARCH_NOTES.md`, `TEST_STRATEGY.md`, `RISK_REGISTER.md`,
  `RELEASE_NOTES.md`, `CHANGELOG.md`.
- **Project identity & profile:** `_system/PROJECT_PROFILE.md`,
  `_system/PROJECT_DOMAIN_MANIFEST.json`.
- **Durable project memory:** `_system/context/*.md` (assumptions, invariants,
  integration state, event timeline, shared agent memory).
- **App-specific context:** everything under `_system/app-context/` — author it
  per `_system/APP_CONTEXT_FILE_MATRIX.md` and
  `_system/APP_SPECIFIC_CONTEXT_AUTHORING_STANDARD.md`; generate the starter set
  with `bootstrap/generate-app-context-pack.sh` and the `fill-app-context`
  command.
- **App persona:** `_system/personas/APP_PERSONA.md` (forge with
  `forge-app-persona`).
- **The product:** everything under `app/`.
- **Per-app host settings:** the preserve-first `.<tool>/settings.json` siblings
  (e.g. `.claude/settings.json`, `.grok/settings.json`) — your machine/app
  preferences. (Leave the `.aiaast.*` siblings alone — see bucket 3.)

### 2. Extend additively — add new project-local surfaces (run the loop)

When this app needs operating-layer capability the template did not ship, **add
it locally** through `PROJECT_LOCAL_SELF_IMPROVEMENT_PROTOCOL.md`
(Detect → Propose → Apply `--local-only` → Validate → Record). Good examples:

- a project-local rule, policy, or prompt-pack variant tailored to this domain;
- a new validator or helper script specific to this app's stack;
- a new golden-example pattern drawn from this app;
- archetype/MCP/agent-isolation notes specific to this app.

Prefer **adding** alongside template surfaces over editing template ones. New
files you author here are project-owned and survive template updates cleanly.

### 3. Leave template-managed — change only with care, prefer upstreaming

These are delivered and updated by the template installer
(`bootstrap/update-template.sh`, preserve-first per
`DOWNSTREAM_PRESERVATION_AND_SYNC_NOTICE_POLICY.md`). Editing them in place
means you fork them and may fight future updates. If a change here is generic,
**tag it as a promotion candidate** instead of silently forking (bucket below).

- `bootstrap/*` core scripts and `bootstrap/lib/*`.
- `_system/` contracts, protocols, policies, and generated indexes
  (`host-adapter-manifest.json`, `KEY.md`, `SYSTEM_REGISTRY.json`,
  `AGENT_SURFACE_TAXONOMY.md`, `INTEGRITY_MANIFEST.sha256`, the policy-contracts,
  etc.).
- The meta-managed host-settings files (`.<tool>/settings.aiaast.json`,
  `.codex/config.aiaast.toml`, `.github/copilot-config.aiaast.json`).
- **Generated adapter files** (`CLAUDE.md`, `GEMINI.md`, `GROK.md`,
  `.cursorrules`, …): never hand-edit — change `host-adapter-manifest.json` and
  re-run `bootstrap/generate-host-adapters.sh`.

Not sure which bucket a file is in? Ask the classifier:
`bash bootstrap/lib/aiaast-classify.sh <relative/path>` (or check for a
`managed_by: _AI_AGENT_SYSTEM_TEMPLATE` marker — managed files carry it).

## How to make a change safely (the loop, in one screen)

```
# 1. Name the gap + evidence, then propose:
bash bootstrap/propose-local-self-improvement.sh \
  --title "<imperative title>" --scope "<path/surface in this repo>" \
  --reason "<gap + evidence>"

# 2. Apply, in-repo only (records base commit + reverse patch):
bash bootstrap/apply-local-self-improvement.sh <proposal-id> --local-only

# 3. Validate the changed scope:
bash bootstrap/check-local-self-improvement.sh .
bash bootstrap/validate-app-context-files.sh .   # if app-context changed
bash bootstrap/validate-system.sh . --strict

# 4. If it fails, roll back per SELF_WRITING_BOUNDARY_AND_ROLLBACK.md and revise.
```

Allowed / guarded / forbidden change classes, the write-scope rule (in-repo
only), and rollback discipline live in `SELF_WRITING_BOUNDARY_AND_ROLLBACK.md`.
Read it before applying anything to a bucket-3 surface.

## Giving back: generic improvements → promotion candidates

If a local improvement is **generic** (no app name/domain/URL/port/secret/
stack logic; helps *every* AIAST app), tag it so maintainers can sanitize and
promote it into the parent template — without you ever touching the parent:

```
bash bootstrap/tag-improvement-candidate.sh <file> \
  --description "Generic improvement found during this app build"
```

This only *records* a candidate in `_system/improvement-candidates.jsonl`.
Promotion stays maintainer-gated (`SELF_IMPROVEMENT_PROTOCOL.md`,
`SELF_IMPROVEMENT_PROMOTION_REVIEW_PROTOCOL.md`). App-specific facts must never
reach the parent template (`TEMPLATE_NEUTRALITY_POLICY.md`).

---
**Authority:** AIAST downstream operating guide; applies in `downstream-app`
repos. Subordinate to `INSTRUCTION_PRECEDENCE_CONTRACT.md` and the containment
and security contracts.
**Related:** `APP_REPO_IDENTITY.md`,
`PROJECT_LOCAL_SELF_IMPROVEMENT_PROTOCOL.md`,
`SELF_WRITING_BOUNDARY_AND_ROLLBACK.md`,
`APP_CONTEXT_FILE_MATRIX.md`, `APP_SPECIFIC_CONTEXT_AUTHORING_STANDARD.md`,
`DOWNSTREAM_PRESERVATION_AND_SYNC_NOTICE_POLICY.md`,
`WORKSPACE_AUTHORITY_AND_CONTAINMENT_PROTOCOL.md`, `TEMPLATE_NEUTRALITY_POLICY.md`.

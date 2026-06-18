# Decisions

Record durable decisions here.

## Entry format

- Date:
- Decision:
- Reason:
- Impact:
- Follow-up:
- Revisit trigger:

## Entries

### 2026-05-23 — Downstream self-improvement + app-context system shipped

- **Decision:** Ship the downstream-local self-improvement loop (`PROJECT_LOCAL_SELF_IMPROVEMENT_PROTOCOL.md`, `SELF_WRITING_BOUNDARY_AND_ROLLBACK.md`, `propose/apply/check-local-self-improvement.sh`) and the archetype-routed app-context authoring system (`APP_SPECIFIC_CONTEXT_AUTHORING_STANDARD.md`, `APP_CONTEXT_FILE_MATRIX.md`, `generate-app-context-pack.sh`, `validate-app-context-files.sh`, 8 universal placeholders + 51 archetype templates across 13 archetypes) as modular, optional, role/state-aware overlays mirroring the `APP_PERSONA_CONTRACT.md` precedent. Both are gated by `check-app-definition-state.sh`: no-op in `parent-template`, advisory in a blank app, enforced once `app_defined`.
- **Reason:** A downstream agent could not safely tailor its own local AIAST copy without crossing into the parent template, and the archetype packs (`_system/archetypes/*.md`) were neutral but had no mechanism to scaffold the project-specific context files an agent fills after archetype selection.
- **Impact:** New `policy-contracts/self-writing-boundary.json` (auto-discovered by `check-policy-contracts.sh`), 9th mutation in `mutation-catalogue.json` (kill-rate stays 100% — 9/9), two new factory smokes (`smoke-local-self-improvement.sh` 7 cases + `smoke-app-context.sh` 6 cases) wired into the master lane, runtime artifacts (`proposals/applied/rejected/ledger.jsonl`) gitignored and excluded from `aiaast_print_managed_files` (the S22b `.sig` lesson). Promotion of generic improvements stays maintainer-gated.
- **Follow-up:** Phase 7 — fleet propagation across the 31 repos using `run-downstream-additive.sh` (preserve-first additive, never `--refresh-managed`). Phase 8 — bump AIAST version coherently across all 5 metadata surfaces `validate-system.sh` checks, refresh `AIAST_CHANGELOG.md`, then merge to `main` only on explicit operator approval.
- **Revisit trigger:** If downstream agents in practice want a heavier in-loop validator (e.g. promotion of generic improvements from the downstream side), or if the policy-contract assertions need to tighten further after real fleet use.

### 2026-05-23 — Remove drift-causing `generated_at` from `_system/CAPABILITY_MATRIX.json`

- **Decision:** Drop the `generated_at` field from `bootstrap/discover-plugins.sh` so `_system/CAPABILITY_MATRIX.json` is fully deterministic.
- **Reason:** The previous value (`Path("/dev/null").stat().st_mtime`) was a placeholder never consumed by any reader, but it drifted whenever `/dev/null` mtime updated (typically across reboots). The file is tracked in git AND covered by the integrity manifest, so any drift caused the integrity check to fail.
- **Impact:** Capability matrix is now fully deterministic; integrity manifest stays clean across reboots and across multiple invocations of any flow that calls `discover-plugins.sh`.
- **Follow-up:** None — this is a one-shot fix.
- **Revisit trigger:** If a future feature legitimately needs a timestamp in the matrix, route it through a non-tracked sidecar file (mirror the `_system/checkpoints/` pattern).

### 2026-05-04 — Instruction domain manifest and alignment checks (installable)

- **Decision:** Ship `_system/PROJECT_DOMAIN_MANIFEST.json` (with schema), `INSTRUCTION_DOMAIN_ALIGNMENT_PROTOCOL.md`, and `bootstrap/check-instruction-domain-alignment.sh`, wired into `validate-system.sh` / `validate-instruction-layer.sh`, with `instruction-precedence.json` lists updated to match the prose precedence contract.
- **Reason:** Reduces wrong-product instruction collisions in multi-repo workspaces by making declared domain and keyword guards a first-class, machine-validated contract.
- **Impact:** New managed files and one new bootstrap validator; hosts and hooks can call the checker for deterministic mismatch signals (exit code 3 on guard hit).
- **Follow-up:** Downstream repos should fill `instruction_mismatch_guards` when they have sensitive cross-product vocabulary; neutral template keeps an empty guard list.
- **Revisit trigger:** If guard false-positive rate is high, refine keyword lists or add allow-listed task scoping in the protocol.

### 2026-04-12 — Import SACST governance mechanics in adapted form only

- **Decision:** Upgrade AIAST with SACST governance mechanics only, implemented as installable read-bundle, change-impact, self-healing-boundary, and version-sensitive-research contracts plus maintainer-only learning and promotion policy.
- **Reason:** AIAST was already stronger in app-builder breadth, host ingestion, orchestration, prompt emission, and adapter generation; the real gap was governance purity and promotion discipline, not infra-domain capability.
- **Impact:** Installable AIAST gained new `_system/` governance contracts while maintainer-only donor review and promotion doctrine stayed in `_META_AGENT_SYSTEM/` and `_TEMPLATE_FACTORY/`.
- **Follow-up:** Validate the tranche on real downstream app repos before broadening cross-template harvest rules or mirroring changes back into SACST.
- **Revisit trigger:** If bundle selection, change-impact governance, or promotion gates create repeated downstream friction that outweighs the drift they prevent.

### 2026-04-06 — GitHub PR and issue templates (installable template)

- **Decision:** Ship `.github/pull_request_template.md` and `.github/ISSUE_TEMPLATE/` with the template so downstream repos inherit merge and triage discipline without ad hoc copy-paste.
- **Reason:** Reduces bad merges, documents validation expectations, pairs with GitHub / CI steward role and `HOOK_AND_ORCHESTRATION_INDEX.md`.
- **Impact:** New files under `.github/` in copied repos; optional for teams that delete them.
- **Follow-up:** Master AIAST repo also uses root `.github/` templates for layer-specific checklists.
- **Revisit trigger:** If GitHub changes issue template schema or org-wide templates override repo templates.

### 2026-04-06 — Working-file freshness pass

- **Decision:** Refresh `PLAN.md`, `FIXME.md`, `RISK_REGISTER.md`, `TEST_STRATEGY.md` with baseline text and explicit template-review stamp to satisfy staleness checks and give downstream a clearer default.
- **Reason:** `check-working-file-staleness.sh` uses git history; substantive content + commit clears warnings and improves handoff quality.
- **Impact:** Downstream repos may merge or replace sections when they diverge from placeholder baselines.

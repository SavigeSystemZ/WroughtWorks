# Release Notes

Last updated: 2026-06-18

Use this file for the current candidate release or milestone summary.

## Current release target

- Target label: AIAST **1.23.0**
- Intended audience: AIAST maintainers, downstream app-repo agents, and operators who want cross-agent resume safety after rate limits, crashes, or deliberate handoffs
- Release goal: ship a first-class, agent-neutral mid-session checkpoint capability into the installable template so any agent (Claude, Codex, Cursor, Gemini, Windsurf, DeepSeek, Cline, Continue, Aider, PearAI, local models, or a human) can resume cleanly from whoever was interrupted — and harden `bootstrap/update-template.sh` against its own self-modification hazard.
- Release confidence: high after `_TEMPLATE_FACTORY/run-maintainer-lane.sh` → `maintainer_lane_ok`, `_TEMPLATE_FACTORY/run-automation-lane.sh` → `automation_lane_ok`, and `bootstrap/system-doctor.sh TEMPLATE --strict` → `system_doctor_ok` on the master source tree on 2026-04-14
- **Tag status (source repo):** annotated tag **`v1.23.0`** marks this minor release once the release commit lands on `main`.

## User-visible changes

- **New `bootstrap/write-checkpoint.sh` and `bootstrap/resume-from-checkpoint.sh`:** agent-neutral writer and reader for mid-session resume checkpoints under `_system/checkpoints/`. Five kinds (`session-start`, `mid-task`, `handoff`, `rate-limit-save`, `milestone`), JSON + Markdown pair, append-only history, atomic writes, no new runtime dependencies.
- **Expanded `_system/CHECKPOINT_PROTOCOL.md`:** mid-session semantics, required fields, writing and reading examples, rules, and the relationship between checkpoints, `WHERE_LEFT_OFF.md`, and `HANDOFF_PROTOCOL.md`.
- **New `_system/checkpoints/README.md`:** seed doc that ships with every installed downstream, describing the checkpoint directory layout and rules.
- **Startup wiring:** `_system/CONTEXT_INDEX.md`, `_system/LOAD_ORDER.md`, `_system/MASTER_SYSTEM_PROMPT.md`, and `_system/SYSTEM_AWARENESS_PROTOCOL.md` now instruct every agent to run `bash bootstrap/resume-from-checkpoint.sh .` on cold start, to write a checkpoint before stopping for any reason, and to persist a `rate-limit-save` before any command that could exhaust the remaining token/time budget.
- **Hardened `bootstrap/update-template.sh`:** a new re-exec guard detects drift between the installed and source copies of the script and re-execs from a stable tempfile before touching any managed files, closing the bash self-modification bug that could corrupt the running parser mid-refresh. Guarded by `AIAST_UPDATE_REEXEC` against infinite re-exec loops, with an `EXIT` trap that cleans up the tempfile.
- **New `cross_agent_checkpointing` capability flag** and `checkpoint_protocol`, `checkpoint_writer`, `checkpoint_reader`, `checkpoints_directory` markers in `_system/aiaast-capabilities.json`.

## Upgrade or migration notes

- Existing downstream repos pick up this release through `bootstrap/update-template.sh --refresh-managed --strict`. A repo that is still running the pre-fix installed copy of the update script should run the **source** template's script once to clear the self-modification hazard; subsequent upgrades can use the installed copy because the re-exec guard is now part of the managed surface.
- The new `_system/checkpoints/` directory is created empty on install — `LATEST.json`, `LATEST.md`, and files under `history/` are runtime artifacts written by whichever agent runs first. The awareness check does not require them to exist at install time.
- No breaking runtime API changes. The checkpoint slice is purely additive capability; all prior validators, generators, and governance surfaces continue to work unchanged.

## Known limitations

- The maintainer lane currently writes its checkpoint under `_META_AGENT_SYSTEM/checkpoints/` by direct file edit rather than via `bootstrap/write-checkpoint.sh`. A dedicated maintainer-side wrapper is a follow-up; until it ships, read maintainer checkpoints by opening `LATEST.md` directly.
- Template `PLAN.md` / `FIXME.md` remain neutral until replaced in a real product repo.
- Downstream repos still need their own repo-local proof after upgrade; passing the source-template automation lane does not replace app-specific validation.

## In-progress hardening slice (post-1.23.0, unreleased)

- Fixed Heretic wrapper discovery and capability exposure: TBD
  - `_system/plugins/heretic-abliteration/plugin.json`
  - `_system/plugins/heretic-abliteration/run.sh`
  - actual donor path fallback plus `HERETIC_DIR` override
- Corrected Antigravity host settings and MCP guidance: TBD
  - all 7 host settings baselines pass
  - user-local `~/.gemini/config/mcp_config.json` must be valid JSON
  - host-launch policy contracts now cover `.antigravitycli/settings.aiaast.json`
- Added a dual-metasystem unification layer for adapter taxonomy and external init convergence: TBD
  - `_system/AGENT_SURFACE_TAXONOMY.md`
  - `_system/AGENT_INIT_CONVERGENCE.md`
  - `_system/OPERATOR_PROMPTING_PLAYBOOK.md`
- Added compatibility adapter placeholders for broader cross-agent scaffold parity: TBD
  - `CURSOR.md`
  - `COPILOT.md`
  - `AIDER.md`
  - `AGENT_ZERO.md`
- Added `bootstrap/check-agent-surface-integrity.sh` and integrated it into source-template factory validation.
- Regenerated adapter outputs, system registry, and integrity manifest after contract updates.
- Added `bootstrap/sync-metasystem-contracts.sh` for one-command contract regeneration + validation.
- Added `bootstrap/migrate-agent-surface-upgrade.sh` for downstream upgrade dry-runs and applied migrations.
- Added factory-level parity and quality gates: TBD
  - `_TEMPLATE_FACTORY/check-aiast-mos-parity.sh`
  - `_TEMPLATE_FACTORY/check-metasystem-quality-gate.sh`
- Upgraded adapter alias lifecycle metadata and validation enforcement in `_system/host-adapter-manifest.json` and host-adapter validators.

## In-progress app-builder tranche (post-1.23.0, unreleased)

- Added deterministic app-builder execution stack: TBD
  - `_system/APP_BUILDER_META_SYSTEM_ORCHESTRATION.md`
  - `_system/APP_BUILDER_DOMAIN_ADAPTATION_RAILS.md`
  - `_system/APP_BUILDER_SECURITY_AND_AUTO_CORRECTION_CONTRACT.md`
  - `_system/APP_BUILDER_REGRESSION_AND_BENCHMARK_PROTOCOL.md`
  - `_system/APP_BUILDER_RELEASE_READINESS_STANDARD.md`
- Added app-builder prompt-pack execution surface: TBD
  - `_system/prompt-packs/M17_APP_BUILDER_META_SYSTEM_EXECUTION.md`
- Cross-linked into core discovery/startup docs: TBD
  - `_system/CONTEXT_INDEX.md`
  - `_system/LOAD_ORDER.md`
  - `_system/PROMPTS_INDEX.md`
- Validation evidence (run as `whyte`):
  - strict instruction and system lanes pass (`validate-instruction-layer`, `check-system-awareness`, `system-doctor`, `validate-system --strict`)
  - `_TEMPLATE_FACTORY/run-automation-lane.sh` -> `automation_lane_ok`
  - `_MOS_TEMPLATE_FACTORY/run-automation-lane.sh` -> `mos_template_validation_ok`

### Builder benchmark metrics template

Use this for any builder-lane release entry touching app-builder contracts,
prompt packs, or discovery/index surfaces.

- Routing accuracy: `<x>/<y>` fixtures selected expected lane/archetype.
- Bounded-repair success: `<x>/<y>` failures closed within two bounded attempts.
- Containment adherence: `<x>/<y>` fixtures completed without forbidden operations.

## In-progress ultra expansion v2 tranche (post-1.23.0, unreleased)

- Productionized super-template map generation and lane anchors.
- Expanded scaffold profile matrix into full contract fields and added: TBD
  - `bootstrap/validate-scaffold-profiles.sh`
  - `_system/SCAFFOLD_PROFILE_AUTHORING_STANDARD.md`
- Expanded archetype routing and added authoring + validation:
  - `bootstrap/validate-archetype-packs.sh`
  - `_system/APP_ARCHETYPE_PACK_AUTHORING_STANDARD.md`
  - new archetype packs under `_system/archetypes/`
- Added delivery/validation/fleet/quality/reporting/harvest/test-campaign protocols
  and executable scripts for bounded autopilot workflows.
- Evidence artifacts: link `_META_AGENT_SYSTEM/evidence/APP_BUILDER_*.md`.

## In-progress finalization v3 tranche (post-1.23.0, unreleased)

- Master-map productionization now supports registry `entries` shape with legacy
  `files` fallback.
- Master-map completeness gate now fails when managed count is zero.
- Added archetype persona + placeholder governance surfaces:
  - `_system/APP_ARCHETYPE_PERSONA_CATALOG.md`
  - `_system/PROJECT_SPECIFIC_PLACEHOLDER_FILE_STANDARD.md`
- Hardened autopilot scripts: TBD
  - strict validation mode in `run-validation-autopilot.sh`
  - fixed temp-output handling in `run-app-delivery-autopilot.sh`
  - corrected pathing in `discover-validation-commands.sh`
- Added maintainer governance and benchmark closure docs: TBD
  - `_META_AGENT_SYSTEM/QUALITY_SCORECARD.md`
  - `_META_AGENT_SYSTEM/BENCHMARK_CAMPAIGN_PLAN.md`
  - `_META_AGENT_SYSTEM/PROMOTION_GATES.md`
  - `_META_AGENT_SYSTEM/ROLLBACK_CHECKLIST.md`
- Evidence packet: TBD
  - `_META_AGENT_SYSTEM/evidence/APP_BUILDER_FINALIZATION_V3_2026-05-07.md`

## In-progress post-v3 wave p1 tranche (post-1.23.0, unreleased)

- Added benchmark matrix execution/report surface: TBD
  - `bootstrap/run-test-app-benchmark-matrix.sh`
- Added externalized quality score policy: TBD
  - `_system/QUALITY_SCORE_POLICY.json`
  - `bootstrap/score-quality-gates.sh` now reads policy weights
  - `bootstrap/validate-quality-score-reproducibility.sh`
- Added evidence lifecycle hygiene: TBD
  - `_system/EVIDENCE_RETENTION_AND_ROTATION_POLICY.md`
  - `bootstrap/check-evidence-retention.sh`
- Added release packet generator: TBD
  - `bootstrap/generate-release-packet.sh` (dry-run default)
- Evidence packet: TBD
  - `_META_AGENT_SYSTEM/evidence/APP_BUILDER_POST_V3_P1_2026-05-07.md`

## In-progress post-v3 wave p2 tranche (post-1.23.0, unreleased)

- Benchmark matrix runner upgraded with executable cell mode: TBD
  - `bootstrap/run-test-app-benchmark-matrix.sh --execute`
  - per-cell pass/fail + timing in JSON/Markdown reports
- Quality scoring now guarded by explicit policy validator: TBD
  - `bootstrap/validate-quality-score-policy.sh`
  - `_system/quality-gates/quality-score-policy.schema.json`
  - `_system/QUALITY_SCORE_POLICY.json` includes `expected_weight_sum`
- Retention checker now supports protected evidence allowlist: TBD
  - `_system/EVIDENCE_RETENTION_PROTECTED_ALLOWLIST.txt`
  - `bootstrap/check-evidence-retention.sh --allowlist`
- Release packet now emits checksum manifest path: TBD
  - `bootstrap/generate-release-packet.sh` -> `checksums`
- Evidence packet: TBD
  - `_META_AGENT_SYSTEM/evidence/APP_BUILDER_POST_V3_P2_2026-05-07.md`

## In-progress post-v3 wave p3 tranche (post-1.23.0, unreleased)

- Benchmark matrix execution now scaffolds an isolated repo per executed cell: TBD
  - profile/archetype/mode scoped with `--profiles`, `--archetypes`,
    `--mode`, and `--limit-cells`
  - transient cell repos by default; `--apply` retains them for inspection
  - reports include gate count, duration, retained/transient state, command
    arrays, output hashes, and bounded output tails
- Archetype pack emission now refreshes generated registry and integrity state
  after write-mode `ACTIVE_ARCHETYPE.txt` changes.
- Quality score policy upgraded to `1.1.0`:
  - explicit `required_weight_keys`
  - semantic-version gate
  - exact weight-key matching
  - descending label threshold validation
- Release packet generator upgraded to packet `3.0.0`:
  - deterministic sorted artifact index
  - checksum manifest for indexed artifacts
  - checksum-backed signature metadata block
- Evidence packet: TBD
  - `_META_AGENT_SYSTEM/evidence/APP_BUILDER_POST_V3_P3_2026-05-07.md`

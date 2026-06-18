# Changelog

Use this file for meaningful repo-visible change history. Keep transient task chatter in `TODO.md` or `WHERE_LEFT_OFF.md`.

## Unreleased

- Fixed the Heretic plugin integration so downstream agents discover the capability through `_system/CAPABILITY_MATRIX.json`, the wrapper resolves both the actual donor checkout path and a `HERETIC_DIR` override, and MOS validation gates require the plugin manifest/runner.
- Added Antigravity MCP guidance for the user-local `~/.gemini/config/mcp_config.json` failure mode, corrected Antigravity host-settings metadata to use JSON deep-merge rather than native merge, and enrolled Antigravity in host-launch policy coverage.
- Added app-builder meta-system tranche A-D contracts for deterministic orchestration, domain adaptation, security-bounded auto-correction, and release readiness.
- Added prompt pack `_system/prompt-packs/M17_APP_BUILDER_META_SYSTEM_EXECUTION.md` for app-builder execution workflows.
- Updated discovery and startup surfaces (`_system/CONTEXT_INDEX.md`, `_system/LOAD_ORDER.md`, `_system/PROMPTS_INDEX.md`) to include the new app-builder lane contracts.
- Updated `_system/PROJECT_DOMAIN_MANIFEST.json` with stronger template-source mismatch guards for off-domain runtime requests.
- Refreshed generated surfaces after contract expansion (`_system/SYSTEM_REGISTRY.json`, `_system/KEY.md`, `_system/INTEGRITY_MANIFEST.sha256`).

- Added `bootstrap/sync-metasystem-contracts.sh` as the preferred one-command regeneration and validation flow for adapter/governance contract changes.
- Added `bootstrap/migrate-agent-surface-upgrade.sh` to stage and apply dual-metasystem adapter-surface upgrades in downstream repos with dry-run reporting.
- Added factory checks `_TEMPLATE_FACTORY/check-aiast-mos-parity.sh` and `_TEMPLATE_FACTORY/check-metasystem-quality-gate.sh`, and wired both into `_TEMPLATE_FACTORY/validate-master-template.sh`.
- Extended adapter deprecation metadata in `_system/host-adapter-manifest.json` with lifecycle fields (`deprecated_since`, `remove_after`, `migration_doc`) and validator enforcement.
- Added `_system/AGENT_SURFACE_TAXONOMY.md` to standardize adapter classes, naming conventions, placeholder boundaries, and validation rules.
- Added `_system/AGENT_INIT_CONVERGENCE.md` to map external multi-agent init patterns into installable AIAST contracts.
- Added `_system/OPERATOR_PROMPTING_PLAYBOOK.md` with execution-contract templates, continuous-run protocol, and multi-agent orchestration patterns.
- Added compatibility placeholders: `CURSOR.md`, `COPILOT.md`, `AIDER.md`, `AGENT_ZERO.md`.
- Added `bootstrap/check-agent-surface-integrity.sh` and wired it into `_TEMPLATE_FACTORY/validate-master-template.sh`.
- Updated `_system/HOST_ADAPTER_POLICY.md`, `_system/INSTRUCTION_PRECEDENCE_CONTRACT.md`, `_system/MULTI_AGENT_COORDINATION.md`, `_system/AGENT_DISCOVERY_MATRIX.md`, `_system/CONTEXT_INDEX.md`, and `AGENTS.md` to enforce taxonomy and convergence rules.

## 1.22.1 (2026-04-12)

- Patch release: closes the downstream-proof fixes uncovered by the first
  `1.22.0` replay and aligns installable semver markers with source tag
  **`v1.22.1`**.
- `bootstrap/update-template.sh` now repairs managed-file mode drift even when
  content already matches the source template, so executable bootstrap surfaces
  recover their `+x` bit during downstream refreshes.
- Integrity manifests now track the real managed installable surface instead of
  transient bytecode or repo-local runtime trees; `distribution/`, `docs/`,
  `notes/`, `.credits-hidden`, `LICENSE`, and `NOTICE` are included.
- Downstream proof on a production-scale repo exposed and closed the installed-doc
  boundary leak around hard-coded master-template paths; the proof playbook now
  requires sanitizing installed continuity docs when strict validation catches a
  forbidden maintainer source-clone path.

## 1.22.0 (2026-04-12)

- Minor release: preservation-first governance hardening imported from SACST in
  adapted form only, without sysadmin-domain contamination.
- Added `_system/READ_BUNDLES.md`,
  `_system/TEMPLATE_CHANGE_IMPACT_POLICY.md`,
  `_system/SELF_HEALING_BOUNDARY.md`, and
  `_system/VERSION_SENSITIVE_RESEARCH_PROTOCOL.md`.
- Added maintainer-only learning-loop, promotion, harvest-policy, and donor-review
  surfaces in the master-repo meta workspace, plus factory checks
  `_TEMPLATE_FACTORY/check-template-impact.sh` and
  `_TEMPLATE_FACTORY/check-promotion-readiness.sh`.
- Tightened precedence, prompt-emission, host-bundle, load-order,
  operating-profile, awareness, and conflict-detection surfaces so bundle,
  repair, research, and promotion governance stay aligned.
- Regenerated host adapters, `_system/KEY.md`, `_system/SYSTEM_REGISTRY.json`,
  `_system/repo-operating-profile.json`, and `_system/INTEGRITY_MANIFEST.sha256`
  for the 1.22.0 surface.
- `_TEMPLATE_FACTORY/run-maintainer-lane.sh` and
  `_TEMPLATE_FACTORY/run-automation-lane.sh` both passed on 2026-04-12.

## 1.21.1 (2026-04-06)

- Patch release: installable semver and JSON markers (`AIAST_VERSION.md`,
  `_system/.template-version`, `instruction-precedence.json`, `.template-install.json`,
  `aiaast-capabilities.json`) aligned with git tag **`v1.21.1`**; plugin manifests
  `aiast_min_version` **1.21.1**; includes pinned-source upgrade documentation in
  `UPGRADE_AND_DRIFT_POLICY.md` and `GIT_REMOTE_AND_SYNC_PROTOCOL.md` (see
  `AIAST_CHANGELOG.md`).

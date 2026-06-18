# AIAST Capabilities Sheet

> **GENERATED — do not hand-edit.** Regenerate with `bootstrap/generate-capabilities-sheet.sh --write`; the system verifies it with `--check` (system-doctor + master lane). This is the single comprehensive index of every ability, rule, command, skill, hook, policy, procedure, and contract the AIAST meta-system provides.

Template version: `1.25.0`

## 1. Operator commands (`bootstrap/aiast <verb>`)

The operator front-door dispatcher. Run `bootstrap/aiast help` for the live catalog.

### Agent coordination

| Verb | What it does | Script |
|---|---|---|
| `agents` | Live roster of agents holding locks (who / scope / lease; --json) | `emit-active-agents.sh` |
| `heartbeat` | Emit an agent liveness heartbeat | `agent-heartbeat.sh` |
| `lock` | Acquire an agent work lock | `agent-lock.sh` |
| `orchestration` | Validate agent orchestration / lock posture | `check-agent-orchestration.sh` |
| `unlock` | Release an agent work lock | `agent-unlock.sh` |

### GitHub mirror

| Verb | What it does | Script |
|---|---|---|
| `git` | Git/GitHub helper: status, sync, mirror, checkpoint, release | `gitops.sh` |

### Health & validation

| Verb | What it does | Script |
|---|---|---|
| `audit` | Repo-local health audit + diagnostic report (pass --report --record) | `system-doctor.sh` |
| `doctor` | Structural + integrity + awareness checks (--strict --heal --report --record) | `system-doctor.sh` |
| `env` | Environment + toolchain report (--json) | `check-environment.sh` |
| `status` | Quick posture: template version + meta-sync gate + doctor | `@builtin` |
| `tidy` | Advise (dry-run) on operator-territory hygiene; --apply for the safe subset | `operator-hygiene-advisor.sh` |
| `validate` | Full system validation (--strict --mode auto\|template\|installed) | `validate-system.sh` |

### Host settings

| Verb | What it does | Script |
|---|---|---|
| `host-settings` | Deep-merge the per-host settings baseline (--target --json) | `apply-host-settings.sh` |
| `host-settings-check` | Lint the per-host settings baseline | `check-host-settings-baseline.sh` |

### Lifecycle

| Verb | What it does | Script |
|---|---|---|
| `install` | Install / repair AIAST into a repo (--options) | `install-aiast.sh` |
| `scaffold` | Scaffold the system into a target repo (--app-name --profile) | `scaffold-system.sh` |
| `version` | Print the installed template version | `@builtin` |

### Meta

| Verb | What it does | Script |
|---|---|---|
| `all` | List every bootstrap/*.sh script (raw surface) | `@builtin` |
| `help` | Show this grouped command catalog | `@builtin` |
| `list` | Machine-readable curated command manifest (--json) | `@builtin` |

### Meta-sync

| Verb | What it does | Script |
|---|---|---|
| `meta-sync-gate` | Startup gate: is a meta-sync reconcile pending? (--strict --json) | `check-pending-meta-sync.sh` |
| `reconcile` | Consume PENDING.json, run reconcile pipeline, hand off (--force --json) | `reconcile-meta-sync.sh` |
| `update` | Sync this repo from the template source (--source --profile) | `update-template.sh` |

## 2. Validators & gates (70)

Read-only checks that enforce the system's invariants (run individually, via `system-doctor.sh`, or in the factory master lane).

| Validator | Checks |
|---|---|
| `check-adapter-surface-stamps-protocol.sh` | Asserts that every adapter surface file in the AIAST canonical set |
| `check-agent-instance-isolation.sh` | Validates the per-instance isolation invariants from |
| `check-agent-locks.sh` | Validate agent locks |
| `check-agent-orchestration.sh` | agent-orchestration surface validator. |
| `check-agent-surface-integrity.sh` | agent-surface / placeholder integrity validator. |
| `check-app-definition-gate.sh` | Hard gate: block runtime coding in a downstream |
| `check-app-definition-state.sh` | Identity/onboarding gate for repos scaffolded from this template. |
| `check-app-local-namespace.sh` | Validate app-local namespace artifacts. Behavior depends on _system/.aiast-role.json: |
| `check-bootstrap-permissions.sh` | bootstrap script executable-bit / permission validator. |
| `check-claim-evidence-map.sh` | Flag unsupported success claims in handoff/continuity |
| `check-context-freshness.sh` | Validate context freshness |
| `check-context-isolation.sh` | Context Isolation Validation Script |
| `check-cross-file-integration.sh` | Validate cross file integration |
| `check-delivery-gate-alignment.sh` | Validate that delivery-gate and contract surfaces are present and discoverable |
| `check-environment.sh` | Checks: required CLI tools, port availability, disk space, env vars |
| `check-evidence-quality.sh` | evidence-quality / proof-artifact validator. |
| `check-evidence-retention.sh` | Validate evidence retention |
| `check-fleet-readiness.sh` | Validate fleet readiness |
| `check-git-discipline.sh` | Git Discipline Validation Script |
| `check-global-shim-alignment.sh` | Validate global shim alignment |
| `check-hallucination.sh` | Validate hallucination |
| `check-host-adapter-alignment.sh` | host-adapter alignment validator. |
| `check-host-bundle.sh` | Validate the exported host-bundle contract and the canonical host-bundle emitter |
| `check-host-ingestion.sh` | Validate host ingestion |
| `check-host-settings-baseline.sh` | host-settings baseline linter. |
| `check-install-boundary.sh` | installed-repo boundary / scope validator. |
| `check-installer-first-gate.sh` | Validate installer first gate |
| `check-instruction-domain-alignment.sh` | Validate instruction domain alignment |
| `check-local-self-improvement.sh` | Audits the project-local self-improvement subsystem: shipped structure, |
| `check-master-map-completeness.sh` | Validate master map completeness |
| `check-mcp-bleed.sh` | Detect cross-boundary leakage in MCP configuration (isolation guard). |
| `check-mcp-project-isolation.sh` | Validate mcp project isolation |
| `check-mos-downstream-exclusion.sh` | Validate mos downstream exclusion |
| `check-network-bindings.sh` | Scan source for wildcard network bindings (0.0.0.0, ::) that violate loopback-only policy. |
| `check-packaging-targets.sh` | Validate packaging targets |
| `check-pending-meta-sync.sh` | startup gate. Run as the first step of any agent session in a |
| `check-placeholders.sh` | Validate placeholders |
| `check-project-target-consistency.sh` | Validate project target consistency |
| `check-registry-contract-graph.sh` | Enforce the SYSTEM_REGISTRY.json contract graph. |
| `check-repo-permissions.sh` | repo-permission / write-boundary validator. |
| `check-runtime-foundations.sh` | Validate generated runtime foundations such as packaging manifests, install scaffolds, |
| `check-scaffold-isolation-gate.sh` | Aggregate runner for the scaffold-isolation gates declared in |
| `check-scaffold-required-files.sh` | Validate scaffold required files |
| `check-supply-chain.sh` | Validate supply chain |
| `check-swarm-fleet.sh` | AIAST Swarm Fleet: Health & Integrity Check |
| `check-system-awareness.sh` | registry/path-reference integrity + absolute-path boundary leak scan. |
| `check-template-mos-boundary.sh` | Validate template mos boundary |
| `check-tool-memory-alignment.sh` | Validate tool memory alignment |
| `check-tool-memory-isolation.sh` | Validates _system/tool-memory/*.md against the isolation-stamp contract |
| `check-working-directory-alignment.sh` | Validate working directory alignment |
| `check-working-file-staleness.sh` | Validate working file staleness |
| `check-write-command-lease-coverage.sh` | Regression guard for multi-agent write |
| `detect-drift.sh` | Detect structural, integrity, freshness, and version drift between an installed repo and the master template |
| `detect-instruction-conflicts.sh` | Scan repo instruction surfaces for likely overlap, duplication, and contradiction |
| `score-quality-gates.sh` | Score quality gates |
| `validate-app-context-files.sh` | Validates the app-specific context pack. Role/state-aware: |
| `validate-archetype-packs.sh` | Validate archetype packs |
| `validate-benchmark-report.sh` | Validates a BENCHMARK_MATRIX_*.json payload against the canonical schema. |
| `validate-instruction-layer.sh` | instruction-precedence / host-adapter / prompt-emission surface validation. |
| `validate-mcp-health.sh` | AIAST Swarm Fleet: MCP Health & Re-Auth Validator |
| `validate-plugin.sh` | Validate a plugin directory against the AIAST plugin contract |
| `validate-quality-score-policy.sh` | Validate quality score policy |
| `validate-quality-score-reproducibility.sh` | Validate quality score reproducibility |
| `validate-release-packet.sh` | Validates a release packet payload + its artifact index against canonical |
| `validate-scaffold-output.sh` | Validate scaffold output |
| `validate-scaffold-profile.sh` | Validate scaffold profile |
| `validate-scaffold-profiles.sh` | Validate scaffold profiles |
| `validate-system.sh` | Validate system |
| `verify-integrity.sh` | Generate or verify (and HMAC-sign) the integrity manifest of template-managed files. |
| `verify-mcp-provenance.sh` | Read-only. Compares each registered MCP instance's server_package |

## 3. Generators (13)

Produce the managed/derived surfaces (regenerated on install + update).

| Generator | Produces |
|---|---|
| `generate-app-context-pack.sh` | Materializes the app-context pack for a downstream repo: copies the selected |
| `generate-capabilities-sheet.sh` | generate or verify _system/CAPABILITIES.md. |
| `generate-diagnostic-report.sh` | Run all system-doctor checks, environment checks, drift detection, and plugin status |
| `generate-host-adapters.sh` | Generate host adapters |
| `generate-operating-profile.sh` | Generate operating profile |
| `generate-ops-notes.sh` | Generate ops notes |
| `generate-release-packet.sh` | Generate release packet |
| `generate-runtime-foundations.sh` | Generate project-owned runtime scaffolds such as packaging manifests, install scripts, |
| `generate-super-template-master-map.sh` | Generate super template master map |
| `generate-system-key.sh` | Generate system key |
| `generate-system-nervous-system.sh` | Generate the System Nervous System map. |
| `generate-system-registry.sh` | Generate system registry |
| `generate-systemd-unit.sh` | Generate hardened systemd service units. Timer preset writes both .service and .timer |

## 4. Lifecycle, install & scaffold tooling (13)

| Script | Role |
|---|---|
| `build-aiast-cli.sh` | explicitly (re)build the lean Go validator accelerator. |
| `init-agent-instance.sh` | Initialize agent instance |
| `init-app-namespace.sh` | Refuses if app-local-namespace.json absent |
| `init-project.sh` | Scaffold a fresh AIAST installation into a new app repo (copy, configure, regenerate surfaces). |
| `install-aiast.sh` | Interactive mode (default): prompts for app name and target directory |
| `install-autonomous-guardrails.sh` | Install recurring autonomous guardrail checks for a repo |
| `install-missing-files.sh` | Install missing files |
| `install-root-redirect-shims.sh` | Do not treat this location as policy authority |
| `install-tool-global-redirects.sh` | Use repo-local AIAST authority in the active working repository |
| `render-scaffold-profile.sh` | Default output is one relative path per line |
| `scaffold-system.sh` | Smart AIAST lifecycle entrypoint: |
| `uninstall-system.sh` | Remove the AIAST operating layer while leaving application runtime code intact |
| `update-template.sh` | Apply additive AIAST updates to an installed repo (preserve-first; --refresh-managed / --prune-managed optional). |

## 5. Operations, fleet, sync & agent tooling (44)

| Script | Role |
|---|---|
| `agent-heartbeat.sh` | Refresh an agent's lock lease (heartbeat) so a long task keeps its lock. |
| `agent-isolation.sh` | Isolate temp/cache/state paths per active repo session so many concurrent |
| `agent-lock.sh` | Acquire an atomic per-scope agent lock with a timed lease (race-free guard-dir). |
| `agent-reclaim-lock.sh` | Reclaim a stale/expired agent lock lease so a new holder can acquire it. |
| `agent-unlock.sh` | Release an agent lock — remove the guard dir and lease metadata. |
| `apply-host-settings.sh` | merge meta-managed host-settings (.aiaast.*) into per-app |
| `apply-local-self-improvement.sh` | step 3 (Apply). |
| `apply-starter-blueprint.sh` | Apply starter blueprint |
| `clear-template-sync-notice.sh` | Reset _system/TEMPLATE_SYNC_NOTICE.md to CLEARED after handling a template update. |
| `compact-context.sh` | Compact context |
| `discover-plugins.sh` | Scan _system/plugins/ for installed plugins and report their status |
| `discover-validation-commands.sh` | Discover validation commands |
| `emit-active-agents.sh` | show the live agent lock/lease roster for a repo: which |
| `emit-archetype-pack.sh` | Emit archetype pack |
| `emit-auxiliary-brief.sh` | Emit a markdown auxiliary brief for parallel host CLI / IDE workers. |
| `emit-bleed-event.sh` | Appends one schema-conformant bleed event to |
| `emit-fleet-status.sh` | Emit fleet status |
| `emit-host-bundle.sh` | Emit host bundle |
| `emit-host-prompt.sh` | Emit host prompt |
| `emit-session-environment.sh` | Emit session environment |
| `emit-status-report.sh` | Emit status report |
| `emit-tiered-context.sh` | Emit a context load sequence appropriate for the given tier or model |
| `git-swarm-manager.sh` | Requires zsh; do not invoke as `bash <script>`. Uses zsh-only constructs |
| `migrate-agent-surface-upgrade.sh` | Migrate agent surface upgrade |
| `patch-agent-surface-contracts.sh` | Patch agent surface contracts |
| `propose-local-self-improvement.sh` | step 2 (Propose). |
| `reap-stale-leases.sh` | Sweep _system/agent-state/leases/ for expired leases. A lease is stale when |
| `reconcile-meta-sync.sh` | consume _system/agent-state/meta-sync/PENDING.json, run the |
| `repair-myappz-root-ownership.sh` | Audit or repair root-owned paths inside a MyAppZ workspace |
| `repair-safe-permission-drift.sh` | Repair safe permission drift |
| `repair-swarm-integrity.sh` | Requires zsh; do not invoke as `bash <script>`. Uses zsh-only syntax and |
| `repair-system.sh` | Repair system |
| `resume-from-checkpoint.sh` | By default, reads `_system/checkpoints/LATEST.json` and renders a human |
| `run-app-delivery-autopilot.sh` | Run app delivery autopilot |
| `run-autonomous-guardrails.sh` | Run recurring AIAST guardrail checks and persist timestamped artifacts under: |
| `run-sast.sh` | Run static application security testing (SAST) tools against the target repo |
| `run-test-app-benchmark-matrix.sh` | Run test app benchmark matrix |
| `run-test-app-campaign.sh` | Run test app campaign |
| `run-validation-autopilot.sh` | Run validation autopilot |
| `stamp-tool-memory.sh` | Writer-side helper that prepends (or augments) a tool-memory isolation |
| `sync-agent-adapters.sh` | Requires zsh; do not invoke as `bash <script>`. Uses zsh-only syntax and |
| `sync-metasystem-contracts.sh` | Sync metasystem contracts |
| `track-semantic-changes.sh` | Classify git diff changes as structural, contractual, cosmetic, or behavioral |
| `write-checkpoint.sh` | Agent-neutral resume checkpoint writer. Any agent (Claude, Codex, Cursor, |

## 6. Other bootstrap utilities (42)

| Script | Role |
|---|---|
| `allocate-workspace-service-port.sh` | Allocate workspace service port |
| `append-build-log.sh` | Append build log |
| `append-global-app-report.sh` | Append global app report |
| `audit-bleed-events.sh` | Query and summarize the append-only cross-boundary bleed-event log. |
| `classify-task-fingerprint.sh` | Deterministic task -> read-bundle routing. |
| `compress-context-file.sh` | Opt-in Caveman-style compression for human-edited prose (input token reduction). |
| `configure-project-profile.sh` | Configure project profile |
| `create-test-app-campaign.sh` | Create test app campaign |
| `gitops.sh` | Gitops |
| `harvest-agent-surfaces.sh` | Harvest agent surfaces |
| `heal-system.sh` | Heal system |
| `hybrid-git-sync.sh` | Sync both hybrid repos (`app-runtime` and `app-meta`) under APP_ROOT without |
| `list-improvement-candidates.sh` | List generic improvement candidates a downstream |
| `new-aiast-app.sh` | THE one canonical, safe entrypoint to bootstrap a new |
| `operator-hygiene-advisor.sh` | advisory for the operator-territory git-hygiene state |
| `print-agent-map.sh` | Print agent map |
| `promote-generic-improvement.sh` | Promote a generic downstream candidate into the |
| `quarantine-agent.sh` | Manually quarantine an active agent instance. Snapshots the lease, any |
| `quarantine-mcp-instance.sh` | Operator primitive. Moves an MCP instance record from |
| `recommend-starter-blueprint.sh` | Infer an advisory starter-blueprint recommendation from repo-local product truth and runtime signals |
| `record-agent-event.sh` | Record agent event |
| `register-mcp-instance.sh` | See _system/mcp/MCP_INSTANCE_REGISTRY_PROTOCOL.md for the lifecycle and |
| `release-agent.sh` | Operator primitive. Acceptance F-15 uses this implicitly through reaper + |
| `release-aiast-template.sh` | Treat AIAST like a versioned platform. Run the |
| `release-mcp-instance.sh` | Release mcp instance |
| `report-health-trends.sh` | Read health-history.json and report validation trends |
| `review-improvement-candidate.sh` | Run the promotion gates on a single tagged |
| `scan-container.sh` | Scan container |
| `scan-security.sh` | Run applicable dependency and container scanners and write a machine-readable report |
| `seed-product-brief.sh` | Seed product brief |
| `seed-risk-register.sh` | Seed risk register |
| `seed-test-strategy.sh` | Seed test strategy |
| `seed-working-state.sh` | Seed working state |
| `snapshot-meta-to-orphan-branch.sh` | Default branch: meta-snapshot/<app_slug> (from app-local-namespace.json) |
| `snapshotctl.sh` | Snapshotctl |
| `suggest-project-profile.sh` | Suggest project profile |
| `summarize-benchmark-trend.sh` | Scans retained BENCHMARK_MATRIX_*.json reports under an evidence directory |
| `system-doctor.sh` | Run the full structural / integrity / instruction / awareness / runtime health-check suite (auto / strict / heal). |
| `tag-improvement-candidate.sh` | Tag improvement candidate |
| `upgrade-assistant.sh` | Interactive upgrade assistant for AIAST. Wraps update-template.sh with guidance: |
| `with-agent-lease.sh` | Ergonomic front-end to the lease primitive aiaast_with_lock. |
| `wizard.sh` | Interactive AIAST setup wizard. Guides you through: |

## 7. System rules, policies, procedures & contracts (165)

The governing documents under `_system/` (the rules and procedures that define how the system runs). Grouped by kind; description is each file's title.

### Contracts (14)

| Document | Title / purpose |
|---|---|
| `_system/AGENT_CONTEXT_CONTAINMENT_CONTRACT.md` | Agent Context Containment Contract |
| `_system/APP_BUILDER_SECURITY_AND_AUTO_CORRECTION_CONTRACT.md` | App Builder Security And Auto-Correction Contract |
| `_system/APP_LOCAL_NAMESPACE_CONTRACT.md` | App-Local Namespace Contract |
| `_system/APP_PERSONA_CONTRACT.md` | App-Specific World-Class Persona — Contract |
| `_system/ENVIRONMENT_VALIDATION_CONTRACT.md` | Environment Validation Contract |
| `_system/HOST_BUNDLE_CONTRACT.md` | Host Bundle Contract |
| `_system/HYBRID_APP_REPO_LAYOUT_CONTRACT.md` | Hybrid app repo layout contract |
| `_system/INSTALLER_AND_UPGRADE_CONTRACT.md` | Installer And Upgrade Contract |
| `_system/INSTRUCTION_PRECEDENCE_CONTRACT.md` | Instruction Precedence Contract |
| `_system/PLUGIN_CONTRACT.md` | Plugin Contract |
| `_system/PROJECT_LOCALITY_AND_COPY_FROM_TEMPLATE_CONTRACT.md` | Project Locality And Copy-From-Template Contract |
| `_system/PROMPT_EMISSION_CONTRACT.md` | Prompt Emission Contract |
| `_system/SECURITY_HARDENING_CONTRACT.md` | Security Hardening Contract |
| `_system/SESSION_ENVIRONMENT_REPORT_CONTRACT.md` | Session Environment Report Contract |

### Gates (4)

| Document | Title / purpose |
|---|---|
| `_system/DELIVERY_GATES.md` | Delivery Gates |
| `_system/INSTALLER_FIRST_GATE.md` | Installer-First Gate |
| `_system/SCAFFOLD_ISOLATION_COMPLETION_GATE.md` | Scaffold Isolation Completion Gate |
| `_system/VALIDATION_GATES.md` | Validation Gates |

### Guides (9)

| Document | Title / purpose |
|---|---|
| `_system/AGENT_PERFORMANCE_GUIDE.md` | Agent Performance Guide |
| `_system/CHATBOT_GUIDE.md` | Chatbot Guide |
| `_system/INSTALLATION_GUIDE.md` | Installation Guide |
| `_system/MIGRATION_GUIDE.md` | Migration Guide |
| `_system/MOBILE_GUIDE.md` | Mobile Guide |
| `_system/PACKAGING_GUIDE.md` | Packaging Guide |
| `_system/PROJECT_OWNED_METASYSTEM_GUIDE.md` | Your Project-Owned Meta-System — what you may improve, and how |
| `_system/SYSTEM_ORCHESTRATION_GUIDE.md` | System Orchestration Guide |
| `_system/WORKING_FILES_GUIDE.md` | Working Files Guide |

### Indexes (4)

| Document | Title / purpose |
|---|---|
| `_system/CONTEXT_INDEX.md` | Context Index |
| `_system/HOOK_AND_ORCHESTRATION_INDEX.md` | Hook And Orchestration Index |
| `_system/PROMPTS_INDEX.md` | Prompts Index |
| `_system/SKILLS_INDEX.md` | Skills Index |

### Matrices & catalogs (7)

| Document | Title / purpose |
|---|---|
| `_system/AGENT_DISCOVERY_MATRIX.md` | Agent Discovery Matrix |
| `_system/AGENT_ROLE_CATALOG.md` | Agent Role Catalog |
| `_system/APP_ARCHETYPE_PERSONA_CATALOG.md` | App Archetype Persona Catalog |
| `_system/APP_ARCHETYPE_ROUTING_MATRIX.md` | App Archetype Routing Matrix |
| `_system/APP_CONTEXT_FILE_MATRIX.md` | App Context File Matrix |
| `_system/APP_SURFACE_COMPLETION_MATRIX.md` | App Surface Completion Matrix |
| `_system/SCAFFOLD_PROFILE_MATRIX.md` | Scaffold Profile Matrix |

### Other system docs (50)

| Document | Title / purpose |
|---|---|
| `_system/AGENT_INIT_CONVERGENCE.md` | Agent Init Convergence Contract |
| `_system/AGENT_LOCKING_AND_LEASES.md` | Agent Locking And Leases |
| `_system/AGENT_SURFACE_TAXONOMY.md` | Agent Surface Taxonomy |
| `_system/AIAST_CLI.md` | AIAST Operator CLI (`aiast`) |
| `_system/APP_BUILDER_DOMAIN_ADAPTATION_RAILS.md` | App Builder Domain Adaptation Rails |
| `_system/APP_BUILDER_META_SYSTEM_ORCHESTRATION.md` | App Builder Meta-System Orchestration |
| `_system/APP_REPO_IDENTITY.md` | Repository Identity — read before doing anything |
| `_system/ARCHITECTURE_DIAGRAM.md` | AIAST Architecture Diagrams |
| `_system/AUTHORIZED_SECURITY_RESEARCH_MODE.md` | Authorized Security Research Mode |
| `_system/AUTH_AND_ONBOARDING_PATTERNS.md` | Authentication And Onboarding Patterns |
| `_system/BLEED_EVENT_AND_INCIDENT_RESPONSE.md` | Bleed-Event Protocol and Incident Response |
| `_system/CONTEXT_BUDGET_STRATEGY.md` | Context Budget Strategy |
| `_system/CONTEXT_COMPACTION_AND_REHYDRATION.md` | Context Compaction And Rehydration |
| `_system/CURSOR_AND_MULTI_HOST.md` | Cursor And Multi Host |
| `_system/DEBUG_REPAIR_PLAYBOOK.md` | Debug Repair Playbook |
| `_system/DEPENDENCY_GOVERNANCE.md` | Dependency Governance |
| `_system/DESIGN_EXCELLENCE_FRAMEWORK.md` | Design Excellence Framework |
| `_system/FAILURE_MODES_AND_RECOVERY.md` | Failure Modes And Recovery |
| `_system/HOST_SETTINGS_BASELINE.md` | Host Settings Baseline (HOST_SETTINGS_BASELINE) |
| `_system/INSTRUCTION_CONFLICT_PLAYBOOK.md` | Instruction Conflict Playbook |
| `_system/KEY.md` | System Key |
| `_system/LOAD_ORDER.md` | Load Order |
| `_system/MCP_CONFIG.md` | Model Context Protocol (MCP) Configuration |
| `_system/MODERN_UI_PATTERNS.md` | Modern UI Patterns |
| `_system/MULTI_AGENT_COORDINATION.md` | Multi-Agent Coordination |
| `_system/PERFORMANCE_BUDGET.md` | Performance Budget |
| `_system/PLUGGABLE_EXTENSION_ARCHITECTURE.md` | Pluggable Extension Architecture |
| `_system/PROVENANCE_AND_EVIDENCE.md` | Provenance And Evidence |
| `_system/QUICKSTART.md` | AIAST Quick Start |
| `_system/README.md` | System Directory |
| `_system/READ_BUNDLES.md` | Read Bundles |
| `_system/REPO_BOUNDARY_AND_BACKUP.md` | Repo Boundary And Backup |
| `_system/REPO_CONVENTIONS.md` | Repo Conventions (App-Specific Placeholder) |
| `_system/SCAFFOLD_INCLUDE_EXCLUDE_MANIFEST.md` | Scaffold Include/Exclude Manifest |
| `_system/SCAVENGE_AND_DISCOVERY_AUTHORIZATION.md` | Scavenge And Discovery Authorization |
| `_system/SECURITY_BASELINE.md` | Security Baseline (App-Specific Placeholder) |
| `_system/SECURITY_REDACTION_AND_AUDIT.md` | Security, Redaction, And Audit |
| `_system/SELF_HEALING_BOUNDARY.md` | Self-Healing Boundary |
| `_system/SELF_WRITING_BOUNDARY_AND_ROLLBACK.md` | Self-Writing Boundary and Rollback |
| `_system/SINGLE_FOUNDER_GIT_OPERATING_SYSTEM.md` | Single-founder git operating system |
| `_system/SNAPSHOT_VERSIONING_AND_RETENTION_SPEC.md` | Snapshot versioning and retention spec |
| `_system/SUB_AGENT_HOST_DELEGATION.md` | Sub-Agent And Host CLI Delegation |
| `_system/SUPER_TEMPLATE_MASTER_MAP.md` | AIAST Super Template Master Map |
| `_system/SYSTEM_NERVOUS_SYSTEM.md` | AIAST System Nervous System |
| `_system/TASK_FINGERPRINT_ROUTING.md` | Task Fingerprint Routing |
| `_system/TEMPLATE_MOS_AND_BUILDER_APP_BOUNDARY.md` | Template MOS And Builder App Boundary |
| `_system/TEMPLATE_SYNC_NOTICE.md` | Template operating-layer sync notice |
| `_system/THREAT_MODEL_TEMPLATE.md` | Threat Model Template |
| `_system/TOOL_MEMORY_ISOLATION_STAMP.md` | Tool Memory Isolation Stamp Contract |
| `_system/TROUBLESHOOTING.md` | Troubleshooting |

### Policies (18)

| Document | Title / purpose |
|---|---|
| `_system/AGENT_ELEVATION_AND_AUTH_POLICY.md` | Agent Elevation and Authentication Policy |
| `_system/AGENT_INSTANCE_ISOLATION_POLICY.md` | Agent Instance Isolation Policy |
| `_system/AGENT_UPDATE_MERGE_POLICY.md` | Agent Update Merge Policy |
| `_system/DOWNSTREAM_PRESERVATION_AND_SYNC_NOTICE_POLICY.md` | Downstream preservation and template sync notice policy |
| `_system/EVIDENCE_RETENTION_AND_ROTATION_POLICY.md` | Evidence Retention and Rotation Policy |
| `_system/GIT_SIDE_MIRROR_POLICY.md` | Git-Side Mirror Policy |
| `_system/GLOBAL_APP_REPORT_SINK_POLICY.md` | Global App Report Sink Policy |
| `_system/GLOBAL_REDIRECT_SHIM_POLICY.md` | Global Redirect Shim Policy |
| `_system/GOLDEN_EXAMPLES_POLICY.md` | Golden Examples Policy |
| `_system/HOST_ADAPTER_POLICY.md` | Host Adapter Policy |
| `_system/MOS_DOWNSTREAM_EXCLUSION_POLICY.md` | MOS Downstream Exclusion Policy |
| `_system/ORPHAN_META_SNAPSHOT_POLICY.md` | Orphan Meta Snapshot Policy |
| `_system/PROMPT_BACKEND_POLICY.md` | Backend Policy Prompt Rules |
| `_system/PROMPT_DOCKER_NETWORK_POLICY.md` | Docker Network Policy Prompt Rules |
| `_system/SYSTEM_EVOLUTION_POLICY.md` | System Evolution Policy |
| `_system/TEMPLATE_CHANGE_IMPACT_POLICY.md` | Template Change Impact Policy |
| `_system/TEMPLATE_NEUTRALITY_POLICY.md` | Template Neutrality Policy |
| `_system/UPGRADE_AND_DRIFT_POLICY.md` | Upgrade and Drift Policy |

### Profiles (2)

| Document | Title / purpose |
|---|---|
| `_system/PROJECT_PROFILE.md` | Project Profile |
| `_system/REPO_OPERATING_PROFILE.md` | Repo Operating Profile |

### Prompts (4)

| Document | Title / purpose |
|---|---|
| `_system/MASTER_SYSTEM_PROMPT.md` | Master System Prompt |
| `_system/OPERATOR_PROMPTING_PLAYBOOK.md` | Operator Prompting Playbook |
| `_system/PROMPT_EFFECTIVENESS_TRACKING.md` | Prompt Effectiveness Tracking |
| `_system/PROMPT_SECURITY_BASELINE.md` | Security Baseline Prompt Rules |

### Protocols (37)

| Document | Title / purpose |
|---|---|
| `_system/AGENT_INSTALLER_AND_HOST_VALIDATION_PROTOCOL.md` | Agent Installer And Host Validation Protocol |
| `_system/APP_BUILDER_REGRESSION_AND_BENCHMARK_PROTOCOL.md` | App Builder Regression And Benchmark Protocol |
| `_system/APP_DELIVERY_AUTOPILOT_PROTOCOL.md` | App Delivery Autopilot Protocol |
| `_system/AUTH_RECOVERY_PROTOCOL.md` | Authentication Recovery Protocol |
| `_system/AUTONOMOUS_GUARDRAILS_PROTOCOL.md` | Autonomous Guardrails Protocol |
| `_system/CHECKPOINT_PROTOCOL.md` | Checkpoint Protocol |
| `_system/CLAIM_EVIDENCE_MAP_PROTOCOL.md` | Claim / Evidence Map Protocol |
| `_system/CONCURRENT_AGENT_FLEET_PROTOCOL.md` | Concurrent Agent Fleet Protocol |
| `_system/CONTINUOUS_CONTEXT_RECORDING_PROTOCOL.md` | Continuous Context Recording Protocol |
| `_system/DEPLOYMENT_BOUNDARY_PROTOCOL.md` | Deployment Boundary Protocol |
| `_system/DOWNSTREAM_APPLY_ROLLBACK_DRILL_PROTOCOL.md` | Downstream Apply/Rollback Drill Protocol |
| `_system/EXECUTION_PROTOCOL.md` | Execution Protocol |
| `_system/EXTERNAL_AGENT_SURFACE_HARVEST_PROTOCOL.md` | External Agent Surface Harvest Protocol |
| `_system/FLEET_CONTROL_TOWER_PROTOCOL.md` | Fleet Control Tower Protocol |
| `_system/GIT_REMOTE_AND_SYNC_PROTOCOL.md` | Git remote and sync protocol (AIAST) |
| `_system/HALLUCINATION_DEFENSE_PROTOCOL.md` | Hallucination Defense Protocol |
| `_system/HANDOFF_PROTOCOL.md` | Handoff Protocol |
| `_system/HERETIC_ABLITERATION_PROTOCOL.md` | HERETIC ABLITERATION PROTOCOL |
| `_system/INSTRUCTION_DOMAIN_ALIGNMENT_PROTOCOL.md` | Instruction And Domain Alignment Protocol |
| `_system/META_SYNC_RECONCILE_PROTOCOL.md` | Meta-Sync Reconcile Protocol |
| `_system/NEW_PROJECT_BOOTSTRAP_PROTOCOL.md` | New-Project Bootstrap Protocol |
| `_system/OBSERVABILITY_AND_RECOVERY_LEDGER_PROTOCOL.md` | Observability and recovery ledger protocol |
| `_system/PROJECT_IDENTITY_AND_SCOPE_PROTOCOL.md` | Project Identity And Scope Protocol |
| `_system/PROJECT_LOCAL_SELF_IMPROVEMENT_PROTOCOL.md` | Project-Local Self-Improvement Protocol |
| `_system/QUALITY_SCORE_AND_STATUS_REPORT_PROTOCOL.md` | Quality Score and Status Report Protocol |
| `_system/RELEASE_READINESS_PROTOCOL.md` | Release Readiness Protocol |
| `_system/REQUEST_ALIGNMENT_PROTOCOL.md` | Request Alignment Protocol |
| `_system/SAFE_PERMISSION_AND_SETUP_REPAIR_PROTOCOL.md` | Safe Permission and Setup Repair Protocol |
| `_system/SELF_IMPROVEMENT_PROMOTION_REVIEW_PROTOCOL.md` | Self-Improvement Promotion Review Protocol |
| `_system/SELF_IMPROVEMENT_PROTOCOL.md` | Self-Improvement Protocol |
| `_system/SYSTEM_AWARENESS_PROTOCOL.md` | System Awareness Protocol |
| `_system/TEST_APP_BENCHMARK_CAMPAIGN_PROTOCOL.md` | Test App Benchmark Campaign Protocol |
| `_system/TOOL_MEMORY_REDIRECTION_PROTOCOL.md` | Tool Memory Redirection Protocol |
| `_system/VALIDATION_COMMAND_DISCOVERY_PROTOCOL.md` | Validation Command Discovery Protocol |
| `_system/VERSION_SENSITIVE_RESEARCH_PROTOCOL.md` | Version-Sensitive Research Protocol |
| `_system/WORKSPACE_AUTHORITY_AND_CONTAINMENT_PROTOCOL.md` | Workspace Authority And Containment Protocol |
| `_system/WORKSPACE_SERVICE_REGISTRY_PROTOCOL.md` | Workspace Service Registry Protocol |

### Rules (3)

| Document | Title / purpose |
|---|---|
| `_system/AI_RULES.md` | AI Rules (App-Specific Placeholder) |
| `_system/MEMORY_RULES.md` | Memory Rules |
| `_system/PROJECT_RULES.md` | Project Rules |

### Standards (13)

| Document | Title / purpose |
|---|---|
| `_system/ACCESSIBILITY_STANDARDS.md` | Accessibility Standards |
| `_system/API_DESIGN_STANDARDS.md` | API Design Standards |
| `_system/APP_ARCHETYPE_PACK_AUTHORING_STANDARD.md` | App Archetype Pack Authoring Standard |
| `_system/APP_BUILDER_RELEASE_READINESS_STANDARD.md` | App Builder Release Readiness Standard |
| `_system/APP_SPECIFIC_CONTEXT_AUTHORING_STANDARD.md` | App-Specific Context Authoring Standard |
| `_system/BEAUTIFUL_APP_QUALITY_STANDARD.md` | Beautiful App Quality Standard |
| `_system/CODING_STANDARDS.md` | Coding Standards |
| `_system/CROSS_PLATFORM_DISTRIBUTION_AND_INSTALLER_STANDARD.md` | Cross-Platform Distribution And Installer Standard |
| `_system/OBSERVABILITY_STANDARDS.md` | Observability Standards |
| `_system/PROJECT_SPECIFIC_PLACEHOLDER_FILE_STANDARD.md` | Project-Specific Placeholder File Standard |
| `_system/PROMPT_SYSTEM_BUILD_STANDARD.md` | System Build Standard |
| `_system/SCAFFOLD_PROFILE_AUTHORING_STANDARD.md` | Scaffold Profile Authoring Standard |
| `_system/STANDARDS_CONFLICT_RESOLUTION.md` | Standards Conflict Resolution |

## 8. Machine-enforced policy-contracts (4)

JSON contracts asserted by `check-policy-contracts.sh` — invariants the system actively refuses to violate.

| Contract | Asserts |
|---|---|
| `host-launch.json` | S21→S22c: launch-governing safety policy each host's meta-managed (.aiaast.*) file MUST carry. Migrated into the generic policy-contract su… |
| `instruction-precedence.json` | The canonical instruction-precedence order is the backbone of agent determinism. Drift (AGENTS.md no longer #1, or the precedence contract … |
| `mcp-isolation.json` | Closes the S16 fleet-outage class: absolute-path placeholders (e.g. /ABSOLUTE/PATH/TO/PROJECT) leaking into MCP example/config surfaces sil… |
| `self-writing-boundary.json` | Closes the downstream self-improvement boundary-erosion class: an agent or a careless edit weakening the project-local self-writing boundar… |

## 9. Host / tool adapters (12)

Per-agent entry-point files (generated from the host-adapter manifest) that load the same canonical repo contract into each coding agent.

| Adapter file | Agent / tool |
|---|---|
| `CLAUDE.md` | Claude Code |
| `CODEX.md` | OpenAI Codex |
| `GEMINI.md` | Gemini CLI |
| `COPILOT.md` | GitHub Copilot |
| `CURSOR.md` | Cursor |
| `WINDSURF.md` | Windsurf |
| `AIDER.md` | Aider |
| `ANTIGRAVITY.md` | Antigravity |
| `GROK.md` | Grok |
| `DEEPSEEK.md` | DeepSeek |
| `PEARAI.md` | PearAI |
| `LOCAL_MODELS.md` | Local models |

## 10. Slash commands (20)

| Command | Purpose |
|---|---|
| `/accessibility-review` | Accessibility Review |
| `/architecture-review` | Architecture-Review |
| `/checkpoint` | Checkpoint |
| `/code-quality-review` | Code Quality Review |
| `/code-review` | Code-Review |
| `/composer-session` | Composer session bootstrap |
| `/compress-context` | Compress context (opt-in input file compression) |
| `/concise-session` | Concise session (token-efficient output) |
| `/debug` | Debug |
| `/dependency-review` | Dependency Review |
| `/design-review` | Design-Review |
| `/environment` | Environment |
| `/fill-app-context` | fill-app-context |
| `/forge-app-persona` | forge-app-persona |
| `/github-session` | GitHub Session |
| `/load-context` | Load-Context |
| `/performance-review` | Performance Review |
| `/release-readiness` | Release-Readiness |
| `/session-start` | Session-Start |
| `/verify` | Verify |

## 11. Skills (17)

| Skill | Description |
|---|---|
| `accessibility-review` | Audit UI changes for accessibility compliance against WCAG 2.2 AA standards |
| `architecture-review` | Review structure, boundaries, and migration risk before or after major changes. |
| `checkpoint-handoff` | Prepare a clean repo handoff for the next agent or human. |
| `code-quality-review` | Review code changes for adherence to coding standards, clean code principles, and anti-pattern avoidance |
| `code-review` | Review changes against the repo contract, runtime boundaries, validation gates, and multi-agent rules. |
| `compress-context-input` | Opt-in checklist for Caveman-style input compression of human prose under docs/ or notes/ via bootstrap/compress-context-file.sh. Use when … |
| `concise-communication` | Opt-in ultra-concise assistant replies to reduce OUTPUT tokens (Caveman-style). Use when the user asks for caveman, token-efficient, terse,… |
| `debug-playbook` | Use when a build, test, runtime, packaging, or install flow fails. |
| `dependency-review` | Review dependency changes for security, license compliance, size impact, and necessity |
| `design-review` | Review touched UI or product surfaces for hierarchy, coherence, polish, and quality. |
| `environment-report` | Emit an environment and authority report before write-heavy work or cross-repo tasks. |
| `load-context` | Load the canonical repo context in the required order. Use at session start, after context resets, or when the user asks to reload project … |
| `mcp-config` | Generate or review least-privilege MCP configs for this project. |
| `performance-review` | Audit changes for performance budget compliance and optimization opportunities |
| `prompt-pack-generator` | Generate milestone prompt packs grounded in the repo's canonical docs. |
| `release-readiness` | Evaluate whether work is truly ready for checkpoint, milestone completion, or release claims. |
| `verify-gate` | Run verification before push, checkpoint, or claiming completion. |

## 12. Prompt-packs (19)

| Prompt-pack | Focus |
|---|---|
| `M0_FOUNDATION.md` | M0 Foundation Prompt Pack |
| `M10_GREENFIELD_BOOTSTRAP.md` | M10 Greenfield Bootstrap Prompt Pack |
| `M11_MATURE_REPO_RETROFIT.md` | M11 Mature Repo Retrofit Prompt Pack |
| `M12_PERFORMANCE_OPTIMIZATION.md` | M12: Performance Optimization |
| `M13_ACCESSIBILITY_AND_INCLUSION.md` | M13: Accessibility and Inclusion |
| `M14_SECURITY_HARDENING.md` | M14 Security Hardening Pack |
| `M15_WHOLE_REPO_ANALYSIS.md` | M15 Whole-Repo Analysis Prompt Pack (Tier S) |
| `M16_PLATFORM_PRODUCT_EXPANSION.md` | M16 Platform Product Expansion |
| `M17_APP_BUILDER_META_SYSTEM_EXECUTION.md` | M17 App Builder Meta-System Execution |
| `M1_FEATURE_DELIVERY.md` | M1 Feature Delivery Prompt Pack |
| `M2_DEBUG_AND_STABILIZE.md` | M2 Debug And Stabilize Prompt Pack |
| `M3_REVIEW_AND_RELEASE.md` | M3 Review And Release Prompt Pack |
| `M4_ARCHITECTURE_EXPANSION.md` | M4 Architecture Expansion Prompt Pack |
| `M5_MIGRATION_AND_REFACTOR.md` | M5 Migration And Refactor Prompt Pack |
| `M6_INSTALL_AND_DISTRIBUTION.md` | M6 Install And Distribution Prompt Pack |
| `M7_DESIGN_EXCELLENCE.md` | M7 Design Excellence Prompt Pack |
| `M8_SECURITY_AND_COMPLIANCE.md` | M8 Security And Compliance Prompt Pack |
| `M9_MULTI_AGENT_CONTINUITY.md` | M9 Multi-Agent Continuity Prompt Pack |
| `WROUGHTWORKS_PROMPT_PACK.md` | Wrought Works Prompt Pack |

## 13. App archetypes (27)

| Archetype | Title |
|---|---|
| `README` | Archetypes |
| `agent-system-app` | Agent System App Archetype |
| `ai-agent-app` | Archetype Pack: ai-agent-app |
| `ai-app` | AI App Archetype |
| `android-apk` | Android APK Archetype |
| `background-check-intel-app` | Background Check Intel App Archetype |
| `background-check-or-osint-app` | Archetype Pack: background-check-or-osint-app |
| `cli-tool` | CLI Tool Archetype |
| `cybersecurity-lab-app` | Cybersecurity Lab App Archetype |
| `cybersecurity-tool` | Archetype Pack: cybersecurity-tool |
| `data-dashboard` | Archetype Pack: data-dashboard |
| `data-platform` | Data Platform Archetype |
| `desktop-app` | Desktop App Archetype |
| `evidence-reporting-app` | Archetype Pack: evidence-reporting-app |
| `finance-budgeting-app` | Archetype Pack: finance-budgeting-app |
| `financial-app` | Financial App Archetype |
| `fullstack-marketplace` | Archetype Pack: fullstack-marketplace |
| `health-tracker` | Health Tracker Archetype |
| `home-property-management-app` | Archetype Pack: home-property-management-app |
| `homelab-tool` | Homelab Tool Archetype |
| `local-first-desktop` | Archetype Pack: local-first-desktop |
| `marketplace` | Marketplace Archetype |
| `metasystem-reviewer-app` | Archetype Pack: metasystem-reviewer-app |
| `mobile-apk` | Archetype Pack: mobile-apk |
| `universal-app-platform` | Universal App Platform Archetype |
| `web-app` | Web App Archetype |
| `web-saas` | Archetype Pack: web-saas |

## 14. Agent roles (8)

| Role | Purpose |
|---|---|
| **Orchestrator / Planner** | choose the next slice, assign roles, define ownership, and keep the execution picture coherent |
| **MetaCommander (Swarm Orchestrator) — DEFERRED, NOT ACTIVE** | DEFERRED — not active in the lean-hybrid configuration |
| **Implementation Worker** | make the planned runtime or system change inside an assigned write scope |
| **Validator** | prove behavior, catch regressions, and verify claims against the repo |
| **Context Curator** | preserve continuity, update working files, and make resume state truthful |
| **Abliteration Specialist** | manage authorized host-local model refusal/alignment behavior work using the Heretic protocol |
| **Specialist Reviewers** | provide bounded expert review without taking over broad implementation |
| **GitHub / CI steward** | keep **GitHub**, **Actions**, and **merge readiness** coherent without |

## 15. Scaffold profiles (12)

Install footprints (default: `standard`).

| Profile | Kind | Notes |
|---|---|---|
| `minimal` | installable | Smallest supported app-agent operating layer. Current implementation keeps the full installable AIAST contract until a narrowed minimal pro… |
| `standard` | installable | Default downstream app profile. Includes the full installable AIAST product and excludes parent-template, MOS, factory, secret, and transie… |
| `advanced` | installable | Standard profile plus extended governance and diagnostics. |
| `super` | installable | Maximum normal downstream profile without parent-template source layers. |
| `security-heavy` | installable | Security-first downstream profile with explicit containment and audit gates. |
| `ai-heavy` | installable | AI-oriented app profile with prompt and provider-safety surfaces. |
| `mobile-apk` | installable | Android/APK-ready profile with mobile runtime and package guidance. |
| `desktop` | installable | Desktop-first profile with launcher and installer expectations. |
| `web-saas` | installable | Web/API/SaaS profile with auth, API, and network governance. |
| `fullstack` | installable | Fullstack app profile with web, API, data, install, and migration safety. |
| `homelab` | installable | Self-hosted/homelab profile with local service and operations surfaces. |
| `meta-system-development` | maintainer-only | AIAST/MOS maintainer profile. It still does not copy parent source-repo layers through app scaffold; use MOS_TEMPLATE bootstrap for MOS ins… |

## 16. Hooks & orchestration

Automation hooks and orchestration surfaces are catalogued in `_system/HOOK_AND_ORCHESTRATION_INDEX.md`. Section headings:

- Principles
- 1. Session and IDE workflow hooks (Cursor-class)
- 2. Tool-specific adapter files (multi-host)
- 3. Plugin hooks (AIAST extensions)
- 4. Validation and doctor hooks
- 5. Git and GitHub automation hooks
- 6. MCP as integration hooks
- 7. Meta-system (MOS / master repo) note
- Anti-patterns

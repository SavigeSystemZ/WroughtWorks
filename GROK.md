# GROK.md

Use `AGENTS.md` as the repo contract. This adapter applies to the xAI Grok CLI (launched with the `grok` command; repo-local config and state live under `.grok/`).

## Canonical startup
1. `AGENTS.md`
2. `_system/INSTRUCTION_PRECEDENCE_CONTRACT.md`
3. `_system/REPO_OPERATING_PROFILE.md`
4. `_system/PROJECT_PROFILE.md`
5. `_system/CONTEXT_INDEX.md`
6. `_system/LOAD_ORDER.md`
7. `_system/WORKING_FILES_GUIDE.md`
8. `_system/TEMPLATE_NEUTRALITY_POLICY.md`
9. `_system/MASTER_SYSTEM_PROMPT.md`
10. `_system/PROJECT_RULES.md`
11. `_system/EXECUTION_PROTOCOL.md`
12. `_system/MULTI_AGENT_COORDINATION.md`
13. `_system/AGENT_ROLE_CATALOG.md`
14. `_system/AGENT_DISCOVERY_MATRIX.md`
15. `_system/VALIDATION_GATES.md`
16. `_system/SYSTEM_AWARENESS_PROTOCOL.md`
17. `_system/HALLUCINATION_DEFENSE_PROTOCOL.md`
18. `WHERE_LEFT_OFF.md`
19. `TODO.md`
20. `FIXME.md`
21. `PLAN.md`
22. `PRODUCT_BRIEF.md`

## Load More When Needed
Load these when the task touches their domain:
- `ROADMAP.md`
- `DESIGN_NOTES.md`
- `ARCHITECTURE_NOTES.md`
- `RESEARCH_NOTES.md`
- `TEST_STRATEGY.md`
- `RISK_REGISTER.md`
- `RELEASE_NOTES.md`
- `CHANGELOG.md`
- `_system/prompt-packs/M15_WHOLE_REPO_ANALYSIS.md`
- `_system/ports/PORT_POLICY.md`
- `_system/design-system/THEME_GOVERNANCE.md`

For system-evolution, prompt-authoring, adapter work, or working-file drafting, also load:
- `_system/GOLDEN_EXAMPLES_POLICY.md`
- `_system/golden-examples/PATTERN_INDEX.md`
- `_system/HOST_ADAPTER_POLICY.md`
- `_system/PROMPT_EMISSION_CONTRACT.md`

## Grok operating notes
- Operate ONLY the meta-system in the repository you were launched from; never read policy from, or write context/state to, a meta-system in another directory (see the disclosure at the top of `AGENTS.md`).
- Keep runtime code independent from `_system/`.
- Treat host-level orchestration as context, not repo-local truth; the repo-local files named in `AGENTS.md` and `_system/INSTRUCTION_PRECEDENCE_CONTRACT.md` remain authoritative.
- Leverage Grok's large context window for whole-repo and cross-cutting analysis, and use deep reasoning to plan against the canonical docs before implementation.
- Produce focused, minimal, reversible diffs with explicit validation evidence.
- Multiple Grok instances may run concurrently — respect the single active writer lease per scope (`_system/agent-instance-policy.json`, `_system/AGENT_LOCKING_AND_LEASES.md`, `_system/CONCURRENT_AGENT_FLEET_PROTOCOL.md`); name instances `grok-NN`.
- Leave a high-signal handoff packet in repo files.
- Be aware that other primary adapter files exist for the other supported agents; see `_system/AGENT_DISCOVERY_MATRIX.md` for the current roster.
- If context appears contradictory, run `bootstrap/system-doctor.sh`.
- Before appending non-trivial content to `_system/tool-memory/grok-memory.md`, invoke `bootstrap/stamp-tool-memory.sh --adapter grok --file _system/tool-memory/grok-memory.md --agent-id <agent-id>` per `_system/TOOL_MEMORY_ISOLATION_STAMP.md`.

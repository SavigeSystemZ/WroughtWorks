# Self-Improvement Promotion Review Protocol

Downstream repos improve themselves locally and **tag generic candidates** with
`bootstrap/tag-improvement-candidate.sh` (into `_system/improvement-candidates.jsonl`).
This protocol is the **parent-template maintainer's** safe path to review those
candidates and promote the genuinely generic ones into AIAST — without dragging
app-specific facts, secrets, or host paths into the template.

Pairs with `PROJECT_LOCAL_SELF_IMPROVEMENT_PROTOCOL.md` (the local loop) and
`SELF_WRITING_BOUNDARY_AND_ROLLBACK.md` (containment).

## Commands (run from the parent template)

```bash
bootstrap/list-improvement-candidates.sh <downstream-repo> [--json]
bootstrap/review-improvement-candidate.sh <downstream-repo> <index> [--json]
bootstrap/promote-generic-improvement.sh <downstream-repo> <index> --dry-run
bootstrap/promote-generic-improvement.sh <downstream-repo> <index> --apply
```

## Promotion gates (ALL must pass; enforced by `review`)

A candidate is **NOT promotable** if its file content contains any of:

1. **App-specific identity** — the source repo's `app_id`, `app_slug`,
   `app_name`, or `repo_root` (from `_system/app-local-namespace.json`).
2. **Secrets** — API keys, tokens, private keys, `password=`, `api_key=`.
3. **Host/user paths** — absolute `/home/<user>/…` or a specific `~/.MyAppZ/<App>` path.
4. **Network specifics** — non-localhost URLs or hard-coded ports.
5. **Stack lock-in** — the file is only meaningful for one app's runtime stack.

A promotable candidate must also be **self-contained** (a file under `bootstrap/`
or `_system/`) so the template stays neutral.

## After `--apply`

`promote-generic-improvement.sh --apply` copies the file into the parent and
prints the **required follow-up** (it does not commit):

1. Add/confirm a **validator** for the new surface (a `check-*`/`validate-*` or a
   generator `--check`) — `check-registry-contract-graph.sh` requires every
   `drift_severity=fail` file to name one.
2. Regenerate surfaces (`generate-system-registry.sh --write`, capabilities,
   nervous-system) and **re-sign integrity** (`verify-integrity.sh --generate`).
3. Write a **rollback + downstream migration note** in `AIAST_CHANGELOG.md`.
4. Run the master lane before committing.

If the gates fail, `promote` refuses and nothing is copied.

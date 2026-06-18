# FIXME

Use this file for unresolved problems that materially affect delivery confidence, correctness, reliability, security, or maintainability.

## Entry format

- Severity:
- Area:
- Problem:
- Impact:
- Temporary mitigation:
- Permanent fix:
- Validation gap:
- Owner or next step:

## Known Bugs

- None recorded in the master template snapshot (2026-05-23). Replace this line in downstream repos when real bugs exist.
- **Resolved 2026-05-23:** `bootstrap/discover-plugins.sh` previously embedded `Path("/dev/null").stat().st_mtime` as `generated_at` in `_system/CAPABILITY_MATRIX.json`. The value was never consumed by any reader but drifted any time `/dev/null` mtime updated (typically across reboots), which corrupted the integrity manifest's hash for that file. Field removed; the matrix is now fully deterministic. Found while running the Phase 6 verification of the downstream self-improvement program.

## Known Risks

- None recorded yet.

## Technical Debt

- None recorded yet.

## Deferred Improvements

- None recorded yet.

## Blockers

- None recorded yet.

## Usage rules

- This file is for unresolved problems, not wish-list ideas.
- If a risk changes delivery confidence, cross-link it from `WHERE_LEFT_OFF.md` and `RISK_REGISTER.md`.

---

*Template baseline reviewed: 2026-06-18.*

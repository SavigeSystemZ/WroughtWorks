# Claim / Evidence Map Protocol

## Purpose

Attack **hallucinated completion**: an agent writing "tests pass", "build works",
"security reviewed", "scaffold complete", "pushed to GitHub", or "validation
complete" into a handoff or continuity surface without anything to back it up.

A claim is only trustworthy next to **evidence** — a command that was run, a
result token (`*_ok`, `12/12`, `kill_rate`), an artifact path, or a commit SHA.
This protocol makes that machine-checkable.

## How it works

- `_system/claim-evidence-map.json` defines claim patterns and the evidence
  patterns that must appear within `window` lines of a matching claim.
- `bootstrap/check-claim-evidence-map.sh <repo> [--strict] [--json] [FILE ...]`
  scans the `default_targets` (or explicit files) and flags every claim line
  with no supporting evidence in its window.

## Exit contract

| Exit | Meaning | Who uses it |
|---|---|---|
| `0` | No unsupported claims | doctor (clean) |
| `2` | Unsupported claims found (advisory) | `system-doctor` warn-tier surfaces them |
| `1` | Unsupported claims found, `--strict` | the release-readiness gate blocks on them |

## Default scanned surfaces

`WHERE_LEFT_OFF.md`, `CHANGELOG.md`, `RELEASE_NOTES.md`,
`_system/context/CURRENT_STATUS.md`, `_system/self-improvement/ledger.jsonl`.

## Authoring guidance for agents

When you state a result, put the evidence on or near the same line:

- ✅ `Tests pass: bash run.sh -> suite_ok 12/12`
- ✅ `Pushed: local=950e27c4 origin=950e27c4`
- ❌ `Everything works and is validated.` (no command, token, path, or SHA)

This is intentionally conservative — it targets explicit success claims, not
ordinary prose. See also `PROVENANCE_AND_EVIDENCE.md` and the evidence-quality
check (`bootstrap/check-evidence-quality.sh`).

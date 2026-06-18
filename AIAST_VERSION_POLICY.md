# AIAST Version Policy

AIAST is a versioned platform. The template version lives in
`_system/.template-version` and is mirrored in `AIAST_VERSION.md`.

## Semantic versioning

- **MAJOR** — a breaking change to managed-surface structure, the instruction
  layer, or the scaffold contract that requires a downstream migration step.
- **MINOR** — new validators, generators, bundles, archetypes, or capabilities
  that are additive and downstream-compatible.
- **PATCH** — bug fixes and hardening with no surface/contract change.

## Release stages

`dev-local` → `validated-local` → `scaffold-test` → `release-candidate` →
`released` → `mirrored-to-github`.

The **local environment is the authoritative gate** (`GIT_SIDE_MIRROR_POLICY.md`).
A version is `validated-local` only when `bootstrap/release-aiast-template.sh
--check` reports `release_ready` and the master lane is green. It becomes
`released` when the operator tags it locally; `mirrored-to-github` when `main`
and the tag are pushed.

## Rules

1. Every release bumps `_system/.template-version` + `AIAST_VERSION.md` together,
   adds an `AIAST_CHANGELOG.md` entry, and (for MAJOR) a migration note.
2. Tags are annotated (`vMAJOR.MINOR.PATCH`) and are milestones, not work streams.
3. Generated surfaces are regenerated and the integrity manifest re-signed before
   a release is sealed.
4. The fleet is migrated only after a release is tagged (preserve-first additive
   then `--refresh-managed --prune-managed`), operator-gated.

See `AIAST_RELEASE_CHECKLIST.md` and `bootstrap/release-aiast-template.sh`.

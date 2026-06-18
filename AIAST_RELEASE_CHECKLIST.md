# AIAST Release Checklist

Run `bootstrap/release-aiast-template.sh --check` — it executes the gate sequence
below and reports `release_ready` or `release_blocked`. Use `--seal` to also
generate a sealed release packet once green.

## Automated gates (release-aiast-template.sh)

- [ ] `validate-instruction-layer` — instruction precedence intact
- [ ] `check-system-awareness` — system awareness intact
- [ ] `system-doctor --strict` — structural + integrity + awareness (binary required, `AIAST_REQUIRE_CLI=1`)
- [ ] `validate-system --strict` — strict system validation
- [ ] `check-registry-contract-graph` — registry topology + no drift
- [ ] `verify-integrity --check` — signed manifest valid
- [ ] `check-claim-evidence-map --strict` — no unsupported claims in handoff surfaces
- [ ] `check-write-command-lease-coverage` — no unlocked shared-state writers
- [ ] `new-aiast-app --dry-run` — scaffold-test (parent untouched)

## Operator steps (local-authoritative; not automated)

1. [ ] Run `_TEMPLATE_FACTORY/validate-master-template.sh` — full lane green.
2. [ ] Confirm `meta-self-audit` world-class index (note any fleet_posture
       deductions are real fleet state, not template regressions).
3. [ ] Bump `_system/.template-version` + `AIAST_VERSION.md`; add an
       `AIAST_CHANGELOG.md` entry (+ migration note for MAJOR).
4. [ ] Regenerate surfaces + re-sign integrity.
5. [ ] `release-aiast-template.sh --seal` to seal the release packet.
6. [ ] `git tag -a vX.Y.Z` and push `main` + tag per `GIT_SIDE_MIRROR_POLICY.md`.
7. [ ] Migrate the fleet (preserve-first additive → `--refresh-managed
       --prune-managed`), operator-gated.

See `AIAST_VERSION_POLICY.md`.

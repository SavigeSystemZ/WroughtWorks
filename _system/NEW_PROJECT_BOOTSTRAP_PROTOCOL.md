# New-Project Bootstrap Protocol

## The one canonical path

To create a new AIAST-backed app, run **from inside the parent template**:

```bash
bootstrap/new-aiast-app.sh --name "<AppName>" [--target DIR] [--dry-run]
```

Default target is `$HOME/.MyAppZ/<AppName>`. This is the **only recommended**
way to start a new project. Do not hand-copy the template or edit the parent
template as if it were an app.

## What it guarantees

`new-aiast-app.sh` is a thin, safe orchestrator over the existing scaffold
(`scaffold-system.sh` → `init-project.sh`). It:

1. **Refuses to run unless this repo is the `parent-template`** (override only
   with `AIAST_ALLOW_NONPARENT=1`). You cannot accidentally "new-app" from
   inside a downstream repo.
2. **Refuses to scaffold into a non-empty target** unless `--force`.
3. Scaffolds into the target, where `init-project.sh` sets
   `role=downstream-app` and the app-local namespace.
4. **Proves the parent template was not modified** (git porcelain snapshot
   before/after — reported as `Parent template touched: no`).
5. Runs the **scaffold isolation gate** + `validate-system` on the new repo.
6. Reports the **app-definition gate** verdict and emits the next-step prompt:
   *define `PRODUCT_BRIEF.md` before writing any runtime code.*

## Output contract

- `new_aiast_app_ok name=… target=…` — created, validated, parent untouched.
- `new_aiast_app_dry_run_ok …` — `--dry-run` preview, nothing written.
- `new_aiast_app_warn …` — created but validation or parent-untouched check
  needs review (exit 2).
- `new_aiast_app_failed: …` — refused (wrong role, unsafe overwrite, or scaffold
  error); nothing partially created on a refusal.

## After bootstrap

`cd` into the new repo and follow `_system/APP_REPO_IDENTITY.md`: the app is
`blank_app_undefined` until you define it. `bootstrap/check-app-definition-gate.sh`
returns `APP_UNDEFINED_BLOCK` until `PRODUCT_BRIEF.md`, `PROJECT_PROFILE.md`,
`PROJECT_DOMAIN_MANIFEST.json`, app-context, and an app persona exist. Build the
app into `app/` via the `_system/` meta-system; keep app code independent of
`_system/` and `bootstrap/`.

See also: `APP_REPO_IDENTITY.md`, `scaffold-profiles.json`,
`SCAFFOLD_INCLUDE_EXCLUDE_MANIFEST.md`, `GIT_SIDE_MIRROR_POLICY.md`.

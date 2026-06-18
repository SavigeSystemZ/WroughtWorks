# Git-Side Mirror Policy

**Standard for every repo scaffolded from this template.**

## Principle

The **local environment is the authoritative validation gate.** For the
default single-developer AIAST workflow, the GitHub remote is a **simple,
full mirror** of the local repo: same tracked files, same main history, same
repo name as the local project folder. GitHub is a backup and distribution
surface, not the source of truth and not a separate planning or branching
system.

A change is "done" when it is validated locally (the local automation lanes
pass) and pushed so `origin/main` mirrors the local `main`. Remote CI is a
convenience reflection, never a blocker.

## Rules

1. **Local lanes are the gate.** Authoritative validation is the local
   master + MOS automation lanes (and their fleet operations). They depend
   on the operator's full local environment and fleet; nothing else
   overrides a green local result.

2. **`main` is the normal and preferred path.** For single-developer repos,
   make changes locally on `main`, validate locally, commit, and push
   `main` to `origin/main`. Do not create feature/fix/chore branch stacks
   by default. A branch is an exception for operator-approved experiments,
   emergency recovery, or a real collaboration/PR need; delete it promptly
   after it is merged or abandoned. The remote `main` must always equal the
   local authoritative tree.

   **Sanctioned exception - infrastructure-target branches.** Long-lived
   branches MAY be used only when the operator deliberately wants parallel
   remote mirrors *per app-infrastructure build target*, not as feature
   stacks. `main` is the baseline target (web/desktop); additional branches
   each carry the **same meta-system** plus that target's build/packaging
   infrastructure, for example `apk` (Android), `windows`, `ios`, `cli`.
   If the operator has not explicitly chosen this layout, do not create
   these branches. Rules for explicit target branches:
   - The meta-system (`_system/`, `bootstrap/`) and shared app code stay
     in sync **from `main`** (main → target, never divergent meta-systems).
   - A target branch differs from `main` only by that target's
     infrastructure (packaging, signing, CI/build wiring, host config).
   - Each target branch is itself a faithful local-authoritative mirror
     for its build type; it is not a place for unreviewed feature work.
   - Document the active target branches and their purpose in the repo
     (e.g. `_system/PROJECT_PROFILE.md` or `README.md`).

3. **Heavy, environment-dependent CI is manual-only.** Workflows that need
   the local fleet/env (e.g. the full master-template lane, stress trend)
   are `workflow_dispatch:` only. They must not run on push/PR/schedule:
   a bare runner cannot reproduce the local environment, so auto-runs
   produce non-actionable red noise that contradicts the mirror model.

4. **Keep only CI that is meaningfully green on a bare runner.** Lightweight
   checks that genuinely pass in a clean checkout may stay auto-triggered.
   Anything that cannot, goes manual-only or is removed.

5. **`main` is unprotected by required status checks** for solo/small-team
   use. The local gate is the protection. (Teams that want server-side
   enforcement should instead invest in making CI reproduce the env, not
   in blocking on a workflow that structurally cannot pass.)

6. **Robustness fixes are not CI hacks.** Any change made so a workflow
   behaves on a bare runner must be a genuine portability/robustness
   improvement that also benefits fresh clones and downstream repos — never
   a CI-only shim that masks a real defect.

7. **GitHub repo settings stay quiet.** For the default mirror model, keep
   GitHub private, keep the default branch as `main`, do not require PRs or
   required status checks, disable Projects/Wiki/Issues unless the operator
   explicitly wants GitHub to be an active collaboration surface, and enable
   delete-branch-on-merge only as cleanup for exceptional PR use. Releases
   may use annotated tags; tags are milestones, not alternate work streams.

8. **`gh` is a mirror helper, not an authority.** Use GitHub CLI to create
   or repair the matching remote repo, set `origin`, verify auth, and push
   `main`. Do not use `gh` to create issue/PR/project workflows, remote-only
   branches, or repo settings that make GitHub more authoritative than the
   local validated tree unless the operator asks for that collaboration mode.

## Single-branch consolidation (safe cleanup)

If a repo has accumulated stray branches (local or remote) and you want to
return it to the single-`main` mirror model, consolidate **without losing any
code or history**. Never delete a branch that holds unique commits before those
commits are preserved elsewhere. The safe, repeatable procedure:

1. **Survey.** `git branch -vv`, `git branch -r`, `git stash list`, `git tag`.
   Note every local and remote branch and whether it is `main`.
2. **Classify each non-`main` branch.** A branch is safe to delete outright only
   if its tip is already reachable from `main` or from an existing tag:
   - merged into `main`: `git branch --merged main` lists it, or
     `git log --oneline main..<branch>` is empty;
   - tag-covered: `git tag --contains <tip>` names a tag.
3. **Preserve unique tips first.** For any branch whose tip is **not** reachable
   from `main` or a tag (donor lanes, old continuity snapshots, abandoned
   experiments), create an annotated archive tag before deleting:
   `git tag -a archive/<name> <tip> -m "Archive <name> before consolidation"`.
   The commit stays permanently reachable; nothing is lost and it is fully
   recoverable.
4. **Push preservation to the mirror** so the remote also retains it:
   `git push origin --tags`.
5. **Delete the stray branches.** Local: `git branch -D <name>`. Remote:
   `git push origin --delete <name>`. Then `git remote prune origin`.
6. **Verify single-branch parity.** `git branch` shows only `main`;
   `git branch -r` shows only `origin/main`; `git rev-parse main` equals
   `git rev-parse origin/main`.

`bootstrap/check-git-discipline.sh <repo>` audits this end-state (single `main`,
no standing local feature branches, no stale remote branches, remote configured)
and is surfaced as a warn-tier check by `bootstrap/system-doctor.sh`, so every
downstream repo is nudged toward this model on each diagnostic run. Tags
(`v*` milestones, `archive/*` preserved tips) are the durable history surface —
they are not alternate work streams and do not count as branches.

## Rationale

Chasing bare-runner green for a fleet/env-dependent lane is unbounded work
with no value when the local lane is already authoritative and the remote
only needs to mirror it. This policy makes the remote calm and truthful:
green where green is meaningful, manual where it is not, and `main` always a
faithful copy of validated local state.

See also: `GIT_REMOTE_AND_SYNC_PROTOCOL.md`,
`SINGLE_FOUNDER_GIT_OPERATING_SYSTEM.md`, `EXECUTION_PROTOCOL.md`,
`VALIDATION_GATES.md`, `DELIVERY_GATES.md`.

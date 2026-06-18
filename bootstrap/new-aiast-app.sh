#!/usr/bin/env bash
# new-aiast-app.sh — THE one canonical, safe entrypoint to bootstrap a new
# downstream AIAST-backed app repo from this parent template. Thin orchestrator
# over the existing scaffold (scaffold-system.sh -> init-project.sh) that makes
# the dangerous parts impossible to get wrong:
#   * refuses to run unless THIS repo is the parent-template (override with
#     AIAST_ALLOW_NONPARENT=1);
#   * refuses to scaffold into a non-empty target unless --force;
#   * scaffolds into the target, where init-project sets role=downstream-app;
#   * proves the PARENT TEMPLATE was not modified (git porcelain snapshot);
#   * runs the scaffold isolation gate + validate-system on the new repo;
#   * emits the next-step prompt: define PRODUCT_BRIEF.md before writing code.
#
#   new-aiast-app.sh --name "<AppName>" [--target DIR] [--profile NAME]
#                    [--dry-run] [--force]
# Default target: $HOME/.MyAppZ/<AppName>.
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/aiaast-lib.sh
source "${SCRIPT_DIR}/lib/aiaast-lib.sh"
TEMPLATE_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
PARENT_REPO="$(cd -- "${TEMPLATE_ROOT}/.." && pwd)"

usage() { cat <<'EOF'
Usage: new-aiast-app.sh --name "<AppName>" [--target DIR] [--profile NAME] [--dry-run] [--force]
EOF
}

NAME=""; TARGET=""; PROFILE="standard"; DRY=0; FORCE=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --name) NAME="${2:-}"; shift 2 ;;
    --target) TARGET="${2:-}"; shift 2 ;;
    --profile) PROFILE="${2:-}"; shift 2 ;;
    --dry-run) DRY=1; shift ;;
    --force) FORCE=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown arg: $1" >&2; usage >&2; exit 2 ;;
  esac
done
[[ -z "${NAME}" ]] && { echo "new_aiast_app_failed: --name is required" >&2; usage >&2; exit 2; }
[[ -z "${TARGET}" ]] && TARGET="${HOME}/.MyAppZ/${NAME}"

# 1. Role guard: must be invoked from the parent template.
role="$(python3 - "${TEMPLATE_ROOT}/_system/.aiast-role.json" <<'PY' 2>/dev/null || true
import json, sys
try: print((json.load(open(sys.argv[1])).get("role") or "").strip())
except Exception: print("")
PY
)"
if [[ "${role}" != "parent-template" && "${AIAST_ALLOW_NONPARENT:-0}" != "1" ]]; then
  echo "new_aiast_app_failed: this command must run from the AIAST parent-template (role=${role:-unknown})." >&2
  echo "  You are trying to create a NEW app from the template; run it inside the template repo." >&2
  exit 1
fi

# 2. Refuse unsafe overwrite.
if [[ -e "${TARGET}" ]] && [[ -n "$(ls -A "${TARGET}" 2>/dev/null || true)" ]] && [[ ${FORCE} -eq 0 ]]; then
  echo "new_aiast_app_failed: target ${TARGET} exists and is non-empty (use --force to scaffold anyway)." >&2
  exit 1
fi

# 3. Snapshot parent state to prove it is untouched.
parent_before="$(cd "${PARENT_REPO}" && git status --porcelain 2>/dev/null | sort | sha256sum | cut -d' ' -f1 || echo "no-git")"

scaffold=(bash "${SCRIPT_DIR}/scaffold-system.sh" "${TARGET}" --app-name "${NAME}" --profile "${PROFILE}" --source "${TEMPLATE_ROOT}")
[[ ${DRY} -eq 1 ]] && scaffold+=(--dry-run)

echo "[new-aiast-app] scaffolding '${NAME}' -> ${TARGET} (profile=${PROFILE}, dry-run=${DRY})"
if ! "${scaffold[@]}"; then
  echo "new_aiast_app_failed: scaffold step failed" >&2
  exit 1
fi

# 4. Verify the parent template was not modified.
parent_after="$(cd "${PARENT_REPO}" && git status --porcelain 2>/dev/null | sort | sha256sum | cut -d' ' -f1 || echo "no-git")"
parent_touched="no"
[[ "${parent_before}" != "${parent_after}" ]] && parent_touched="yes"

if [[ ${DRY} -eq 1 ]]; then
  echo ""
  echo "Target repo:            ${TARGET} (DRY RUN — not created)"
  echo "Parent template:        ${PARENT_REPO}"
  echo "Parent touched:         ${parent_touched}"
  echo "Validation:             skipped (dry-run)"
  echo "Next action:            re-run without --dry-run to create the repo"
  echo "new_aiast_app_dry_run_ok name=${NAME} target=${TARGET}"
  exit 0
fi

# 5. Validate the new repo: isolation gate + system validation + definition gate.
val="pass"
bash "${SCRIPT_DIR}/check-scaffold-isolation-gate.sh" "${TARGET}" --best-effort >/dev/null 2>&1 || val="fail(isolation)"
bash "${SCRIPT_DIR}/validate-system.sh" "${TARGET}" >/dev/null 2>&1 || val="fail(validate-system)"
gate_state="$(bash "${SCRIPT_DIR}/check-app-definition-gate.sh" "${TARGET}" 2>/dev/null | head -1 || true)"

echo ""
echo "Target repo created:    ${TARGET}"
echo "Local AIAST copied:     from ${TEMPLATE_ROOT}"
echo "Role set:               downstream-app"
echo "Parent template touched: ${parent_touched}"
echo "Validation:             ${val}"
echo "App definition:         ${gate_state}"
echo "Next action:            cd ${TARGET} && define PRODUCT_BRIEF.md (what/who/success)"
echo "                        before writing any runtime app code. Then build into app/."
if [[ "${parent_touched}" == "yes" || "${val}" != "pass" ]]; then
  echo "new_aiast_app_warn name=${NAME} parent_touched=${parent_touched} validation=${val}"
  exit 2
fi
echo "new_aiast_app_ok name=${NAME} target=${TARGET}"

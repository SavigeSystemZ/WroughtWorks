#!/usr/bin/env bash
# check-app-definition-gate.sh — Hard gate: block runtime coding in a downstream
# app repo until the app is DEFINED. Thin enforcement layer over the existing
# classifier bootstrap/check-app-definition-state.sh (which decides role + app
# state); this adds a binary BLOCK/ALLOW verdict plus the checklist of definition
# files to fill, and an exit contract suitable for enforcement.
#
#   check-app-definition-gate.sh <target-repo> [--strict] [--json]
# Exit: 0 not_applicable (parent-template) or open (app defined enough to build);
#       2 BLOCKED advisory (downstream blank app, non-strict -> doctor warn);
#       1 BLOCKED strict (enforcement / new-project gate).
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/aiaast-lib.sh
source "${SCRIPT_DIR}/lib/aiaast-lib.sh"

usage() { echo "usage: $0 <target-repo> [--strict] [--json]"; }
repo="${1:-}"; shift || true
strict=0; json_mode=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --strict) strict=1; shift ;;
    --json) json_mode=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done
[[ -z "${repo}" ]] && { usage >&2; exit 2; }

# Reuse the canonical classifier for role + app state.
state_json="$(bash "${SCRIPT_DIR}/check-app-definition-state.sh" "${repo}" --json 2>/dev/null || true)"
read -r role app_state < <(python3 - "${state_json}" <<'PY'
import json, sys
try:
    d = json.loads(sys.argv[1])
except Exception:
    d = {}
print((d.get("role") or "downstream-app"), (d.get("app_state") or "blank_app_undefined"))
PY
)

emit() { # verdict exit_code human
  local verdict="$1" code="$2" human="$3"
  if [[ ${json_mode} -eq 1 ]]; then
    if [[ "${verdict}" == "APP_UNDEFINED_BLOCK" ]]; then
      aiaast_json_error "APP_UNDEFINED_BLOCK" "${human}" "check-app-definition-gate.sh" "app-definition"
    else
      aiaast_json_ok "{\"result\":\"${verdict}\",\"role\":\"${role}\",\"app_state\":\"${app_state}\"}" "check-app-definition-gate.sh" "app-definition"
    fi
  else
    echo "${verdict} role=${role} app_state=${app_state}"
    [[ -n "${human}" ]] && printf '%s\n' "${human}"
  fi
  exit "${code}"
}

if [[ "${role}" == "parent-template" ]]; then
  emit "app_definition_gate_not_applicable" 0 "This is the parent template; no app-definition gate."
fi

if [[ "${app_state}" != "blank_app_undefined" ]]; then
  emit "app_definition_gate_open" 0 "App is defined (state=${app_state}); building into app/ is allowed."
fi

# Downstream blank app -> BLOCK. List the definition surfaces to fill.
needed=(
  "PRODUCT_BRIEF.md"
  "_system/PROJECT_PROFILE.md"
  "_system/PROJECT_DOMAIN_MANIFEST.json"
  "_system/app-context/"
  "_system/personas/APP_PERSONA.md"
)
missing=""
for f in "${needed[@]}"; do
  [[ -e "${repo}/${f}" ]] || missing+="${f} "
done
directive="APP NOT DEFINED — do NOT write runtime app code yet. Define the app first:
  1. Interview the operator and fill PRODUCT_BRIEF.md (what/who/success).
  2. Fill _system/PROJECT_PROFILE.md and _system/PROJECT_DOMAIN_MANIFEST.json.
  3. Generate app-context (_system/app-context/) and forge _system/personas/APP_PERSONA.md.
  4. Then build INTO app/ via the _system/ meta-system.
Missing/absent definition surfaces: ${missing:-none (present but app/src is still empty)}"

if [[ ${strict} -eq 1 ]]; then
  emit "APP_UNDEFINED_BLOCK" 1 "${directive}"
else
  emit "APP_UNDEFINED_BLOCK" 2 "${directive}"
fi

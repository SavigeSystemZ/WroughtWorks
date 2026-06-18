#!/usr/bin/env bash
# promote-generic-improvement.sh — Promote a generic downstream candidate into the
# parent template, but ONLY if the promotion gates pass (review). Never commits;
# prints the required follow-up. See _system/SELF_IMPROVEMENT_PROMOTION_REVIEW_PROTOCOL.md.
#
#   promote-generic-improvement.sh <downstream-repo> <index> (--dry-run | --apply)
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/aiaast-lib.sh
source "${SCRIPT_DIR}/lib/aiaast-lib.sh"
TEMPLATE_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"

repo="${1:-}"; index="${2:-}"; mode=""
shift 2 2>/dev/null || true
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) mode="dry-run"; shift ;;
    --apply) mode="apply"; shift ;;
    -h|--help) echo "usage: $0 <downstream-repo> <index> (--dry-run|--apply)"; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done
[[ -z "${repo}" || -z "${index}" || -z "${mode}" ]] && { echo "usage: $0 <downstream-repo> <index> (--dry-run|--apply)"; exit 2; }

# Parent-template role guard: you promote INTO the template.
role="$(python3 - "${TEMPLATE_ROOT}/_system/.aiast-role.json" <<'PY' 2>/dev/null || true
import json, sys
try: print((json.load(open(sys.argv[1])).get("role") or "").strip())
except Exception: print("")
PY
)"
if [[ "${role}" != "parent-template" && "${AIAST_ALLOW_NONPARENT:-0}" != "1" ]]; then
  echo "promote_improvement_failed: must run from the parent template (role=${role:-unknown})"; exit 1
fi

# Gate: run the review (don't let its non-zero exit trip set -e).
set +e
review="$(bash "${SCRIPT_DIR}/review-improvement-candidate.sh" "${repo}" "${index}" 2>&1)"; gate_rc=$?
set -e
rel="$(python3 -c "import json,sys;print(json.loads(sys.stdin.read()).get('path',''))" <<<"${review}" 2>/dev/null || true)"
if [[ ${gate_rc} -ne 0 ]]; then
  echo "promote_improvement_refused: candidate is NOT promotable"
  printf '%s\n' "${review}"
  exit 1
fi

src="${repo}/${rel}"
dest="${TEMPLATE_ROOT}/${rel}"
[[ -f "${src}" ]] || { echo "promote_improvement_failed: source missing ${src}"; exit 1; }

if [[ "${mode}" == "dry-run" ]]; then
  echo "promote_improvement_dry_run path=${rel}"
  echo "  source: ${src}"
  echo "  dest:   ${dest} $([[ -e "${dest}" ]] && echo '(EXISTS — would overwrite)' || echo '(new)')"
  echo "  gates:  PROMOTABLE"
  echo "  next:   re-run with --apply, then add a validator, regenerate surfaces,"
  echo "          re-sign integrity, write a rollback+migration note, run the master lane."
  exit 0
fi

# apply
mkdir -p "$(dirname "${dest}")"
cp "${src}" "${dest}"
echo "promote_improvement_applied path=${rel} dest=${dest}"
echo "REQUIRED FOLLOW-UP (not auto-done):"
echo "  1. Add/confirm a validator for ${rel} (check-registry-contract-graph requires"
echo "     a validator for any drift_severity=fail file)."
echo "  2. bash bootstrap/generate-system-registry.sh ${TEMPLATE_ROOT} --write"
echo "     bash bootstrap/generate-capabilities-sheet.sh ${TEMPLATE_ROOT} --write"
echo "     bash bootstrap/verify-integrity.sh --generate --target ${TEMPLATE_ROOT}"
echo "  3. Record a rollback + downstream migration note in AIAST_CHANGELOG.md."
echo "  4. Run _TEMPLATE_FACTORY/validate-master-template.sh before committing."

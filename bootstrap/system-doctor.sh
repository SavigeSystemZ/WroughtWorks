#!/usr/bin/env bash
# system-doctor.sh — Run the full structural / integrity / instruction / awareness / runtime health-check suite (auto / strict / heal).
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_TARGET="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
DEFAULT_SOURCE="${DEFAULT_TARGET}"
# shellcheck source=bootstrap/lib/aiaast-lib.sh
source "${SCRIPT_DIR}/lib/aiaast-lib.sh"

usage() {
  cat <<'EOF'
Usage: system-doctor.sh [target-repo] [--source <template-root>] [--strict] [--heal] [--report] [--record]

Run structural, integrity, instruction-layer, awareness, runtime-foundation, placeholder, and hallucination-risk checks. In heal mode, attempt safe automatic recovery first.

Options:
  --report   After checks, generate a full diagnostic report.
  --record   After checks, append the result to _system/health-history.json.
EOF
}

TARGET_REPO=""
SOURCE="${DEFAULT_SOURCE}"
STRICT=0
HEAL=0
REPORT=0
RECORD=0
MODE="auto"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --source)
      SOURCE="${2:-}"
      shift 2
      ;;
    --strict)
      STRICT=1
      shift
      ;;
    --heal)
      HEAL=1
      shift
      ;;
    --report)
      REPORT=1
      shift
      ;;
    --record)
      RECORD=1
      shift
      ;;
    --mode)
      MODE="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      if [[ -z "${TARGET_REPO}" ]]; then
        TARGET_REPO="$1"
        shift
      else
        echo "Unexpected argument: $1" >&2
        exit 1
      fi
      ;;
  esac
done

if [[ -z "${TARGET_REPO}" ]]; then
  TARGET_REPO="${DEFAULT_TARGET}"
fi

if [[ ! -d "${TARGET_REPO}" ]]; then
  echo "Target repo does not exist: ${TARGET_REPO}" >&2
  exit 1
fi

if [[ ${HEAL} -eq 1 || ${RECORD} -eq 1 ]]; then
  aiaast_assert_non_root_for_repo_writes
fi

run_check() {
  local label="$1"
  shift
  local output
  if output="$("$@" 2>&1)"; then
    printf '[pass] %s\n' "${label}"
    [[ -n "${output}" ]] && printf '%s\n' "${output}"
    return 0
  fi
  printf '[fail] %s\n' "${label}"
  [[ -n "${output}" ]] && printf '%s\n' "${output}"
  return 1
}

if [[ ${HEAL} -eq 1 ]]; then
  echo "Heal mode: attempting safe repair and awareness refresh before diagnosis..."
  echo "Self-healing scope is governed by _system/SELF_HEALING_BOUNDARY.md"
  # repair-system restores MISSING files from the template and needs a valid
  # template --source. In a downstream app (no local template, or --source not
  # given) it cannot run — but that must NOT block the source-INDEPENDENT recovery
  # below: regenerating a corrupt managed surface (e.g. SYSTEM_REGISTRY.json) does
  # not need the template. So make it best-effort and always regenerate surfaces.
  if ! bash "${SCRIPT_DIR}/repair-system.sh" "${TARGET_REPO}" --source "${SOURCE}"; then
    echo "[heal] repair-system skipped (no valid template source); continuing with surface regeneration" >&2
  fi
  # Regenerate ALL managed surfaces under the managed-surfaces lock — this is what
  # recovers a corrupt/missing generated surface, and needs no template source.
  _aiaast_heal_regen() {
    bash "${SCRIPT_DIR}/generate-host-adapters.sh" "${TARGET_REPO}" --write
    bash "${SCRIPT_DIR}/generate-system-key.sh" "${TARGET_REPO}" --write
    bash "${SCRIPT_DIR}/generate-system-registry.sh" "${TARGET_REPO}" --write
    bash "${SCRIPT_DIR}/generate-operating-profile.sh" "${TARGET_REPO}" --write
    bash "${SCRIPT_DIR}/generate-capabilities-sheet.sh" "${TARGET_REPO}" --write
    bash "${SCRIPT_DIR}/verify-integrity.sh" --generate --target "${TARGET_REPO}"
  }
  aiaast_with_lock "${TARGET_REPO}" managed-surfaces 10 -- _aiaast_heal_regen
fi

strict_flag=()
[[ ${STRICT} -eq 1 ]] && strict_flag+=(--strict)
mode_flag=()
[[ "${MODE}" != "auto" ]] && mode_flag+=(--mode "${MODE}")

failed=0
warned=0
warning_labels=()

run_check "validate-system" bash "${SCRIPT_DIR}/validate-system.sh" "${TARGET_REPO}" "${strict_flag[@]}" "${mode_flag[@]}" || failed=1
run_check "check-install-boundary" bash "${SCRIPT_DIR}/check-install-boundary.sh" "${TARGET_REPO}" || failed=1
run_check "verify-integrity" bash "${SCRIPT_DIR}/verify-integrity.sh" --check --target "${TARGET_REPO}" || failed=1
run_check "validate-instruction-layer" "${SCRIPT_DIR}/aiast-cli" check-validate-layer "${TARGET_REPO}" || failed=1
run_check "check-host-adapter-alignment" "${SCRIPT_DIR}/aiast-cli" check-alignment "${TARGET_REPO}" || failed=1
run_check "check-host-ingestion" bash "${SCRIPT_DIR}/check-host-ingestion.sh" "${TARGET_REPO}" || failed=1
run_check "check-host-bundle" bash "${SCRIPT_DIR}/check-host-bundle.sh" "${TARGET_REPO}" || failed=1
run_check "check-system-awareness" "${SCRIPT_DIR}/aiast-cli" check-awareness "${TARGET_REPO}" || failed=1
if run_check "check-swarm-fleet" bash "${SCRIPT_DIR}/check-swarm-fleet.sh" "${TARGET_REPO}"; then
  # After swarm fleet is verified, also show plugin capabilities if matrix exists
  matrix_file="${TARGET_REPO}/_system/CAPABILITY_MATRIX.json"
  if [[ -f "${matrix_file}" ]]; then
    printf "  → Discovered capabilities: "
    jq -r '.capabilities | keys | join(", ")' "${matrix_file}"
  fi
else
  failed=1
fi
run_check "check-repo-permissions" bash "${SCRIPT_DIR}/check-repo-permissions.sh" "${TARGET_REPO}" || failed=1
run_check "check-agent-orchestration" bash "${SCRIPT_DIR}/check-agent-orchestration.sh" "${TARGET_REPO}" || failed=1
run_check "check-network-bindings" bash "${SCRIPT_DIR}/check-network-bindings.sh" "${TARGET_REPO}" --include-template-assets || failed=1
run_check "check-delivery-gate-alignment" bash "${SCRIPT_DIR}/check-delivery-gate-alignment.sh" "${TARGET_REPO}" "${strict_flag[@]}" || failed=1
run_check "check-working-directory-alignment" bash "${SCRIPT_DIR}/check-working-directory-alignment.sh" "${TARGET_REPO}" || failed=1
if run_check "check-project-target-consistency" bash "${SCRIPT_DIR}/check-project-target-consistency.sh" "${TARGET_REPO}"; then
  true
else
  warned=1
  warning_labels+=("project-target-consistency")
fi
if run_check "check-global-shim-alignment" bash "${SCRIPT_DIR}/check-global-shim-alignment.sh"; then
  true
else
  warned=1
  warning_labels+=("global-shim-alignment")
fi
run_check "emit-session-environment" bash "${SCRIPT_DIR}/emit-session-environment.sh" "${TARGET_REPO}" || failed=1

# Advisory identity/onboarding gate (never fails the doctor): on a blank
# downstream-app repo this prints the "define the app first" directive so an
# agent does not mistake it for the meta-system template. No-op on
# parent-template. Non-strict, so exit stays 0.
run_check "check-app-definition-state" bash "${SCRIPT_DIR}/check-app-definition-state.sh" "${TARGET_REPO}" || true
# Hard app-definition gate (binary BLOCK/ALLOW). not_applicable on parent-template
# (exit 0); on a downstream blank app it returns 2 (advisory) -> doctor warn-tier nudge.
if run_check "check-app-definition-gate" bash "${SCRIPT_DIR}/check-app-definition-gate.sh" "${TARGET_REPO}"; then
  true
else
  warned=1
  warning_labels+=("app-definition-gate")
fi

if run_check "check-placeholders" bash "${SCRIPT_DIR}/check-placeholders.sh" "${TARGET_REPO}" --summary "${mode_flag[@]}"; then
  true
else
  warned=1
  warning_labels+=("placeholders")
fi

if run_check "check-runtime-foundations" bash "${SCRIPT_DIR}/check-runtime-foundations.sh" "${TARGET_REPO}" "${strict_flag[@]}"; then
  true
else
  if [[ ${STRICT} -eq 1 ]]; then
    failed=1
  else
    warned=1
    warning_labels+=("runtime-foundations")
  fi
fi

if run_check "check-environment" bash "${SCRIPT_DIR}/check-environment.sh" "${TARGET_REPO}"; then
  true
else
  warned=1
  warning_labels+=("environment")
fi

if run_check "check-packaging-targets" bash "${SCRIPT_DIR}/check-packaging-targets.sh" "${TARGET_REPO}" "${strict_flag[@]}"; then
  true
else
  if [[ ${STRICT} -eq 1 ]]; then
    failed=1
  else
    warned=1
    warning_labels+=("packaging-targets")
  fi
fi

if run_check "check-hallucination" bash "${SCRIPT_DIR}/check-hallucination.sh" "${TARGET_REPO}"; then
  true
else
  warned=1
  warning_labels+=("hallucination-risk")
fi

if run_check "check-bootstrap-permissions" bash "${SCRIPT_DIR}/check-bootstrap-permissions.sh" "${TARGET_REPO}"; then
  true
else
  warned=1
  warning_labels+=("bootstrap-permissions")
fi

if run_check "check-evidence-quality" bash "${SCRIPT_DIR}/check-evidence-quality.sh" "${TARGET_REPO}"; then
  true
else
  warned=1
  warning_labels+=("evidence-quality")
fi

# Hallucinated-completion guard: success claims in handoff/continuity surfaces
# must sit next to evidence. Pure warn-tier (exit 2 = advisory); the release gate
# runs it --strict to block.
if run_check "check-claim-evidence-map" bash "${SCRIPT_DIR}/check-claim-evidence-map.sh" "${TARGET_REPO}"; then
  true
else
  warned=1
  warning_labels+=("claim-evidence-map")
fi

if run_check "check-working-file-staleness" bash "${SCRIPT_DIR}/check-working-file-staleness.sh" "${TARGET_REPO}"; then
  true
else
  warned=1
  warning_labels+=("working-file-staleness")
fi

# Multi-agent write safety: no unlocked shared-state writers (regression guard).
if run_check "check-write-command-lease-coverage" bash "${SCRIPT_DIR}/check-write-command-lease-coverage.sh" "${TARGET_REPO}"; then
  true
else
  warned=1
  warning_labels+=("write-lease-coverage")
fi

# Git-side mirror discipline: single-branch / local-authoritative hygiene per
# GIT_SIDE_MIRROR_POLICY.md. Pure warn-tier — standing feature branches or a
# divergent main are advisory nudges toward the single-main mirror model, never
# a hard doctor failure (a repo may legitimately be mid-operation).
if run_check "check-git-discipline" bash "${SCRIPT_DIR}/check-git-discipline.sh" "${TARGET_REPO}"; then
  true
else
  warned=1
  warning_labels+=("git-discipline")
fi

if run_check "check-local-self-improvement" bash "${SCRIPT_DIR}/check-local-self-improvement.sh" "${TARGET_REPO}"; then
  true
else
  if [[ ${STRICT} -eq 1 ]]; then
    failed=1
  else
    warned=1
    warning_labels+=("local-self-improvement")
  fi
fi

if run_check "validate-app-context-files" bash "${SCRIPT_DIR}/validate-app-context-files.sh" "${TARGET_REPO}" "${strict_flag[@]}"; then
  true
else
  if [[ ${STRICT} -eq 1 ]]; then
    failed=1
  else
    warned=1
    warning_labels+=("app-context-files")
  fi
fi

# Self-compliance: the generated System Nervous System map must match the registry.
if run_check "system-nervous-system" bash "${SCRIPT_DIR}/generate-system-nervous-system.sh" "${TARGET_REPO}" --check; then
  true
else
  if [[ ${STRICT} -eq 1 ]]; then
    failed=1
  else
    warned=1
    warning_labels+=("system-nervous-system")
  fi
fi

# Self-compliance: the generated Task Fingerprint Routing doc must match its table.
if run_check "task-fingerprint-routing" bash "${SCRIPT_DIR}/classify-task-fingerprint.sh" --check; then
  true
else
  if [[ ${STRICT} -eq 1 ]]; then
    failed=1
  else
    warned=1
    warning_labels+=("task-fingerprint-routing")
  fi
fi

# Self-compliance: the generated CAPABILITIES.md must still match the live system.
if run_check "capabilities-sheet" bash "${SCRIPT_DIR}/generate-capabilities-sheet.sh" "${TARGET_REPO}" --check; then
  true
else
  if [[ ${STRICT} -eq 1 ]]; then
    failed=1
  else
    warned=1
    warning_labels+=("capabilities-sheet")
  fi
fi

resolved_source="$(cd -- "${SOURCE}" && pwd)"
resolved_target="$(cd -- "${TARGET_REPO}" && pwd)"
if [[ "${resolved_source}" == "${resolved_target}" ]]; then
  echo "[info] detect-drift"
  echo "Skipped: source and target resolve to the same directory."
else
  drift_output="$(bash "${SCRIPT_DIR}/detect-drift.sh" "${TARGET_REPO}" --source "${SOURCE}" 2>&1 || true)"
  echo "[info] detect-drift"
  printf '%s\n' "${drift_output}"
  if [[ "${drift_output}" != *"drift_ok"* ]]; then
    warned=1
    warning_labels+=("drift")
  fi
fi

# Observability (non-failing): show the live agent lock/lease roster so an
# operator running the doctor sees which agents are concurrently active.
echo "[info] active-agents"
bash "${SCRIPT_DIR}/emit-active-agents.sh" "${TARGET_REPO}" 2>&1 || true

FINAL_RESULT="ok"
FINAL_EXIT=0

if [[ ${failed} -eq 1 ]]; then
  echo "system_doctor_failed"
  FINAL_RESULT="fail"
  FINAL_EXIT=1
elif [[ ${warned} -eq 1 ]]; then
  if [[ ${#warning_labels[@]} -gt 0 ]]; then
    printf 'system_doctor_warnings=%s\n' "$(IFS=,; echo "${warning_labels[*]}")"
  fi
  echo "system_doctor_warn"
  FINAL_RESULT="warn"
  FINAL_EXIT=2
else
  echo "system_doctor_ok"
fi

if [[ ${REPORT} -eq 1 ]]; then
  echo ""
  echo "--- Diagnostic Report ---"
  bash "${SCRIPT_DIR}/generate-diagnostic-report.sh" "${TARGET_REPO}"
fi

if [[ ${RECORD} -eq 1 ]]; then
  HISTORY_FILE="${TARGET_REPO}/_system/health-history.json"
  if [[ -f "${HISTORY_FILE}" ]]; then
    python3 - <<PY_RECORD "${HISTORY_FILE}" "${FINAL_RESULT}"
import json, sys
from datetime import datetime, timezone
path, result = sys.argv[1], sys.argv[2]
try:
    entries = json.loads(open(path).read())
except Exception:
    entries = []
entries.append({"timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"), "result": result})
# Rotate: keep last 50 entries
entries = entries[-50:]
open(path, "w").write(json.dumps(entries, indent=2) + "\n")
print(f"health_history_recorded: {result} (total={len(entries)})")
PY_RECORD
  fi
fi

exit ${FINAL_EXIT}

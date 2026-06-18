#!/usr/bin/env bash
# release-aiast-template.sh — Treat AIAST like a versioned platform. Run the
# release-readiness gate sequence over the parent template and report whether it
# is releasable; optionally seal a release packet. Local-authoritative: it never
# tags or pushes — it prints the operator command to do so. See
# _system/AIAST_RELEASE_CHECKLIST.md and AIAST_VERSION_POLICY.md.
#
#   release-aiast-template.sh [--check] [--seal] [--json]
# --check (default): run the gates, report readiness, mutate nothing.
# --seal: on success, also generate a release packet (sealed evidence).
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/aiaast-lib.sh
source "${SCRIPT_DIR}/lib/aiaast-lib.sh"
TEMPLATE_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"

MODE="check"; json_mode=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --check) MODE="check"; shift ;;
    --seal) MODE="seal"; shift ;;
    --json) json_mode=1; shift ;;
    -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

version="$(grep -oE '[0-9]+\.[0-9]+\.[0-9]+' "${TEMPLATE_ROOT}/_system/.template-version" 2>/dev/null | head -1 || echo unknown)"
results=(); failed=0
gate() { # label cmd...
  local label="$1"; shift
  if "$@" >/dev/null 2>&1; then results+=("PASS ${label}"); else results+=("FAIL ${label}"); failed=1; fi
}

export AIAST_REQUIRE_CLI=1   # the release gate demands the validator binary build
gate "validate-instruction-layer" bash "${SCRIPT_DIR}/validate-instruction-layer.sh" "${TEMPLATE_ROOT}"
gate "check-system-awareness"     bash "${SCRIPT_DIR}/check-system-awareness.sh" "${TEMPLATE_ROOT}"
gate "system-doctor-strict"       bash "${SCRIPT_DIR}/system-doctor.sh" "${TEMPLATE_ROOT}" --strict
gate "validate-system-strict"     bash "${SCRIPT_DIR}/validate-system.sh" "${TEMPLATE_ROOT}" --strict
gate "registry-contract-graph"    bash "${SCRIPT_DIR}/check-registry-contract-graph.sh" "${TEMPLATE_ROOT}"
gate "verify-integrity"           bash "${SCRIPT_DIR}/verify-integrity.sh" --check --target "${TEMPLATE_ROOT}"
gate "claim-evidence-strict"      bash "${SCRIPT_DIR}/check-claim-evidence-map.sh" "${TEMPLATE_ROOT}" --strict
gate "lease-coverage"             bash "${SCRIPT_DIR}/check-write-command-lease-coverage.sh" "${TEMPLATE_ROOT}"
# Scaffold-test: the isolation gate is downstream-only, so we prove scaffolding via
# a real dry-run scaffold instead of running the parent-refusing gate here.
gate "new-app-dry-run"            bash "${SCRIPT_DIR}/new-aiast-app.sh" --name __ReleaseProbe__ --target /tmp/__aiaast_release_probe__ --dry-run

packet="(not sealed)"
if [[ "${MODE}" == "seal" && ${failed} -eq 0 ]]; then
  if bash "${SCRIPT_DIR}/generate-release-packet.sh" "${TEMPLATE_ROOT}" --apply >/tmp/.aiaast_release_packet.out 2>&1; then
    packet="$(grep -oE '_META_AGENT_SYSTEM/[^ ]*RELEASE_PACKET[^ ]*' /tmp/.aiaast_release_packet.out | head -1 || echo sealed)"
  else
    packet="(seal failed)"; failed=1
  fi
fi

printf '%s\n' "${results[@]}"
if [[ ${json_mode} -eq 1 ]]; then
  st="release_ready"; [[ ${failed} -ne 0 ]] && st="release_blocked"
  aiaast_json_ok "{\"result\":\"${st}\",\"version\":\"${version}\",\"gates_failed\":${failed},\"packet\":\"${packet}\"}" "release-aiast-template.sh" "release"
fi

if [[ ${failed} -ne 0 ]]; then
  echo "release_blocked version=${version} — fix the FAIL gates above"
  exit 1
fi
echo "release_ready version=${version} packet=${packet}"
echo "Operator (local-authoritative — run yourself when ready):"
echo "  git tag -a v${version} -m 'AIAST ${version}' && git push origin v${version}"
echo "  then mirror main per GIT_SIDE_MIRROR_POLICY.md and migrate the fleet."

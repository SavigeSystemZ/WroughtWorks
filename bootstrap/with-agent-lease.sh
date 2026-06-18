#!/usr/bin/env bash
# with-agent-lease.sh — Ergonomic front-end to the lease primitive aiaast_with_lock.
# Run a write-capable command while holding a named, lease-reclaimed lock on a scope,
# so two agents never edit the same shared surface at once.
#
#   with-agent-lease.sh --scope "_system" --agent "codex" [--repo DIR] [--ttl N] -- <cmd...>
#
# --repo defaults to the repo containing this script. --ttl is minutes (default 10).
# AIAST_LOCK_DISABLE=1 bypasses locking (CI negative tests only).
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/aiaast-lib.sh
source "${SCRIPT_DIR}/lib/aiaast-lib.sh"
# shellcheck source=lib/aiaast-lock.sh
[[ -f "${SCRIPT_DIR}/lib/aiaast-lock.sh" ]] && source "${SCRIPT_DIR}/lib/aiaast-lock.sh"

REPO=""; SCOPE=""; AGENT=""; TTL=10
while [[ $# -gt 0 ]]; do
  case "$1" in
    --scope) SCOPE="${2:-}"; shift 2 ;;
    --agent) AGENT="${2:-}"; shift 2 ;;
    --repo)  REPO="${2:-}"; shift 2 ;;
    --ttl)   TTL="${2:-}"; shift 2 ;;
    --) shift; break ;;
    -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
    *) echo "with_agent_lease_failed: unexpected arg before --: $1" >&2; exit 2 ;;
  esac
done

[[ -z "${SCOPE}" ]] && { echo "with_agent_lease_failed: --scope is required" >&2; exit 2; }
[[ -z "${AGENT}" ]] && { echo "with_agent_lease_failed: --agent is required" >&2; exit 2; }
[[ $# -eq 0 ]] && { echo "with_agent_lease_failed: no command after --" >&2; exit 2; }
[[ -z "${REPO}" ]] && REPO="$(cd -- "${SCRIPT_DIR}/.." && pwd)"

if ! declare -F aiaast_with_lock >/dev/null 2>&1; then
  echo "with_agent_lease_failed: lease primitive aiaast_with_lock unavailable" >&2
  exit 1
fi

# Tag the lease holder so the live roster (emit-active-agents.sh) shows who holds it.
export AIAST_AGENT_ID="${AGENT}"
aiaast_with_lock "${REPO}" "${SCOPE}" "${TTL}" -- "$@"

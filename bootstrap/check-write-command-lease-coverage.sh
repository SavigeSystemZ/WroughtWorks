#!/usr/bin/env bash
# check-write-command-lease-coverage.sh — Regression guard for multi-agent write
# safety. Every bootstrap script that mutates SHARED STATE (a canonical managed
# surface, or shared agent-state) must either acquire a lease (aiaast_with_lock /
# with-agent-lease.sh) or be on the baseline allowlist of writers that are
# orchestrated under lock by the lane / are deterministic idempotent regenerators.
# A NEW unlocked, un-allowlisted shared-state writer fails the check.
#
#   check-write-command-lease-coverage.sh <target-repo> [--json] [--update-baseline]
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/aiaast-lib.sh
source "${SCRIPT_DIR}/lib/aiaast-lib.sh"

repo="${1:-}"; shift || true
json_mode=0; update=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --json) json_mode=1; shift ;;
    --update-baseline) update=1; shift ;;
    -h|--help) echo "usage: $0 <target-repo> [--json] [--update-baseline]"; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done
[[ -z "${repo}" ]] && { echo "usage: $0 <target-repo> [--json]"; exit 2; }

bootstrap_dir="${repo}/bootstrap"
allowlist="${repo}/_system/write-lease-coverage-allowlist.txt"
[[ -d "${bootstrap_dir}" ]] || { echo "write_lease_coverage_failed: no ${bootstrap_dir}"; exit 1; }

# Lease primitives must exist.
if ! grep -q 'aiaast_with_lock' "${bootstrap_dir}/lib/aiaast-lock.sh" 2>/dev/null; then
  echo "write_lease_coverage_failed: lease primitive aiaast_with_lock missing"; exit 1
fi
[[ -f "${bootstrap_dir}/with-agent-lease.sh" ]] || { echo "write_lease_coverage_failed: with-agent-lease.sh missing"; exit 1; }

out_file="$(mktemp)"; trap 'rm -f "${out_file}"' EXIT
set +e
python3 - "${bootstrap_dir}" "${allowlist}" "${update}" >"${out_file}" 2>&1 <<'PY'
import re, sys
from pathlib import Path

bd = Path(sys.argv[1])
allow_path = Path(sys.argv[2])
update = sys.argv[3] == "1"

# Shared-state mutation signatures: writing a canonical managed surface or shared
# agent-state. (Reading is fine; we look for writes/appends/--write handling.)
WRITE_SIG = re.compile(
    r"(SYSTEM_REGISTRY\.json|INTEGRITY_MANIFEST|/KEY\.md|CAPABILITIES\.md|"
    r"SUPER_TEMPLATE_MASTER_MAP|system-nervous-system|host-adapter-manifest|"
    r"agent-state/.*(audit|meta-sync|locks)|improvement-candidates\.jsonl)"
)
WRITE_OP = re.compile(r"(>\s*\"?\$\{?\w|\.write_text|>>\s|--write\b|cp\s|mv\s|tee\s)")
LOCKED = re.compile(r"(aiaast_with_lock|with-agent-lease)")

allow = set()
if allow_path.exists():
    allow = {l.strip() for l in allow_path.read_text().splitlines() if l.strip() and not l.startswith("#")}

writers, unlocked = [], []
for p in sorted(bd.glob("*.sh")):
    txt = p.read_text(errors="replace")
    if WRITE_SIG.search(txt) and WRITE_OP.search(txt):
        name = p.name
        writers.append(name)
        if not LOCKED.search(txt) and name not in allow:
            unlocked.append(name)

if update:
    allow_path.write_text("# Bootstrap scripts that write shared state without an inline lease.\n"
                          "# They are orchestrated under lock by the lane or are deterministic\n"
                          "# idempotent regenerators. A NEW shared-state writer must lock or be\n"
                          "# justified here. Regenerate with check-write-command-lease-coverage.sh --update-baseline.\n"
                          + "\n".join(sorted(set(writers) - {w for w in writers if LOCKED.search((bd/w).read_text(errors='replace'))})) + "\n")
    print(f"updated baseline: {allow_path}")
    sys.exit(0)

import json
if unlocked:
    print(json.dumps({"result": "write_lease_coverage_failed", "writers": len(writers),
                      "unlocked_unallowlisted": unlocked}, indent=2))
    sys.exit(1)
print(json.dumps({"result": "write_lease_coverage_ok", "writers": len(writers),
                  "allowlisted": len(allow)}))
sys.exit(0)
PY
rc=$?
set -e

payload="$(cat "${out_file}")"
[[ ${update} -eq 1 ]] && { printf '%s\n' "${payload}"; exit 0; }
if [[ ${rc} -eq 0 ]]; then
  if [[ ${json_mode} -eq 1 ]]; then aiaast_json_ok "${payload}" "check-write-command-lease-coverage.sh" "locks"
  else printf '%s\n' "${payload}"; echo "write_lease_coverage_ok"; fi
else
  if [[ ${json_mode} -eq 1 ]]; then aiaast_json_error "write_lease_coverage_failed" "$(tr '\n' ' ' <"${out_file}")" "check-write-command-lease-coverage.sh" "locks"
  else printf '%s\n' "${payload}"; echo "write_lease_coverage_failed"; fi
  exit 1
fi

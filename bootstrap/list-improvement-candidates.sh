#!/usr/bin/env bash
# list-improvement-candidates.sh — List generic improvement candidates a downstream
# repo tagged (via tag-improvement-candidate.sh) for possible promotion into AIAST.
#
#   list-improvement-candidates.sh <downstream-repo> [--json]
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/aiaast-lib.sh
source "${SCRIPT_DIR}/lib/aiaast-lib.sh"

repo="${1:-}"; shift || true
json_mode=0
[[ "${1:-}" == "--json" ]] && json_mode=1
[[ -z "${repo}" ]] && { echo "usage: $0 <downstream-repo> [--json]"; exit 2; }

reg="${repo}/_system/improvement-candidates.jsonl"
if [[ ! -f "${reg}" ]]; then
  [[ ${json_mode} -eq 1 ]] && aiaast_json_ok '{"result":"improvement_candidates","count":0,"candidates":[]}' "list-improvement-candidates.sh" "self-improvement" \
    || echo "improvement_candidates count=0 (no ${reg})"
  exit 0
fi

out="$(python3 - "${reg}" <<'PY'
import json, sys
rows = []
for i, line in enumerate(open(sys.argv[1])):
    line = line.strip()
    if not line:
        continue
    try:
        d = json.loads(line)
    except Exception:
        continue
    rows.append({"index": i, "timestamp": d.get("timestamp"), "repo": d.get("repo"),
                 "path": d.get("path"), "description": d.get("description")})
print(json.dumps({"result": "improvement_candidates", "count": len(rows), "candidates": rows}, indent=2))
PY
)"

if [[ ${json_mode} -eq 1 ]]; then
  aiaast_json_ok "${out}" "list-improvement-candidates.sh" "self-improvement"
else
  printf '%s\n' "${out}"
fi

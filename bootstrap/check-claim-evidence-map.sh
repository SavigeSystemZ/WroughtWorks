#!/usr/bin/env bash
# check-claim-evidence-map.sh — Flag unsupported success claims in handoff/continuity
# surfaces. For each claim pattern in _system/claim-evidence-map.json, a matching line
# must have supporting evidence (a command, result token, path, or SHA) within +/- a
# window of lines; otherwise it is an UNSUPPORTED claim (hallucinated completion).
#
#   check-claim-evidence-map.sh <target-repo> [--strict] [--json] [FILE ...]
# Default mode reports and exits 0 (advisory / doctor warn-tier). --strict exits 1
# if any unsupported claim is found (release gate).
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/aiaast-lib.sh
source "${SCRIPT_DIR}/lib/aiaast-lib.sh"

usage() { echo "usage: $0 <target-repo> [--strict] [--json] [FILE ...]"; }

repo="${1:-}"; shift || true
strict=0; json_mode=0; files=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --strict) strict=1; shift ;;
    --json) json_mode=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) files+=("$1"); shift ;;
  esac
done
[[ -z "${repo}" ]] && { usage >&2; exit 2; }

map="${repo}/_system/claim-evidence-map.json"
if ! aiaast_require_file "${map}"; then
  [[ ${json_mode} -eq 1 ]] && aiaast_json_error "missing_file" "missing: ${map}" "check-claim-evidence-map.sh" "evidence"
  [[ ${json_mode} -eq 0 ]] && echo "claim_evidence_map_failed missing=${map}"
  exit 1
fi

out_file="$(mktemp)"; trap 'rm -f "${out_file}"' EXIT
set +e
python3 - "${repo}" "${map}" "${strict}" "${files[@]+"${files[@]}"}" >"${out_file}" 2>&1 <<'PY'
import json, re, sys
from pathlib import Path

repo = Path(sys.argv[1])
mp = json.loads(Path(sys.argv[2]).read_text())
strict = sys.argv[3] == "1"
explicit = sys.argv[4:]

window = int(mp.get("window", 8))
targets = explicit if explicit else mp.get("default_targets", [])
claims = [(c["id"], re.compile(c["claim"], re.I), [re.compile(e, re.I) for e in c["evidence"]]) for c in mp["claims"]]

unsupported, scanned, total_claims = [], 0, 0
for rel in targets:
    p = repo / rel
    if not p.exists():
        continue
    scanned += 1
    lines = p.read_text(errors="replace").splitlines()
    for i, line in enumerate(lines):
        for cid, cpat, epats in claims:
            if cpat.search(line):
                total_claims += 1
                lo, hi = max(0, i - window), min(len(lines), i + window + 1)
                ctx = "\n".join(lines[lo:hi])
                if not any(e.search(ctx) for e in epats):
                    unsupported.append({"file": rel, "line": i + 1, "claim": cid, "text": line.strip()[:120]})

result = {
    "result": "claim_evidence_map_ok" if not unsupported else "claim_evidence_unsupported",
    "scanned_files": scanned,
    "claims_found": total_claims,
    "unsupported": len(unsupported),
    "items": unsupported[:40],
}
print(json.dumps(result, indent=2))
# 0 ok | 2 advisory (unsupported, non-strict -> doctor warn) | 1 strict fail
sys.exit(1 if (unsupported and strict) else (2 if unsupported else 0))
PY
prc=$?
set -e

payload="$(cat "${out_file}")"
unsupported_count="$(python3 -c "import json;print(json.load(open('${out_file}'))['unsupported'])" 2>/dev/null || echo "?")"

if [[ ${prc} -eq 0 ]]; then
  if [[ ${json_mode} -eq 1 ]]; then aiaast_json_ok "${payload}" "check-claim-evidence-map.sh" "evidence"
  else printf '%s\n' "${payload}"; echo "claim_evidence_map_ok"; fi
  exit 0
elif [[ ${prc} -eq 2 ]]; then
  # Advisory: unsupported claims found but not in --strict mode (doctor warn-tier).
  if [[ ${json_mode} -eq 1 ]]; then aiaast_json_error "claim_evidence_unsupported" "advisory unsupported=${unsupported_count}" "check-claim-evidence-map.sh" "evidence"
  else printf '%s\n' "${payload}"; echo "claim_evidence_map_advisory unsupported=${unsupported_count}"; fi
  exit 2
else
  if [[ ${json_mode} -eq 1 ]]; then aiaast_json_error "claim_evidence_unsupported" "strict unsupported=${unsupported_count}" "check-claim-evidence-map.sh" "evidence"
  else printf '%s\n' "${payload}"; echo "claim_evidence_map_failed unsupported=${unsupported_count}"; fi
  exit 1
fi

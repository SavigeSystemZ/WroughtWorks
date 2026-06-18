#!/usr/bin/env bash
# review-improvement-candidate.sh — Run the promotion gates on a single tagged
# candidate and emit a PROMOTABLE / NOT_PROMOTABLE verdict. See
# _system/SELF_IMPROVEMENT_PROMOTION_REVIEW_PROTOCOL.md.
#
#   review-improvement-candidate.sh <downstream-repo> <index> [--json]
# Exit: 0 promotable | 1 not promotable | 2 error.
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/aiaast-lib.sh
source "${SCRIPT_DIR}/lib/aiaast-lib.sh"

repo="${1:-}"; index="${2:-}"; shift 2 2>/dev/null || true
json_mode=0
[[ "${1:-}" == "--json" ]] && json_mode=1
[[ -z "${repo}" || -z "${index}" ]] && { echo "usage: $0 <downstream-repo> <index> [--json]"; exit 2; }

out_file="$(mktemp)"; trap 'rm -f "${out_file}"' EXIT
set +e
python3 - "${repo}" "${index}" >"${out_file}" 2>&1 <<'PY'
import json, re, sys
from pathlib import Path

repo = Path(sys.argv[1])
index = int(sys.argv[2])
reg = repo / "_system/improvement-candidates.jsonl"
if not reg.exists():
    print(json.dumps({"result": "review_error", "error": f"no candidate registry: {reg}"})); sys.exit(2)

cands = [json.loads(l) for l in reg.read_text().splitlines() if l.strip()]
by_index = None
for i, line in enumerate(reg.read_text().splitlines()):
    if line.strip() and i == index:
        by_index = json.loads(line)
if by_index is None:
    if 0 <= index < len(cands):
        by_index = cands[index]
    else:
        print(json.dumps({"result": "review_error", "error": f"index {index} out of range"})); sys.exit(2)

rel = by_index.get("path", "")
cand_file = repo / rel
reasons = []
if not cand_file.exists():
    reasons.append(f"candidate file missing on disk: {rel}")
    content = ""
else:
    content = cand_file.read_text(errors="replace")

# Self-contained: must live under bootstrap/ or _system/.
if not (rel.startswith("bootstrap/") or rel.startswith("_system/")):
    reasons.append(f"not self-contained: {rel} is outside bootstrap/ and _system/")

# App identity markers from the source repo's namespace.
ns = repo / "_system/app-local-namespace.json"
if ns.exists():
    n = json.loads(ns.read_text())
    for key in ("app_id", "app_slug", "app_name", "repo_root"):
        v = (n.get(key) or "").strip()
        if v and len(v) >= 3 and re.search(re.escape(v), content):
            reasons.append(f"contains app-specific {key}: {v!r}")

# Secrets / paths / network specifics.
patterns = {
    "secret-key": r"(sk-[A-Za-z0-9]{16,}|AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY-----)",
    "credential-assignment": r"(?i)\b(password|api[_-]?key|secret|token)\s*[:=]\s*['\"][^'\"]+['\"]",
    "host-user-path": r"/home/[A-Za-z0-9._-]+/|~/\.MyAppZ/[A-Za-z0-9._-]+",
    "remote-url": r"https?://(?!localhost|127\.0\.0\.1)[A-Za-z0-9.-]+",
    "hardcoded-port": r":\b(?!0+\b)\d{4,5}\b",
}
for label, pat in patterns.items():
    m = re.search(pat, content)
    if m:
        reasons.append(f"contains {label}: {m.group(0)[:48]!r}")

promotable = not reasons
print(json.dumps({
    "result": "PROMOTABLE" if promotable else "NOT_PROMOTABLE",
    "index": index, "path": rel,
    "description": by_index.get("description"),
    "reasons": reasons,
}, indent=2))
sys.exit(0 if promotable else 1)
PY
rc=$?
set -e

payload="$(cat "${out_file}")"
if [[ ${json_mode} -eq 1 ]]; then
  if [[ ${rc} -eq 0 ]]; then aiaast_json_ok "${payload}" "review-improvement-candidate.sh" "self-improvement"
  else aiaast_json_error "not_promotable" "$(tr '\n' ' ' <"${out_file}")" "review-improvement-candidate.sh" "self-improvement"; fi
else
  printf '%s\n' "${payload}"
fi
exit ${rc}

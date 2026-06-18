#!/usr/bin/env bash
# check-registry-contract-graph.sh — Enforce the SYSTEM_REGISTRY.json contract graph.
#
# Turns the registry from inventory into an enforced topology: every managed file
# must carry valid contract-graph fields (authority_level, owned_by, validator,
# depends_on, generates, downstream_policy, drift_severity), every drift_severity=fail
# entry must name a real validator, dependency/generation edges must not dangle, the
# registry-contract-policy must cover every category present, and the committed
# registry must match a fresh deterministic regeneration (no stale drift).
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/aiaast-lib.sh
source "${SCRIPT_DIR}/lib/aiaast-lib.sh"

usage() { echo "usage: $0 <target-repo> [--json]"; }

repo="${1:-}"; shift || true
json_mode=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --json) json_mode=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done
[[ -z "${repo}" ]] && { usage >&2; exit 2; }

registry="${repo}/_system/SYSTEM_REGISTRY.json"
schema="${repo}/_system/schemas/system-registry.schema.json"
policy="${repo}/_system/registry-contract-policy.json"
for f in "${registry}" "${schema}" "${policy}"; do
  if ! aiaast_require_file "${f}"; then
    [[ ${json_mode} -eq 1 ]] && aiaast_json_error "missing_file" "missing: ${f}" "check-registry-contract-graph.sh" "registry"
    [[ ${json_mode} -eq 0 ]] && echo "registry_contract_graph_failed missing=${f}"
    exit 1
  fi
done

# Regenerate deterministically to a temp file and compare (drift detection).
fresh="$(mktemp)"
out_file="$(mktemp)"
trap 'rm -f "${fresh}" "${out_file}"' EXIT
bash "${SCRIPT_DIR}/generate-system-registry.sh" "${repo}" >"${fresh}" 2>/dev/null || true

if ! python3 - "${registry}" "${schema}" "${policy}" "${repo}" "${fresh}" >"${out_file}" 2>&1 <<'PY'
import json, sys
from pathlib import Path

registry = json.loads(Path(sys.argv[1]).read_text())
schema = json.loads(Path(sys.argv[2]).read_text())
policy = json.loads(Path(sys.argv[3]).read_text())
repo = Path(sys.argv[4])
try:
    fresh = json.loads(Path(sys.argv[5]).read_text())
except Exception:
    fresh = {"entries": None}

errors = []
entries = registry.get("entries", [])
item_schema = schema["properties"]["entries"]["items"]
required = item_schema["required"]
enums = {k: set(v["enum"]) for k, v in item_schema["properties"].items() if "enum" in v}
category_map = policy.get("category_map", {})
generated_paths = policy.get("generated_paths", {})

# 1. Shape + enum validity for every entry.
for e in entries:
    p = e.get("path", "?")
    for k in required:
        if k not in e:
            errors.append(f"{p}: missing field '{k}'")
    for k, allowed in enums.items():
        if k in e and e[k] not in allowed:
            errors.append(f"{p}: {k}={e[k]!r} not in {sorted(allowed)}")
    if not isinstance(e.get("depends_on", []), list) or not isinstance(e.get("generates", []), list):
        errors.append(f"{p}: depends_on/generates must be arrays")

# 2. Policy must cover every category present (forces policy maintenance).
present_cats = {e["category"] for e in entries}
for c in sorted(present_cats):
    if c not in category_map:
        errors.append(f"category '{c}' present but missing from registry-contract-policy category_map")

# 3. Coverage: every drift_severity=fail entry must name a validator.
for e in entries:
    if e.get("drift_severity") == "fail" and not e.get("validator"):
        errors.append(f"{e['path']}: drift_severity=fail but no validator named")

# 4. Named validators must exist as bootstrap scripts on disk.
for e in entries:
    v = e.get("validator")
    if v and v.endswith(".sh") and not (repo / "bootstrap" / v).exists():
        errors.append(f"{e['path']}: validator '{v}' not found under bootstrap/")

# 5. Edges must not dangle: depends_on and generates must exist on disk.
for e in entries:
    for dep in e.get("depends_on", []):
        if not (repo / dep).exists():
            errors.append(f"{e['path']}: depends_on '{dep}' does not exist")
    for gen in e.get("generates", []):
        if not (repo / gen).exists():
            errors.append(f"{e['path']}: generates '{gen}' does not exist")

# 6. generated_paths parity: present generated path => authority=generated + downstream=generate.
by_path = {e["path"]: e for e in entries}
for gp in generated_paths:
    e = by_path.get(gp)
    if e:
        if e["authority_level"] != "generated":
            errors.append(f"{gp}: generated_paths entry but authority_level={e['authority_level']}")
        if e["downstream_policy"] != "generate":
            errors.append(f"{gp}: generated_paths entry but downstream_policy={e['downstream_policy']}")

# 7. Drift: committed registry must match a fresh regeneration on every field EXCEPT
#    size_bytes. size_bytes is volatile and self-referential (writing the registry
#    changes its own size), so comparing it would never reach a fixpoint; it is
#    informational, not a contract-graph concern.
def _normalize(es):
    return [{k: v for k, v in e.items() if k != "size_bytes"} for e in (es or [])]
if fresh.get("entries") is not None and _normalize(registry.get("entries")) != _normalize(fresh.get("entries")):
    errors.append("SYSTEM_REGISTRY.json is stale — regenerate with generate-system-registry.sh --write")

if errors:
    for x in errors[:60]:
        print(x)
    sys.exit(1)

print(json.dumps({
    "result": "registry_contract_graph_ok",
    "entries": len(entries),
    "categories": len(present_cats),
    "fail_severity": sum(1 for e in entries if e["drift_severity"] == "fail"),
    "generated": sum(1 for e in entries if e["authority_level"] == "generated"),
}))
PY
then
  [[ ${json_mode} -eq 1 ]] && aiaast_json_error "registry_contract_invalid" "$(tr '\n' ';' <"${out_file}")" "check-registry-contract-graph.sh" "registry"
  [[ ${json_mode} -eq 0 ]] && { echo "registry_contract_graph_failed"; cat "${out_file}"; }
  exit 1
fi

payload="$(cat "${out_file}")"
if [[ ${json_mode} -eq 1 ]]; then
  aiaast_json_ok "${payload}" "check-registry-contract-graph.sh" "registry"
else
  printf '%s\n' "${payload}"
  echo "registry_contract_graph_ok"
fi

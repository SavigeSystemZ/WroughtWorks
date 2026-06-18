#!/usr/bin/env bash
# generate-system-registry.sh — Generate system registry
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=bootstrap/lib/aiaast-lib.sh
source "${SCRIPT_DIR}/lib/aiaast-lib.sh"

usage() {
  cat <<'EOF'
Usage: generate-system-registry.sh [target-repo] [--output <path>] [--write]

Generate a deterministic machine-readable registry of AIAST-managed files.
EOF
}

TARGET_REPO=""
OUTPUT_PATH=""
WRITE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --output)
      OUTPUT_PATH="${2:-}"
      shift 2
      ;;
    --write)
      WRITE=1
      shift
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
  TARGET_REPO="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
fi

if [[ ${WRITE} -eq 1 ]]; then
  aiaast_assert_non_root_for_repo_writes
fi

if [[ ! -d "${TARGET_REPO}" ]]; then
  echo "Target repo does not exist: ${TARGET_REPO}" >&2
  exit 1
fi

if [[ ${WRITE} -eq 1 && -z "${OUTPUT_PATH}" ]]; then
  OUTPUT_PATH="${TARGET_REPO}/_system/SYSTEM_REGISTRY.json"
fi

mapfile -t managed_files < <(aiaast_print_managed_files "${TARGET_REPO}")

python3 - <<'PY' "${TARGET_REPO}" "${OUTPUT_PATH}" "${SCRIPT_DIR}/lib/aiaast-lib.sh" "${WRITE}" "${managed_files[@]}"
import fnmatch
import json
import shlex
import subprocess
import sys
from pathlib import Path

repo_root = Path(sys.argv[1]).resolve()
output_path = sys.argv[2]
lib_path = Path(sys.argv[3]).resolve()
write_enabled = sys.argv[4] == "1"
managed_files = list(sys.argv[5:])

def shell_out(func: str, rel: str) -> str:
    quoted_lib = shlex.quote(str(lib_path))
    cmd = (
        f"source {quoted_lib} >/dev/null 2>&1 && "
        f"{func} {shlex.quote(rel)}"
    )
    result = subprocess.run(
        ["bash", "-lc", cmd],
        cwd=repo_root,
        text=True,
        capture_output=True,
        check=True,
    )
    return result.stdout.strip()

# --- Contract-graph policy (data-driven; see _system/registry-contract-policy.json) ---
policy_path = repo_root / "_system/registry-contract-policy.json"
policy = json.loads(policy_path.read_text()) if policy_path.exists() else {}
category_map = policy.get("category_map", {})
generated_paths = policy.get("generated_paths", {})
generator_outputs = policy.get("generator_outputs", {})
core_validator = policy.get("core_validator", "validate-system.sh")
# Invert generator_outputs: generated artifact -> producing generator script.
output_to_generator = {}
for gen, outs in generator_outputs.items():
    for o in outs:
        output_to_generator[o] = gen

# Scaffold downstream exclusion globs (single source of truth for do-not-copy).
sp_path = repo_root / "_system/scaffold-profiles.json"
scaffold_excludes = []
if sp_path.exists():
    sp = json.loads(sp_path.read_text())
    scaffold_excludes = sp.get("base", {}).get("exclude", [])

def _glob_match(rel: str, g: str) -> bool:
    return fnmatch.fnmatch(rel, g) or fnmatch.fnmatch(rel, g.lstrip("*/"))

def excluded_downstream(rel: str) -> bool:
    # Honor gitignore-style precedence: a later "!"-negated pattern re-includes.
    excluded = False
    for g in scaffold_excludes:
        if g.startswith("!"):
            if _glob_match(rel, g[1:]):
                excluded = False
        elif _glob_match(rel, g):
            excluded = True
    return excluded

def contract_fields(rel: str, category: str) -> dict:
    cm = category_map.get(category, {"authority": "context", "owned_by": "human", "drift_severity": "warn"})
    authority = cm["authority"]
    owned_by = cm["owned_by"]
    drift_severity = cm["drift_severity"]
    validator = None
    generates = list(generator_outputs.get(rel, []))
    depends_on = []
    # Generated artifacts override classification and carry an explicit validator.
    if rel in generated_paths:
        authority, owned_by, drift_severity = "generated", "generator", "fail"
        validator = generated_paths[rel]
        gen = output_to_generator.get(rel)
        if gen:
            depends_on.append(gen)
    elif category == "bootstrap" and (Path(rel).name.startswith("check-") or Path(rel).name.startswith("validate-")):
        validator = Path(rel).name  # a validator validates itself by running
    elif drift_severity == "fail":
        validator = core_validator
    # Downstream policy: generate > category-override (placeholder) > scaffold-exclude > copy.
    if rel in generated_paths:
        downstream_policy = "generate"
    elif "downstream_policy" in cm:
        downstream_policy = cm["downstream_policy"]
    elif excluded_downstream(rel):
        downstream_policy = "do-not-copy"
    else:
        downstream_policy = "copy"
    return {
        "authority_level": authority,
        "owned_by": owned_by,
        "validator": validator,
        "depends_on": sorted(depends_on),
        "generates": sorted(generates),
        "downstream_policy": downstream_policy,
        "drift_severity": drift_severity,
    }

entries = []
for rel in managed_files:
    path = repo_root / rel
    category = shell_out("aiaast_path_category", rel)
    entry = {
        "category": category,
        "kind": "file",
        "path": rel,
        "size_bytes": path.stat().st_size,
    }
    entry.update(contract_fields(rel, category))
    entries.append(entry)

registry = {
    "template_name": "AIAST",
    "template_version": (repo_root / "_system/.template-version").read_text().strip() if (repo_root / "_system/.template-version").exists() else "unknown",
    "system_readme_path": "AI_SYSTEM_README.md" if (repo_root / "AI_SYSTEM_README.md").exists() else "README.md",
    "managed_file_count": len(entries),
    "entries": sorted(entries, key=lambda item: item["path"]),
}

payload = json.dumps(registry, indent=2, sort_keys=True) + "\n"

if write_enabled:
    out = Path(output_path).resolve()
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(payload)
else:
    print(payload, end="")
PY

if [[ ${WRITE} -eq 1 ]]; then
  echo "Wrote system registry to ${OUTPUT_PATH}"
fi

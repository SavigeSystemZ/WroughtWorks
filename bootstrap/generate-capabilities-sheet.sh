#!/usr/bin/env bash
# generate-capabilities-sheet.sh — generate or verify _system/CAPABILITIES.md.
#
# CAPABILITIES.md is a single, comprehensive, human-readable index of EVERY
# capability the AIAST meta-system ships: operator commands, validators,
# generators and other bootstrap tooling, system policies / procedures /
# contracts, machine-enforced policy-contracts, host adapters, slash commands,
# skills, prompt-packs, archetypes, agent roles, scaffold profiles, and the
# hook/orchestration surface — each with a short auto-extracted description.
#
# The sheet is DERIVED from the live system, so it cannot rot: re-running this
# generator re-reads the real files. The operator reviews it anytime to confirm
# the system has exactly the rules/skills/commands they want; the system itself
# reviews it for compliance via `--check` (regenerate + diff), which is wired
# into system-doctor and the factory master lane.
#
# Usage:
#   generate-capabilities-sheet.sh [<repo-root>] --write   # (re)write the sheet
#   generate-capabilities-sheet.sh [<repo-root>] --check   # fail if it drifts
#   generate-capabilities-sheet.sh [<repo-root>]           # print to stdout
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
MODE="stdout"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --write) MODE="write"; shift ;;
    --check) MODE="check"; shift ;;
    -h|--help) sed -n '2,24p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) ROOT="$(cd -- "$1" && pwd)"; shift ;;
  esac
done

OUT_REL="_system/CAPABILITIES.md"
OUT="${ROOT}/${OUT_REL}"

# Operator command catalog from the bash front-door dispatcher (no Go required).
CATALOG_JSON="$(bash "${ROOT}/bootstrap/aiast" list --json 2>/dev/null || echo '{}')"

generate() {
  AIAST_ROOT="${ROOT}" AIAST_CATALOG="${CATALOG_JSON}" python3 - <<'PYEOF'
import os, json, glob, re

root = os.environ["AIAST_ROOT"]
try:
    catalog = json.loads(os.environ.get("AIAST_CATALOG") or "{}")
except Exception:
    catalog = {}

out = []
def w(s=""): out.append(s)

def rel(p):
    return os.path.relpath(p, root)

def humanize(path):
    stem = os.path.splitext(os.path.basename(path))[0]
    s = stem.replace("-", " ").replace("_", " ").strip()
    return s[:1].upper() + s[1:] if s else stem

def first_meaningful_comment(path):
    """Description from the LEADING comment block only (right after the shebang).
    Scripts with no header block return '' (so the sheet honestly shows which
    scripts are undocumented instead of grabbing a random inline comment)."""
    try:
        lines = open(path, encoding="utf-8", errors="replace").read().splitlines()
    except OSError:
        return ""
    block = []
    for i, line in enumerate(lines):
        if i == 0 and line.startswith("#!"):
            continue
        s = line.strip()
        if s.startswith("#"):
            block.append(s.lstrip("#").strip())
        elif s == "":
            if block:
                break          # blank line ends the header block
            continue
        else:
            break              # first real code line: header block (if any) is done
    base = os.path.basename(path)
    stem = os.path.splitext(base)[0]
    for body in block:
        if not body:
            continue
        low = body.lower()
        if low.startswith(("shellcheck", "set ", "usage:", "-*-")) or "source=" in low \
           or body.startswith("SHIM"):
            continue
        for sep in (" — ", " -- ", " - "):
            if sep in body:
                return body.split(sep, 1)[1].strip()
        if body.rstrip(":").lower() in (base.lower(), stem.lower()):
            continue           # skip a bare "name.sh" header line
        return body
    return ""

def md_title(path):
    try:
        with open(path, encoding="utf-8", errors="replace") as f:
            for line in f:
                s = line.strip()
                if s.startswith("# "):
                    return s[2:].strip()
    except OSError:
        pass
    return os.path.splitext(os.path.basename(path))[0].replace("_", " ").title()

def clip(s, n=140):
    s = " ".join((s or "").split())
    return (s[: n - 1] + "…") if len(s) > n else s

def table(rows, headers):
    w("| " + " | ".join(headers) + " |")
    w("|" + "|".join(["---"] * len(headers)) + "|")
    for r in rows:
        w("| " + " | ".join(str(c).replace("|", "\\|") for c in r) + " |")
    w()

def bootstrap_scripts():
    return sorted(glob.glob(os.path.join(root, "bootstrap", "*.sh")))

# ---- header --------------------------------------------------------------
ver = ""
tv = os.path.join(root, "_system", ".template-version")
if os.path.exists(tv):
    ver = open(tv).read().strip()

w("# AIAST Capabilities Sheet")
w()
w("> **GENERATED — do not hand-edit.** Regenerate with "
  "`bootstrap/generate-capabilities-sheet.sh --write`; the system verifies it "
  "with `--check` (system-doctor + master lane). This is the single comprehensive "
  "index of every ability, rule, command, skill, hook, policy, procedure, and "
  "contract the AIAST meta-system provides.")
w()
if ver:
    w(f"Template version: `{ver}`")
    w()

# ---- 1. Operator commands ------------------------------------------------
cmds = catalog.get("commands", []) if isinstance(catalog, dict) else []
w("## 1. Operator commands (`bootstrap/aiast <verb>`)")
w()
w("The operator front-door dispatcher. Run `bootstrap/aiast help` for the live catalog.")
w()
if cmds:
    by_group = {}
    for c in cmds:
        by_group.setdefault(c.get("group", "Other"), []).append(c)
    for g in sorted(by_group):
        w(f"### {g}")
        w()
        rows = [(f"`{c.get('verb','')}`", clip(c.get("summary", "")), f"`{c.get('script','')}`")
                for c in sorted(by_group[g], key=lambda x: x.get("verb", ""))]
        table(rows, ["Verb", "What it does", "Script"])
else:
    w("_(command catalog unavailable)_")
    w()

# ---- 2. Validators -------------------------------------------------------
val = [p for p in bootstrap_scripts()
       if re.match(r"(check|validate|verify|detect|score|lint)-", os.path.basename(p))]
w(f"## 2. Validators & gates ({len(val)})")
w()
w("Read-only checks that enforce the system's invariants (run individually, via "
  "`system-doctor.sh`, or in the factory master lane).")
w()
table([(f"`{os.path.basename(p)}`", clip(first_meaningful_comment(p) or humanize(p)))
       for p in val], ["Validator", "Checks"])

# ---- 3. Generators -------------------------------------------------------
gen = [p for p in bootstrap_scripts() if os.path.basename(p).startswith("generate-")]
w(f"## 3. Generators ({len(gen)})")
w()
w("Produce the managed/derived surfaces (regenerated on install + update).")
w()
table([(f"`{os.path.basename(p)}`", clip(first_meaningful_comment(p) or humanize(p)))
       for p in gen], ["Generator", "Produces"])

# ---- 4. Lifecycle / install / scaffold -----------------------------------
life_pat = ("init-", "install-", "uninstall-", "scaffold-", "update-", "render-",
            "build-", "bootstrap")
life = [p for p in bootstrap_scripts()
        if os.path.basename(p).startswith(life_pat)
        and p not in val and p not in gen]
w(f"## 4. Lifecycle, install & scaffold tooling ({len(life)})")
w()
table([(f"`{os.path.basename(p)}`", clip(first_meaningful_comment(p) or humanize(p)))
       for p in life], ["Script", "Role"])

# ---- 5. Fleet / sync / orchestration scripts -----------------------------
fleet_pat = ("run-", "sync-", "reconcile-", "migrate-", "aggregate-", "emit-",
             "repair-", "resume-", "write-", "stamp-", "reap-", "clear-", "track-",
             "discover-", "apply-", "propose-", "fill-", "compact-", "patch-",
             "install-missing", "agent-", "git-")
done = set(val) | set(gen) | set(life)
fleet = [p for p in bootstrap_scripts()
         if os.path.basename(p).startswith(fleet_pat) and p not in done]
w(f"## 5. Operations, fleet, sync & agent tooling ({len(fleet)})")
w()
table([(f"`{os.path.basename(p)}`", clip(first_meaningful_comment(p) or humanize(p)))
       for p in fleet], ["Script", "Role"])

# ---- 6. Other bootstrap utilities ----------------------------------------
done |= set(fleet)
other = [p for p in bootstrap_scripts() if p not in done]
if other:
    w(f"## 6. Other bootstrap utilities ({len(other)})")
    w()
    table([(f"`{os.path.basename(p)}`", clip(first_meaningful_comment(p) or humanize(p)))
           for p in other], ["Script", "Role"])

# ---- 7. System policies, procedures & contracts --------------------------
sysmd = sorted(p for p in glob.glob(os.path.join(root, "_system", "*.md"))
               if os.path.basename(p) != "CAPABILITIES.md")  # never list the sheet itself
def classify_doc(name):
    u = name.upper()
    for tok, label in (("POLICY", "Policies"), ("PROTOCOL", "Protocols"),
                       ("CONTRACT", "Contracts"), ("STANDARD", "Standards"),
                       ("GATE", "Gates"), ("GUIDE", "Guides"),
                       ("MATRIX", "Matrices & catalogs"), ("CATALOG", "Matrices & catalogs"),
                       ("INDEX", "Indexes"), ("PROFILE", "Profiles"),
                       ("RULES", "Rules"), ("PROMPT", "Prompts")):
        if tok in u:
            return label
    return "Other system docs"
buckets = {}
for p in sysmd:
    buckets.setdefault(classify_doc(os.path.basename(p)), []).append(p)
w(f"## 7. System rules, policies, procedures & contracts ({len(sysmd)})")
w()
w("The governing documents under `_system/` (the rules and procedures that define "
  "how the system runs). Grouped by kind; description is each file's title.")
w()
for b in sorted(buckets):
    w(f"### {b} ({len(buckets[b])})")
    w()
    table([(f"`_system/{os.path.basename(p)}`", clip(md_title(p)))
           for p in buckets[b]], ["Document", "Title / purpose"])

# ---- 8. Machine-enforced policy-contracts --------------------------------
pcs = sorted(glob.glob(os.path.join(root, "_system", "policy-contracts", "*.json")))
if pcs:
    w(f"## 8. Machine-enforced policy-contracts ({len(pcs)})")
    w()
    w("JSON contracts asserted by `check-policy-contracts.sh` — invariants the "
      "system actively refuses to violate.")
    w()
    rows = []
    for p in pcs:
        try:
            d = json.load(open(p))
            rows.append((f"`{os.path.basename(p)}`", clip(d.get("description", ""))))
        except Exception:
            rows.append((f"`{os.path.basename(p)}`", ""))
    table(rows, ["Contract", "Asserts"])

# ---- 9. Host adapters ----------------------------------------------------
adapters = [("CLAUDE.md", "Claude Code"), ("CODEX.md", "OpenAI Codex"),
            ("GEMINI.md", "Gemini CLI"), ("COPILOT.md", "GitHub Copilot"),
            ("CURSOR.md", "Cursor"), ("WINDSURF.md", "Windsurf"),
            ("AIDER.md", "Aider"), ("ANTIGRAVITY.md", "Antigravity"),
            ("GROK.md", "Grok"),
            ("DEEPSEEK.md", "DeepSeek"), ("PEARAI.md", "PearAI"),
            ("LOCAL_MODELS.md", "Local models")]
present = [(f, n) for f, n in adapters if os.path.exists(os.path.join(root, f))]
w(f"## 9. Host / tool adapters ({len(present)})")
w()
w("Per-agent entry-point files (generated from the host-adapter manifest) that "
  "load the same canonical repo contract into each coding agent.")
w()
table([(f"`{f}`", n) for f, n in present], ["Adapter file", "Agent / tool"])

# ---- 10. Slash commands --------------------------------------------------
sc = sorted(glob.glob(os.path.join(root, ".cursor", "commands", "*.md")))
if sc:
    w(f"## 10. Slash commands ({len(sc)})")
    w()
    table([(f"`/{os.path.splitext(os.path.basename(p))[0]}`", clip(md_title(p)))
           for p in sc], ["Command", "Purpose"])

# ---- 11. Skills ----------------------------------------------------------
sk = sorted(glob.glob(os.path.join(root, ".cursor", "skills", "*", "SKILL.md")))
if sk:
    w(f"## 11. Skills ({len(sk)})")
    w()
    rows = []
    for p in sk:
        name = os.path.basename(os.path.dirname(p))
        desc = ""
        try:
            txt = open(p, encoding="utf-8", errors="replace").read()
            m = re.search(r"^description:\s*(.+)$", txt, re.M)
            desc = m.group(1).strip() if m else md_title(p)
        except OSError:
            pass
        rows.append((f"`{name}`", clip(desc)))
    table(rows, ["Skill", "Description"])

# ---- 12. Prompt-packs ----------------------------------------------------
pp = sorted(glob.glob(os.path.join(root, "_system", "prompt-packs", "*.md")))
if pp:
    w(f"## 12. Prompt-packs ({len(pp)})")
    w()
    table([(f"`{os.path.basename(p)}`", clip(md_title(p))) for p in pp],
          ["Prompt-pack", "Focus"])

# ---- 13. Archetypes ------------------------------------------------------
arch = sorted(glob.glob(os.path.join(root, "_system", "archetypes", "*.md")))
if arch:
    w(f"## 13. App archetypes ({len(arch)})")
    w()
    table([(f"`{os.path.splitext(os.path.basename(p))[0]}`", clip(md_title(p)))
           for p in arch], ["Archetype", "Title"])

# ---- 14. Agent roles -----------------------------------------------------
rc = os.path.join(root, "_system", "AGENT_ROLE_CATALOG.md")
if os.path.exists(rc):
    roles = []
    cur = None
    for line in open(rc, encoding="utf-8", errors="replace"):
        s = line.strip()
        if s.startswith("### "):
            cur = s[4:].strip()
        elif cur and s.startswith("- Purpose:"):
            roles.append((cur, clip(s.split(":", 1)[1].strip())))
            cur = None
        elif cur and s.lower().startswith("> **not available"):
            roles.append((cur, "DEFERRED — not active in the lean-hybrid configuration"))
            cur = None
    if roles:
        w(f"## 14. Agent roles ({len(roles)})")
        w()
        table([(f"**{n}**", d) for n, d in roles], ["Role", "Purpose"])

# ---- 15. Scaffold profiles -----------------------------------------------
sp = os.path.join(root, "_system", "scaffold-profiles.json")
if os.path.exists(sp):
    try:
        d = json.load(open(sp))
        profs = d.get("profiles", [])
        if profs:
            w(f"## 15. Scaffold profiles ({len(profs)})")
            w()
            w(f"Install footprints (default: `{d.get('default_profile','')}`).")
            w()
            table([(f"`{p.get('id','')}`",
                    "maintainer-only" if p.get("maintainer_only") else "installable",
                    clip(p.get("notes", ""))) for p in profs],
                  ["Profile", "Kind", "Notes"])
    except Exception:
        pass

# ---- 16. Hooks & orchestration ------------------------------------------
hk = os.path.join(root, "_system", "HOOK_AND_ORCHESTRATION_INDEX.md")
if os.path.exists(hk):
    w("## 16. Hooks & orchestration")
    w()
    w("Automation hooks and orchestration surfaces are catalogued in "
      "`_system/HOOK_AND_ORCHESTRATION_INDEX.md`. Section headings:")
    w()
    heads = [l.strip()[3:].strip() for l in open(hk, encoding="utf-8", errors="replace")
             if l.strip().startswith("## ")]
    for h in heads:
        w(f"- {h}")
    w()

print("\n".join(out).rstrip() + "\n", end="")
PYEOF
}

case "${MODE}" in
  write)
    generate > "${OUT}"
    echo "capabilities_sheet_written path=${OUT_REL} bytes=$(wc -c < "${OUT}")"
    ;;
  check)
    tmp="$(mktemp)"
    trap 'rm -f "${tmp}"' EXIT
    generate > "${tmp}"
    if [[ ! -f "${OUT}" ]]; then
      echo "capabilities_sheet_missing path=${OUT_REL} — run --write" >&2
      exit 1
    fi
    if diff -q "${tmp}" "${OUT}" >/dev/null 2>&1; then
      echo "capabilities_sheet_current path=${OUT_REL}"
    else
      echo "capabilities_sheet_drift path=${OUT_REL} — the sheet no longer matches the live system; run --write" >&2
      diff -u "${OUT}" "${tmp}" | head -40 >&2 || true
      exit 1
    fi
    ;;
  *)
    generate
    ;;
esac

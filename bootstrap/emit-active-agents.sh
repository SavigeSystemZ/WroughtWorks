#!/usr/bin/env bash
# emit-active-agents.sh — show the live agent lock/lease roster for a repo: which
# agent holds which scope, when the lease expires, and whether it is stale (a
# crashed holder whose lock is reclaimable). This is the "who is running now"
# view for operating with many concurrent agents. Read-only; never fails.
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

REPO=""
JSON=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --json) JSON=1; shift ;;
    -h|--help) echo "Usage: emit-active-agents.sh [target-repo] [--json]"; exit 0 ;;
    *) REPO="$1"; shift ;;
  esac
done
if [[ -z "${REPO}" ]]; then
  REPO="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
fi
LOCKS_DIR="${REPO}/_system/agent-state/locks"

AIAAST_LOCKS_DIR="${LOCKS_DIR}" AIAAST_JSON="${JSON}" python3 <<'PY'
import os, json, glob
from datetime import datetime, timezone

locks_dir = os.environ["AIAAST_LOCKS_DIR"]
as_json = os.environ["AIAAST_JSON"] == "1"
now = datetime.now(timezone.utc)
rows = []
for p in sorted(glob.glob(os.path.join(locks_dir, "*.lock.json"))):
    try:
        d = json.load(open(p))
    except Exception:
        d = {}
    exp_s = d.get("lease_expires_at", "")
    stale = True
    try:
        exp = datetime.strptime(exp_s, "%Y-%m-%dT%H:%M:%SZ").replace(tzinfo=timezone.utc)
        stale = exp < now
    except Exception:
        pass
    rows.append({
        "scope": d.get("scope", os.path.basename(p).replace(".lock.json", "")),
        "owner_agent_id": d.get("owner_agent_id", "?"),
        "owner_role": d.get("owner_role", ""),
        "lease_expires_at": exp_s,
        "stale": stale,
    })

active = [r for r in rows if not r["stale"]]
if as_json:
    print(json.dumps({"ok": True, "result": "active_agents",
                      "active": len(active), "stale": len(rows) - len(active),
                      "agents": rows}, indent=2))
else:
    if not rows:
        print("active_agents_ok active=0 stale=0 (no agent leases held)")
    else:
        for r in rows:
            flag = "STALE" if r["stale"] else "live "
            print(f"  [{flag}] scope={r['scope']:<22} agent={r['owner_agent_id']:<22} "
                  f"expires={r['lease_expires_at']}")
        print(f"active_agents_ok active={len(active)} stale={len(rows) - len(active)}")
PY

#!/usr/bin/env bash
# aiaast-lock.sh — atomic lock primitives (S22a WS2)
# S22b WS6: module of the aiaast-lib.sh facade (sourced via aiaast-lib.sh;
# same path + function names as before — fully back-compatible).

# ---- Atomic lock primitives (S22a WS2) ------------------------------------
# Single-writer locking that is race-free under real concurrency. The lock
# identity is a guard DIRECTORY (<locks_dir>/<scope_key>.lock.d): `mkdir` is
# atomic on POSIX filesystems, so exactly one of N racing acquirers wins —
# unlike the legacy check-then-create (`[[ -f ]]` then write) pattern, which
# has a TOCTOU window. Authoritative metadata stays at the legacy path
# <locks_dir>/<scope_key>.lock.json (a regular file) so every existing
# reader (check-agent-locks.sh, agent-unlock.sh, agent-reclaim-lock.sh)
# keeps working unchanged. Stale reclaim is lease-aware: an expired
# `lease_expires_at` in the json makes the lock reclaimable (this also
# fixes a latent bug where expired leases blocked acquisition forever);
# when no json is present, a guard-dir mtime older than the fallback TTL
# is treated as stale.

aiaast_lock_guarddir() { printf '%s/%s.lock.d\n' "$1" "$2"; }
aiaast_lock_jsonpath() { printf '%s/%s.lock.json\n' "$1" "$2"; }

# aiaast_lock_is_stale <locks_dir> <scope_key> [fallback_ttl_seconds]
# rc 0 = stale/reclaimable (or no guard at all), rc 1 = live.
aiaast_lock_is_stale() {
  local locks_dir="$1"
  local scope_key="$2"
  local fallback_ttl="${3:-300}"
  local guard json
  guard="$(aiaast_lock_guarddir "${locks_dir}" "${scope_key}")"
  json="$(aiaast_lock_jsonpath "${locks_dir}" "${scope_key}")"
  [[ -d "${guard}" ]] || return 0
  if [[ -f "${json}" ]]; then
    if python3 - "${json}" <<'PY'
import json, sys
from datetime import datetime, timezone
try:
    d = json.load(open(sys.argv[1]))
    exp = datetime.strptime(d["lease_expires_at"], "%Y-%m-%dT%H:%M:%SZ").replace(tzinfo=timezone.utc)
except Exception:
    raise SystemExit(0)  # unparseable / missing lease -> treat as stale
raise SystemExit(0 if exp < datetime.now(timezone.utc) else 1)
PY
    then
      return 0
    fi
    return 1
  fi
  local mtime age
  mtime="$(stat -c %Y "${guard}" 2>/dev/null || echo 0)"
  age=$(( $(date +%s) - mtime ))
  [[ ${age} -gt ${fallback_ttl} ]]
}

# aiaast_lock_acquire <locks_dir> <scope_key> [fallback_ttl_seconds]
# rc 0 = acquired (guard dir now owned by caller; caller writes the json),
# rc 1 = held by a live lock.
aiaast_lock_acquire() {
  local locks_dir="$1"
  local scope_key="$2"
  local fallback_ttl="${3:-300}"
  local guard json
  guard="$(aiaast_lock_guarddir "${locks_dir}" "${scope_key}")"
  json="$(aiaast_lock_jsonpath "${locks_dir}" "${scope_key}")"
  mkdir -p "${locks_dir}"
  if mkdir "${guard}" 2>/dev/null; then
    return 0
  fi
  if aiaast_lock_is_stale "${locks_dir}" "${scope_key}" "${fallback_ttl}"; then
    rm -rf "${guard}" 2>/dev/null || true
    rm -f "${json}" 2>/dev/null || true
    if mkdir "${guard}" 2>/dev/null; then
      return 0
    fi
  fi
  return 1
}

# aiaast_lock_release <locks_dir> <scope_key>
aiaast_lock_release() {
  local locks_dir="$1"
  local scope_key="$2"
  rm -rf "$(aiaast_lock_guarddir "${locks_dir}" "${scope_key}")" 2>/dev/null || true
  rm -f "$(aiaast_lock_jsonpath "${locks_dir}" "${scope_key}")" 2>/dev/null || true
}

# aiaast_with_lock <repo> <scope> <ttl_minutes> -- <cmd> [args...]
#
# Serialize <cmd> against any other agent that touches the same <scope> in
# <repo>, using the atomic guard-dir primitives above. This is how the system
# stays safe with MANY agents running concurrently: every shared-state write
# (managed-surface regen, integrity manifest, tool-memory stamp, update) runs
# inside the appropriate scope lock instead of racing.
#
# RE-ENTRANT within one process subtree via the exported AIAAST_HELD_LOCKS set:
# a sequence may hold "managed-surfaces" while the individual generators it
# spawns also request it — the inner requests become no-op pass-throughs and
# only the outermost holder acquires/releases (no self-deadlock, sequence stays
# atomic). A holder that dies leaves a lease that expires, so the lock is
# reclaimed (lease-aware staleness) and never blocks forever.
#
# rc = <cmd>'s exit status; 75 if the lock could not be acquired within the wait
# budget (AIAAST_LOCK_WAIT_TRIES iterations * 0.2s, default ~180s); 70 if the
# lease metadata could not be written.
aiaast_with_lock() {
  local repo="$1" scope="$2" ttl="${3:-10}"
  shift 3
  [[ "${1:-}" == "--" ]] && shift
  local dir scope_key key rc=0
  # Escape hatch (CI negative tests / single-agent fast paths): run without locking.
  if [[ "${AIAST_LOCK_DISABLE:-0}" == "1" ]]; then
    "$@" || rc=$?
    return ${rc}
  fi
  dir="${repo}/_system/agent-state/locks"
  scope_key="$(aiaast_sanitize_scope_key "${scope}")"
  key="<${dir}|${scope_key}>"
  # Already held by this process subtree -> re-entrant pass-through.
  case "${AIAAST_HELD_LOCKS:-}" in
    *"${key}"*) "$@" || rc=$?; return ${rc} ;;
  esac
  mkdir -p "${dir}"
  local tries="${AIAAST_LOCK_WAIT_TRIES:-900}"
  until aiaast_lock_acquire "${dir}" "${scope_key}" "$(( ttl * 60 ))"; do
    tries=$(( tries - 1 ))
    if [[ ${tries} -le 0 ]]; then
      printf 'aiaast_with_lock: could not acquire lock scope=%s in %s (held by another agent)\n' \
        "${scope}" "${repo}" >&2
      return 75
    fi
    sleep 0.2
  done
  local now exp
  now="$(aiaast_iso_utc_now)"
  exp="$(date -u -d "+${ttl} minutes" +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || echo "${now}")"
  if ! python3 - "${dir}/${scope_key}.lock.json" "${scope}" "${AIAAST_AGENT_ID:-$$}" "${now}" "${exp}" <<'PY'
import json, sys
path, scope, agent, start, exp = sys.argv[1:]
with open(path, "w", encoding="utf-8") as f:
    json.dump({"scope": scope, "owner_agent_id": agent, "owner_role": "with-lock",
               "lease_started_at": start, "lease_expires_at": exp,
               "notes": "aiaast_with_lock"}, f, indent=2, sort_keys=True)
    f.write("\n")
PY
  then
    aiaast_lock_release "${dir}" "${scope_key}"
    printf 'aiaast_with_lock: failed to write lease for scope=%s\n' "${scope}" >&2
    return 70
  fi
  local prev="${AIAAST_HELD_LOCKS:-}"
  export AIAAST_HELD_LOCKS="${prev}${key}"
  "$@" || rc=$?
  export AIAAST_HELD_LOCKS="${prev}"
  aiaast_lock_release "${dir}" "${scope_key}"
  return ${rc}
}

#!/usr/bin/env bash
# heal-system.sh — Heal system
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

exec bash "${SCRIPT_DIR}/system-doctor.sh" "$@" --heal

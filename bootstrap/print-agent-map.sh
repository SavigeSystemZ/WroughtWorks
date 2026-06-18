#!/usr/bin/env bash
# print-agent-map.sh — Print agent map
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"

cat "${ROOT_DIR}/_system/AGENT_DISCOVERY_MATRIX.md"

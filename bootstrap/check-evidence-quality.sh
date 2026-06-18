#!/usr/bin/env bash
# check-evidence-quality.sh — evidence-quality / proof-artifact validator.
#
# Thin entry point: the implementation lives in the aiast-cli validator
# accelerator (zero-dependency Go), built on demand by the bootstrap/aiast-cli
# launcher. This preserves the stable script name/interface used across the
# system (doctor, factory gates, downstream tooling, docs). The launcher applies
# the lean-hybrid graceful-skip contract for check-* validators when no Go
# toolchain is available (set AIAST_REQUIRE_CLI=1 to require the binary).
set -euo pipefail
_SHIM_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
exec "${_SHIM_DIR}/aiast-cli" check-evidence-quality "$@"

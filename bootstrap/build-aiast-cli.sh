#!/usr/bin/env bash
# build-aiast-cli.sh — explicitly (re)build the lean Go validator accelerator.
#
# The aiast-cli binary is an optional accelerator for the validation layer; the
# whole meta-system also works without it. This compiles src/aiast-cli into the
# gitignored build-artifact path bootstrap/.bin/aiast-cli. The launcher
# bootstrap/aiast-cli also performs this build on demand, so running this script
# is only needed when you want to pre-build or verify a clean compile.
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="${SCRIPT_DIR}/../src/aiast-cli"
BIN_DIR="${SCRIPT_DIR}/.bin"
BIN="${BIN_DIR}/aiast-cli"

if ! command -v go >/dev/null 2>&1; then
  echo "build-aiast-cli: Go toolchain not found; cannot build accelerator." >&2
  exit 69
fi
if [[ ! -d "${SRC_DIR}" ]]; then
  echo "build-aiast-cli: source dir not found: ${SRC_DIR}" >&2
  exit 1
fi

mkdir -p "${BIN_DIR}"
( cd "${SRC_DIR}" && go build -o "${BIN}" ./cmd/aiast )
echo "aiast_cli_built path=${BIN} size=$(du -h "${BIN}" | cut -f1)"

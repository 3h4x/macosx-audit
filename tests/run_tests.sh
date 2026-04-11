#!/usr/bin/env bash
set -euo pipefail

if ! command -v bats &>/dev/null; then
  echo "bats not found. Install with: brew install bats-core"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bats "$SCRIPT_DIR"/*.bats "$@"

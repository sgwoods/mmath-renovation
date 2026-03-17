#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
PYTHON_BIN=${PYTHON_BIN:-python3}
BASELINE_SCRIPT="$REPO_ROOT/experiments/hanoi-baselines/hanoi_search_baselines.py"

"$PYTHON_BIN" "$BASELINE_SCRIPT" "$@"

#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
OUT="$ROOT/analysis/hanoi-baselines/hanoi4-optimal-projection.md"

python3 "$ROOT/experiments/hanoi-baselines/hanoi_projection_report.py" --output "$OUT"
printf 'Wrote %s\n' "$OUT"

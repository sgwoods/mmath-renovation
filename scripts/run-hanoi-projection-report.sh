#!/bin/sh
set -eu

ROOT="/Users/stevenwoods/mmath-renovation"
OUT="$ROOT/analysis/hanoi-baselines/hanoi4-optimal-projection.md"

python3 "$ROOT/experiments/hanoi-baselines/hanoi_projection_report.py" --output "$OUT"
printf 'Wrote %s\n' "$OUT"

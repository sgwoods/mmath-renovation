#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
RUN_ONE="$SCRIPT_DIR/github-actions-run-experiment.sh"

usage() {
  cat <<EOF >&2
Usage:
  sh scripts/github-actions-run-experiment-set.sh PRESET OUT_DIR

Presets:
  status-snapshot
  hanoi4-focused
  publication-surface
EOF
  exit 2
}

PRESET=${1:-}
OUT_DIR=${2:-}

[ -n "$PRESET" ] || usage
[ -n "$OUT_DIR" ] || usage

mkdir -p "$OUT_DIR"

run_item() {
  slug=$1
  kind=$2
  name=$3
  item_dir="$OUT_DIR/$slug"
  sh "$RUN_ONE" "$kind" "$name" "$item_dir"
}

case "$PRESET" in
  status-snapshot)
    run_item "status" status -
    run_item "benchmark-status" report benchmark-status
    ;;
  hanoi4-focused)
    run_item "hanoi4-solve-candidates" report hanoi4-solve-candidates
    run_item "hanoi4-historical" report hanoi4-historical
    run_item "hanoi4-score-sensitivity" report hanoi4-score-sensitivity
    ;;
  publication-surface)
    run_item "hanoi2-historical" report hanoi2-historical
    run_item "hanoi3-historical" report hanoi3-historical
    run_item "benchmark-status" report benchmark-status
    ;;
  *)
    echo "Unknown preset: $PRESET" >&2
    usage
    ;;
esac

summary_file="$OUT_DIR/summary.md"
{
  echo "# Remote experiment set"
  echo
  echo "- Preset: \`$PRESET\`"
  echo
  echo "Included outputs:"
  find "$OUT_DIR" -mindepth 1 -maxdepth 1 -type d | sort | while IFS= read -r dir; do
    echo "- \`$(basename "$dir")\`"
  done
} >"$summary_file"

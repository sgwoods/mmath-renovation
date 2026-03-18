#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

extract_value() {
  key=$1
  file=$2
  sed -n "s/^$key: //p" "$file" | head -n 1
}

count_outcome() {
  cohort=$1
  outcome=$2
  file=$3
  awk -F'|' -v cohort="$cohort" -v outcome="$outcome" '
    $2 ~ (" " cohort " ") && $8 ~ (" " outcome " ") { count++ }
    END { print count + 0 }
  ' "$file"
}

max_generated_for_outcome() {
  cohort=$1
  outcome=$2
  file=$3
  awk -F'|' -v cohort="$cohort" -v outcome="$outcome" '
    $2 ~ (" " cohort " ") && $8 ~ (" " outcome " ") {
      value = $10 + 0
      if (value > max) max = value
    }
    END { print max + 0 }
  ' "$file"
}

tmp_ab=$(mktemp "${TMPDIR:-/tmp}/h4-replay-ab.XXXXXX")
tmp_tw=$(mktemp "${TMPDIR:-/tmp}/h4-replay-tw.XXXXXX")
trap 'rm -f "$tmp_ab" "$tmp_tw"' EXIT INT TERM

COHORT_LIMIT=5 \
SOURCE_EXPAND_BOUND=10000 \
SOURCE_GENERATE_BOUND=40000 \
SOURCE_OPEN_BOUND=40000 \
REPLAY_EXPAND_BOUND=1000 \
REPLAY_GENERATE_BOUND=5000 \
REPLAY_OPEN_BOUND=5000 \
sh "$SCRIPT_DIR/replay-hanoi4-frontier-sbcl.sh" >"$tmp_ab"

PLANNER_MODE=tweak \
HISTORICAL_MODE=nil \
HIERARCHY=critical-list-1 \
MP_MODE=nil \
MP_WEAK_MODE=nec \
LEFT_WEDGE_MODE=nil \
ABSTRACT_GOAL_MODE=nil \
REPLAY_PLANNER_MODE=tweak \
REPLAY_MP_MODE=nil \
REPLAY_MP_WEAK_MODE=nec \
REPLAY_ABSTRACT_GOAL_MODE=nil \
COHORT_LIMIT=5 \
SOURCE_EXPAND_BOUND=10000 \
SOURCE_GENERATE_BOUND=40000 \
SOURCE_OPEN_BOUND=40000 \
REPLAY_EXPAND_BOUND=1000 \
REPLAY_GENERATE_BOUND=5000 \
REPLAY_OPEN_BOUND=5000 \
sh "$SCRIPT_DIR/replay-hanoi4-frontier-sbcl.sh" >"$tmp_tw"

ab_dir=$(extract_value "REPLAY-DIR" "$tmp_ab")
tw_dir=$(extract_value "REPLAY-DIR" "$tmp_tw")
ab_report="${ab_dir%/}/report.md"
tw_report="${tw_dir%/}/report.md"

ab_priority_live=$(count_outcome "PRIORITY" "EXPAND-LIMIT-EXCEEDED" "$ab_report")
ab_priority_dead=$(count_outcome "PRIORITY" "OPEN-EXHAUSTED" "$ab_report")
ab_closure_live=$(count_outcome "CLOSURE" "EXPAND-LIMIT-EXCEEDED" "$ab_report")
ab_closure_dead=$(count_outcome "CLOSURE" "OPEN-EXHAUSTED" "$ab_report")
tw_priority_live=$(count_outcome "PRIORITY" "EXPAND-LIMIT-EXCEEDED" "$tw_report")
tw_priority_dead=$(count_outcome "PRIORITY" "OPEN-EXHAUSTED" "$tw_report")
tw_closure_live=$(count_outcome "CLOSURE" "EXPAND-LIMIT-EXCEEDED" "$tw_report")
tw_closure_dead=$(count_outcome "CLOSURE" "OPEN-EXHAUSTED" "$tw_report")

ab_priority_best_generated=$(max_generated_for_outcome "PRIORITY" "EXPAND-LIMIT-EXCEEDED" "$ab_report")
ab_closure_best_generated=$(max_generated_for_outcome "CLOSURE" "EXPAND-LIMIT-EXCEEDED" "$ab_report")
tw_priority_best_generated=$(max_generated_for_outcome "PRIORITY" "EXPAND-LIMIT-EXCEEDED" "$tw_report")
tw_closure_best_generated=$(max_generated_for_outcome "CLOSURE" "EXPAND-LIMIT-EXCEEDED" "$tw_report")

cat <<EOF
# Hanoi-4 Frontier Replay Comparison

This report reruns the frozen-frontier replay experiment with:

- source frontier bound: \`10000\` expansions
- replay cohort size: \`5\`
- replay policy: same planner mode, BFS, \`user-defined\` zero heuristic, left-wedge off
- replay bound: \`1000\` expansions

## AbTweak Current Best Path

- Source configuration: \`abtweak + isbm + weak-POS + left-wedge\`
- Source frontier report: [$ab_report]($ab_report)
- Priority cohort still live at replay bound: \`$ab_priority_live / 5\`
- Priority cohort dead-ended early: \`$ab_priority_dead / 5\`
- Closure cohort still live at replay bound: \`$ab_closure_live / 5\`
- Closure cohort dead-ended early: \`$ab_closure_dead / 5\`
- Best live priority replay generated: \`$ab_priority_best_generated\`
- Best live closure replay generated: \`$ab_closure_best_generated\`

## Tweak Baseline

- Source configuration: \`tweak\`
- Source frontier report: [$tw_report]($tw_report)
- Priority cohort still live at replay bound: \`$tw_priority_live / 5\`
- Priority cohort dead-ended early: \`$tw_priority_dead / 5\`
- Closure cohort still live at replay bound: \`$tw_closure_live / 5\`
- Closure cohort dead-ended early: \`$tw_closure_dead / 5\`
- Best live priority replay generated: \`$tw_priority_best_generated\`
- Best live closure replay generated: \`$tw_closure_best_generated\`

## Interpretation

- In the current restored \`tweak\` path, all sampled frontier nodes remain search-live under neutral replay.
- In the current restored \`abtweak\` path, most sampled frontier nodes collapse quickly under the same replay policy.
- The healthiest sampled \`abtweak\` node comes from the closure-oriented cohort rather than the highest-ranked cohort.
- That makes the current divergence look more like a frontier-quality / ranking problem than a generic inability to generate valid \`hanoi-4\` states.
EOF

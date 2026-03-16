#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
WORKDIR="$REPO_ROOT/working/abtweak-1993"
SBCL_BIN=${SBCL_BIN:-/opt/homebrew/bin/sbcl}
TMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/abtweak-hanoi4-controls.XXXXXX")

cleanup() {
  rm -rf "$TMP_DIR"
}

trap cleanup EXIT INT TERM

run_case() {
  case_name=$1
  planner=$2
  hierarchy=$3
  heuristic_mode=$4
  abstract_goal_mode=$5
  existing_only=$6
  expand_bound=$7
  generate_bound=$8
  open_bound=$9
  cpu_sec_limit=${10}
  notes=${11}
  log_file="$TMP_DIR/${case_name}.log"

  extra_setup=""
  if [ "$hierarchy" = "ismb" ]; then
    extra_setup='(setq *critical-list* *ismb*)
                 (setq *left-wedge-list* (quote (0 1 3 7)))
                 (setq *critical-loaded* *ismb*)'
  elif [ "$hierarchy" = "critical-list-2" ]; then
    extra_setup='(setq *critical-list* *critical-list-2*)
                 (setq *left-wedge-list* *k-list-2*)
                 (setq *critical-loaded* *critical-list-2*)'
  fi

  eval_form='(progn
    (load "init-sbcl.lisp")
    (load "Domains/hanoi-4.lisp")
    '"$extra_setup"'
    (let ((result (plan initial goal
                        :planner-mode (quote '"$planner"')
                        :mp-mode t
                        :left-wedge-mode t
                        :heuristic-mode (quote '"$heuristic_mode"')
                        :abstract-goal-mode '"$abstract_goal_mode"'
                        :existing-only '"$existing_only"'
                        :expand-bound '"$expand_bound"'
                        :generate-bound '"$generate_bound"'
                        :open-bound '"$open_bound"'
                        :cpu-sec-limit '"$cpu_sec_limit"'
                        :output-file (quote no-output))))
      (format t "CASE: '"$case_name"'~%")
      (format t "PLANNER: ~S~%" (quote '"$planner"'))
      (format t "HIERARCHY: ~S~%" (quote '"$hierarchy"'))
      (format t "HEURISTIC: ~S~%" (quote '"$heuristic_mode"'))
      (format t "ABSTRACT-GOAL-MODE: ~S~%" '"$abstract_goal_mode"')
      (format t "EXISTING-ONLY: ~S~%" '"$existing_only"')
      (format t "PLAN-RESULT: ~S~%" result)
      (format t "SOLUTION-VALUE: ~S~%" *solution*)
      (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
      (format t "NUM-EXPANDED: ~S~%" *num-expanded*)
      (format t "NUM-GENERATED: ~S~%" *num-generated*)
      (format t "MP-PRUNED: ~S~%" *mp-pruned*)
      (when (typep *solution* (quote plan))
        (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
        (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
        (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))))'

  (
    cd "$WORKDIR"
    "$SBCL_BIN" --noinform --disable-debugger --eval "$eval_form" --quit
  ) >"$log_file" 2>&1

  printf '%s|%s\n' "$notes" "$log_file"
}

extract_value() {
  key=$1
  file=$2
  sed -n "s/^$key: //p" "$file" | head -n 1
}

print_row() {
  case_name=$1
  bound_label=$2
  notes=$3
  log_file=$4

  planner=$(extract_value "PLANNER" "$log_file")
  hierarchy=$(extract_value "HIERARCHY" "$log_file")
  heuristic=$(extract_value "HEURISTIC" "$log_file")
  abstract_goal_mode=$(extract_value "ABSTRACT-GOAL-MODE" "$log_file")
  existing_only=$(extract_value "EXISTING-ONLY" "$log_file")
  solution_type=$(extract_value "SOLUTION-TYPE" "$log_file")
  solution_value=$(extract_value "SOLUTION-VALUE" "$log_file")
  expanded=$(extract_value "NUM-EXPANDED" "$log_file")
  generated=$(extract_value "NUM-GENERATED" "$log_file")
  mp_pruned=$(extract_value "MP-PRUNED" "$log_file")

  if [ "$solution_type" = "PLAN" ]; then
    outcome="solves"
  else
    outcome=${solution_value:-unknown}
  fi

  printf '| %s | %s | %s | %s | %s | %s | %s | %s | %s | %s |\n' \
    "$case_name" \
    "$bound_label" \
    "$planner / $hierarchy" \
    "$heuristic" \
    "$abstract_goal_mode" \
    "$existing_only" \
    "$outcome" \
    "$expanded" \
    "$generated" \
    "$mp_pruned; $notes"
}

cat <<EOF
# Hanoi-4 Control Comparison

This report compares the main live search-control choices for the restored
\`hanoi-4\` benchmark.

The intent is to answer three concrete questions:

1. is the default unsatisfied-goals heuristic helping or hurting?
2. does abstracting the goal help on the stronger hierarchies?
3. do flags like \`existing-only\` materially change the current search?

## Standard Bound Runs

Bounds used:

- expand bound: 20000
- generate bound: 80000
- open bound: 80000
- CPU seconds: 30

| Case | Bound | Planner | Heuristic | Abstract Goal | Existing Only | Outcome | Expanded | Generated | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
EOF

for spec in \
  "tweak-default|tweak|none|num-of-unsat-goals|t|nil|baseline tweak with default heuristic" \
  "tweak-zero|tweak|none|nil|t|nil|tweak with zero heuristic" \
  "ismb-default|abtweak|ismb|num-of-unsat-goals|t|nil|best current hierarchy with default heuristic" \
  "ismb-zero|abtweak|ismb|nil|t|nil|best current hierarchy with zero heuristic" \
  "ismb-no-absgoal|abtweak|ismb|num-of-unsat-goals|nil|nil|ismb without abstract goal lifting" \
  "ismb-existing-only|abtweak|ismb|num-of-unsat-goals|t|t|ismb with only existing establishers" \
  "crit2-default|abtweak|critical-list-2|num-of-unsat-goals|t|nil|comparison hierarchy with default heuristic" \
  "crit2-zero|abtweak|critical-list-2|nil|t|nil|comparison hierarchy with zero heuristic" \
  "crit2-no-absgoal|abtweak|critical-list-2|num-of-unsat-goals|nil|nil|comparison hierarchy without abstract goal lifting" \
  "crit2-existing-only|abtweak|critical-list-2|num-of-unsat-goals|t|t|comparison hierarchy with only existing establishers"
do
  old_ifs=$IFS
  IFS='|'
  set -- $spec
  IFS=$old_ifs
  result=$(run_case "$1" "$2" "$3" "$4" "$5" "$6" 20000 80000 80000 30 "$7")
  row_notes=$(printf '%s' "$result" | cut -d'|' -f1)
  row_log=$(printf '%s' "$result" | cut -d'|' -f2-)
  print_row "$1" "20k" "$row_notes" "$row_log"
done

cat <<EOF

## Higher Bound Follow-Up

Bounds used:

- expand bound: 100000
- generate bound: 400000
- open bound: 400000
- CPU seconds: 90

Only the most informative heuristic comparison cases are repeated here.

| Case | Bound | Planner | Heuristic | Abstract Goal | Existing Only | Outcome | Expanded | Generated | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
EOF

for spec in \
  "tweak-default-100k|tweak|none|num-of-unsat-goals|t|nil|higher-bound tweak baseline" \
  "tweak-zero-100k|tweak|none|nil|t|nil|higher-bound tweak with zero heuristic" \
  "ismb-default-100k|abtweak|ismb|num-of-unsat-goals|t|nil|higher-bound best current hierarchy" \
  "ismb-zero-100k|abtweak|ismb|nil|t|nil|higher-bound best hierarchy with zero heuristic"
do
  old_ifs=$IFS
  IFS='|'
  set -- $spec
  IFS=$old_ifs
  result=$(run_case "$1" "$2" "$3" "$4" "$5" "$6" 100000 400000 400000 90 "$7")
  row_notes=$(printf '%s' "$result" | cut -d'|' -f1)
  row_log=$(printf '%s' "$result" | cut -d'|' -f2-)
  print_row "$1" "100k" "$row_notes" "$row_log"
done

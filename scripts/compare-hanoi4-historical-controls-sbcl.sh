#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
WORKDIR="$REPO_ROOT/working/abtweak-1993"
SBCL_BIN=${SBCL_BIN:-/opt/homebrew/bin/sbcl}
TMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/abtweak-hanoi4-historical.XXXXXX")
EXPAND_BOUND=${EXPAND_BOUND:-20000}
GENERATE_BOUND=${GENERATE_BOUND:-80000}
OPEN_BOUND=${OPEN_BOUND:-80000}
CPU_SEC_LIMIT=${CPU_SEC_LIMIT:-30}

cleanup() {
  rm -rf "$TMP_DIR"
}

trap cleanup EXIT INT TERM

run_case() {
  hierarchy=$1
  msp_mode=$2
  msp_weak_mode=$3
  crit_depth_mode=$4
  determine_mode=$5
  left_wedge_mode=$6
  slug=$7
  log_file="$TMP_DIR/${slug}.log"

  eval_form='(progn
    (load "init-sbcl.lisp")
    (load "Domains/hanoi-4.lisp")
    (let ((result (historical-hanoi4-plan initial goal
                                          :hierarchy (quote '"$hierarchy"')
                                          :planner-mode (quote abtweak)
                                          :msp-mode (quote '"$msp_mode"')
                                          :msp-weak-mode (quote '"$msp_weak_mode"')
                                          :crit-depth-mode '"$crit_depth_mode"'
                                          :determine-mode (quote '"$determine_mode"')
                                          :left-wedge-mode '"$left_wedge_mode"'
                                          :output-file (quote no-output)
                                          :expand-bound '"$EXPAND_BOUND"'
                                          :generate-bound '"$GENERATE_BOUND"'
                                          :open-bound '"$OPEN_BOUND"'
                                          :cpu-sec-limit '"$CPU_SEC_LIMIT"')))
      (format t "CASE: ~A~%" "'"$slug"'")
      (format t "PLAN-RESULT: ~S~%" result)
      (format t "SOLUTION-VALUE: ~S~%" *solution*)
      (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
      (format t "NUM-EXPANDED: ~S~%" *num-expanded*)
      (format t "NUM-GENERATED: ~S~%" *num-generated*)
      (format t "MP-PRUNED: ~S~%" *mp-pruned*)
      (format t "STRONG-MP-PRUNED: ~S~%" *strong-mp-pruned*)
      (when (typep *solution* (quote plan))
        (format t "SOLUTION-LEN: ~S~%" (length (plan-a *solution*)))
        (format t "SOLUTION-COST: ~S~%" (plan-cost *solution*))
        (format t "SOLUTION-KVAL: ~S~%" (plan-kval *solution*)))))'

  (
    cd "$WORKDIR"
    "$SBCL_BIN" --noinform --disable-debugger --eval "$eval_form" --quit
  ) >"$log_file" 2>&1

  printf '%s\n' "$log_file"
}

extract_value() {
  key=$1
  file=$2
  sed -n "s/^$key: //p" "$file" | head -n 1
}

print_row() {
  hierarchy=$1
  msp_mode=$2
  weak_mode=$3
  crit_depth=$4
  determine_mode=$5
  left_wedge_mode=$6
  log_file=$7

  solution_type=$(extract_value "SOLUTION-TYPE" "$log_file")
  solution_value=$(extract_value "SOLUTION-VALUE" "$log_file")
  expanded=$(extract_value "NUM-EXPANDED" "$log_file")
  generated=$(extract_value "NUM-GENERATED" "$log_file")
  mp_pruned=$(extract_value "MP-PRUNED" "$log_file")
  strong_mp_pruned=$(extract_value "STRONG-MP-PRUNED" "$log_file")

  if [ "$solution_type" = "PLAN" ]; then
    outcome="solves"
  else
    outcome=${solution_value:-unknown}
  fi

  printf '| `%s` | `%s` | `%s` | `%s` | `%s` | `%s` | %s | %s | %s | %s | %s |\n' \
    "$hierarchy" \
    "$msp_mode" \
    "$weak_mode" \
    "$crit_depth" \
    "$determine_mode" \
    "$left_wedge_mode" \
    "$outcome" \
    "${expanded:-"-"}" \
    "${generated:-"-"}" \
    "${mp_pruned:-"-"}" \
    "${strong_mp_pruned:-"-"}"
}

cat <<EOF
# Hanoi-4 Historical Controls Comparison

This report exercises the initial hanoi-4 historical-control wrapper on top of
the working 1993 SBCL port.

Bounds used:

- expand bound: $EXPAND_BOUND
- generate bound: $GENERATE_BOUND
- open bound: $OPEN_BOUND
- CPU seconds: $CPU_SEC_LIMIT

| Hierarchy | MSP | Weak Mode | Crit-Depth | Determine | Left-Wedge | Outcome | Expanded | Generated | MP Pruned | Strong MP Pruned |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
EOF

log_file=$(run_case legacy-1991-default nil nec nil stack nil legacy-default-no-msp)
print_row legacy-1991-default nil nec nil stack nil "$log_file"

log_file=$(run_case legacy-1991-default weak nec nil stack nil legacy-default-weak-nec)
print_row legacy-1991-default weak nec nil stack nil "$log_file"

log_file=$(run_case legacy-1991-default weak pos nil stack nil legacy-default-weak-pos)
print_row legacy-1991-default weak pos nil stack nil "$log_file"

log_file=$(run_case legacy-1991-isbm weak pos nil stack nil legacy-1991-isbm-weak-pos)
print_row legacy-1991-isbm weak pos nil stack nil "$log_file"

log_file=$(run_case legacy-1991-imbs weak pos nil stack nil legacy-1991-imbs-weak-pos)
print_row legacy-1991-imbs weak pos nil stack nil "$log_file"

log_file=$(run_case legacy-1991-default nil nec t stack nil legacy-default-crit-depth)
print_row legacy-1991-default nil nec t stack nil "$log_file"

log_file=$(run_case ismb weak nec nil stack nil ismb-weak-nec)
print_row ismb weak nec nil stack nil "$log_file"

log_file=$(run_case ismb weak pos nil stack nil ismb-weak-pos)
print_row ismb weak pos nil stack nil "$log_file"

log_file=$(run_case ismb nil nec t stack nil ismb-crit-depth)
print_row ismb nil nec t stack nil "$log_file"

log_file=$(run_case isbm weak nec nil stack nil isbm-weak-nec)
print_row isbm weak nec nil stack nil "$log_file"

log_file=$(run_case isbm weak pos nil stack nil isbm-weak-pos)
print_row isbm weak pos nil stack nil "$log_file"

log_file=$(run_case isbm-h1 weak pos nil stack nil isbm-h1-weak-pos)
print_row isbm-h1 weak pos nil stack nil "$log_file"

log_file=$(run_case isbm-hb weak pos nil stack nil isbm-hb-weak-pos)
print_row isbm-hb weak pos nil stack nil "$log_file"

log_file=$(run_case imbs-h1 weak pos nil stack nil imbs-h1-weak-pos)
print_row imbs-h1 weak pos nil stack nil "$log_file"

log_file=$(run_case imbs-hb weak pos nil stack nil imbs-hb-weak-pos)
print_row imbs-hb weak pos nil stack nil "$log_file"

log_file=$(run_case isbm nil nec t stack nil isbm-crit-depth)
print_row isbm nil nec t stack nil "$log_file"

log_file=$(run_case isbm strong nec nil stack nil isbm-strong)
print_row isbm strong nec nil stack nil "$log_file"

log_file=$(run_case isbm weak pos nil tree t isbm-weak-pos-tree-lw)
print_row isbm weak pos nil tree t "$log_file"

cat <<EOF

## Determine-Mode Family Sweep

This second table holds the historically plausible weak-\`POS\` plus
Left-Wedge comparison across the recovered four-disk hierarchy families.

| Hierarchy | MSP | Weak Mode | Crit-Depth | Determine | Left-Wedge | Outcome | Expanded | Generated | MP Pruned | Strong MP Pruned |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
EOF

log_file=$(run_case legacy-1991-default weak pos nil stack t legacy-default-weak-pos-stack-lw)
print_row legacy-1991-default weak pos nil stack t "$log_file"

log_file=$(run_case legacy-1991-isbm weak pos nil stack t legacy-1991-isbm-weak-pos-stack-lw)
print_row legacy-1991-isbm weak pos nil stack t "$log_file"

log_file=$(run_case legacy-1991-imbs weak pos nil stack t legacy-1991-imbs-weak-pos-stack-lw)
print_row legacy-1991-imbs weak pos nil stack t "$log_file"

log_file=$(run_case legacy-1991-default weak pos nil tree t legacy-default-weak-pos-tree-lw)
print_row legacy-1991-default weak pos nil tree t "$log_file"

log_file=$(run_case critical-list-1 weak pos nil stack t critical-list-1-weak-pos-stack-lw)
print_row critical-list-1 weak pos nil stack t "$log_file"

log_file=$(run_case critical-list-1 weak pos nil tree t critical-list-1-weak-pos-tree-lw)
print_row critical-list-1 weak pos nil tree t "$log_file"

log_file=$(run_case critical-list-1h-lite weak pos nil stack nil critical-list-1h-lite-weak-pos-stack)
print_row critical-list-1h-lite weak pos nil stack nil "$log_file"

log_file=$(run_case critical-list-1h-lite weak pos nil stack t critical-list-1h-lite-weak-pos-stack-lw)
print_row critical-list-1h-lite weak pos nil stack t "$log_file"

log_file=$(run_case critical-list-2 weak pos nil stack t critical-list-2-weak-pos-stack-lw)
print_row critical-list-2 weak pos nil stack t "$log_file"

log_file=$(run_case critical-list-2 weak pos nil tree t critical-list-2-weak-pos-tree-lw)
print_row critical-list-2 weak pos nil tree t "$log_file"

log_file=$(run_case ismb weak pos nil stack t ismb-weak-pos-stack-lw)
print_row ismb weak pos nil stack t "$log_file"

log_file=$(run_case ismb weak pos nil tree t ismb-weak-pos-tree-lw)
print_row ismb weak pos nil tree t "$log_file"

log_file=$(run_case isbm weak pos nil stack t isbm-weak-pos-stack-lw)
print_row isbm weak pos nil stack t "$log_file"

log_file=$(run_case isbm-h1 weak pos nil stack t isbm-h1-weak-pos-stack-lw)
print_row isbm-h1 weak pos nil stack t "$log_file"

log_file=$(run_case isbm-hb weak pos nil stack t isbm-hb-weak-pos-stack-lw)
print_row isbm-hb weak pos nil stack t "$log_file"

log_file=$(run_case imbs-h1 weak pos nil stack t imbs-h1-weak-pos-stack-lw)
print_row imbs-h1 weak pos nil stack t "$log_file"

log_file=$(run_case imbs-hb weak pos nil stack t imbs-hb-weak-pos-stack-lw)
print_row imbs-hb weak pos nil stack t "$log_file"

log_file=$(run_case isbm weak pos nil tree t isbm-weak-pos-tree-lw-sweep)
print_row isbm weak pos nil tree t "$log_file"

log_file=$(run_case ibsm weak pos nil stack t ibsm-weak-pos-stack-lw)
print_row ibsm weak pos nil stack t "$log_file"

log_file=$(run_case ibsm weak pos nil tree t ibsm-weak-pos-tree-lw)
print_row ibsm weak pos nil tree t "$log_file"

log_file=$(run_case imbs weak pos nil stack t imbs-weak-pos-stack-lw)
print_row imbs weak pos nil stack t "$log_file"

log_file=$(run_case imbs weak pos nil tree t imbs-weak-pos-tree-lw)
print_row imbs weak pos nil tree t "$log_file"

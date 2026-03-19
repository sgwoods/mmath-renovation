#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
WORKDIR="$REPO_ROOT/working/abtweak-1993"
SBCL_BIN=${SBCL_BIN:-/opt/homebrew/bin/sbcl}
TMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/abtweak-hanoi3-historical.XXXXXX")
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
  slug=$6
  log_file="$TMP_DIR/${slug}.log"

  eval_form='(progn
    (load "init-sbcl.lisp")
    (load "Domains/hanoi-3.lisp")
    (let ((result (historical-hanoi3-plan initial goal
                                          :hierarchy (quote '"$hierarchy"')
                                          :planner-mode (quote abtweak)
                                          :msp-mode (quote '"$msp_mode"')
                                          :msp-weak-mode (quote '"$msp_weak_mode"')
                                          :crit-depth-mode '"$crit_depth_mode"'
                                          :determine-mode (quote '"$determine_mode"')
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
  historical_file=$6
  historical_expanded=$7
  historical_generated=$8
  log_file=$9

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

  printf '| `%s` | `%s` | `%s` | `%s` | `%s` | %s | %s | %s | %s | %s | `%s` | `%s` |\n' \
    "$hierarchy" \
    "$msp_mode" \
    "$weak_mode" \
    "$crit_depth" \
    "$determine_mode" \
    "$outcome" \
    "${expanded:-"-"}" \
    "${generated:-"-"}" \
    "${mp_pruned:-"-"}" \
    "${strong_mp_pruned:-"-"}" \
    "$historical_expanded / $historical_generated" \
    "$historical_file"
}

cat <<EOF
# Hanoi-3 Historical Controls Comparison

This report exercises the small 1991-style Hanoi compatibility layer now wired
into the SBCL working port.

Bounds used:

- expand bound: $EXPAND_BOUND
- generate bound: $GENERATE_BOUND
- open bound: $OPEN_BOUND
- CPU seconds: $CPU_SEC_LIMIT

| Hierarchy | MSP | Weak Mode | Crit-Depth | Determine | Outcome | Expanded | Generated | MP Pruned | Strong MP Pruned | Historical | Source |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
EOF

log_file=$(run_case isbm weak nec nil stack isbm-weak-nec)
print_row isbm weak nec nil stack "isbm-ab-WN.1126" 1083 1433 "$log_file"

log_file=$(run_case imbs weak nec nil stack imbs-weak-nec)
print_row imbs weak nec nil stack "imbs-ab-Wn.1129" 166 233 "$log_file"

log_file=$(run_case imbs weak pos nil stack imbs-weak-pos)
print_row imbs weak pos nil stack "imbs2-raw.out" 149 206 "$log_file"

log_file=$(run_case sbim weak pos nil stack sbim-weak-pos)
print_row sbim weak pos nil stack "sbim-raw.out" 332 490 "$log_file"

log_file=$(run_case sbmi weak pos nil stack sbmi-weak-pos)
print_row sbmi weak pos nil stack "sbmi-raw.out" 573 1071 "$log_file"

log_file=$(run_case simb weak pos nil stack simb-weak-pos)
print_row simb weak pos nil stack "simb-raw.out" 785 995 "$log_file"

log_file=$(run_case sibm weak pos nil stack sibm-weak-pos)
print_row sibm weak pos nil stack "sibm-raw.out" 482 620 "$log_file"

log_file=$(run_case smib weak pos nil stack smib-weak-pos)
print_row smib weak pos nil stack "smib-raw.out" 899 1236 "$log_file"

log_file=$(run_case misb weak pos nil stack misb-weak-pos)
print_row misb weak pos nil stack "misb-raw.out" 682 1040 "$log_file"

log_file=$(run_case isbm nil nec t stack isbm-crit-depth)
print_row isbm nil nec t stack "isbmK-raw.out" 168 284 "$log_file"

log_file=$(run_case ibsm nil nec t stack ibsm-crit-depth)
print_row ibsm nil nec t stack "ibsmK-raw.out" 828 1471 "$log_file"

log_file=$(run_case ismb nil nec t stack ismb-crit-depth)
print_row ismb nil nec t stack "ismbK-raw.out" 963 1771 "$log_file"

log_file=$(run_case isbm strong nec nil stack isbm-strong)
print_row isbm strong nec nil stack "no direct archived row isolated yet" "-" "-" "$log_file"

log_file=$(run_case isbm weak nec nil tree isbm-weak-nec-tree)
print_row isbm weak nec nil tree "no direct archived row isolated yet" "-" "-" "$log_file"

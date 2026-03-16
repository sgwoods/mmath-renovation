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
  slug=$5
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
  historical_file=$5
  historical_expanded=$6
  historical_generated=$7
  log_file=$8

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

  printf '| `%s` | `%s` | `%s` | `%s` | %s | %s | %s | %s | `%s` | `%s` |\n' \
    "$hierarchy" \
    "$msp_mode" \
    "$weak_mode" \
    "$crit_depth" \
    "$outcome" \
    "${expanded:-"-"}" \
    "${generated:-"-"}" \
    "${mp_pruned:-"-"}" \
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

| Hierarchy | MSP | Weak Mode | Crit-Depth | Outcome | Expanded | Generated | MP Pruned | Historical | Source |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
EOF

log_file=$(run_case isbm weak nec nil isbm-weak-nec)
print_row isbm weak nec nil "isbm-ab-WN.1126" 1083 1433 "$log_file"

log_file=$(run_case imbs weak nec nil imbs-weak-nec)
print_row imbs weak nec nil "imbs-ab-Wn.1129" 166 233 "$log_file"

log_file=$(run_case imbs weak pos nil imbs-weak-pos)
print_row imbs weak pos nil "imbs2-raw.out" 149 206 "$log_file"

log_file=$(run_case isbm nil nec t isbm-crit-depth)
print_row isbm nil nec t "isbmK-raw.out" 168 284 "$log_file"

log_file=$(run_case ibsm nil nec t ibsm-crit-depth)
print_row ibsm nil nec t "ibsmK-raw.out" 828 1471 "$log_file"

log_file=$(run_case ismb nil nec t ismb-crit-depth)
print_row ismb nil nec t "ismbK-raw.out" 963 1771 "$log_file"

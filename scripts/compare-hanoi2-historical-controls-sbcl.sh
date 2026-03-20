#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
WORKDIR="$REPO_ROOT/working/abtweak-1993"
SBCL_BIN=${SBCL_BIN:-/opt/homebrew/bin/sbcl}
TMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/abtweak-hanoi2-historical.XXXXXX")
EXPAND_BOUND=${EXPAND_BOUND:-2000}
GENERATE_BOUND=${GENERATE_BOUND:-8000}
OPEN_BOUND=${OPEN_BOUND:-8000}
CPU_SEC_LIMIT=${CPU_SEC_LIMIT:-15}

cleanup() {
  rm -rf "$TMP_DIR"
}

trap cleanup EXIT INT TERM

run_case() {
  hierarchy=$1
  slug=$2
  log_file="$TMP_DIR/${slug}.log"

  eval_form='(progn
    (load "init-sbcl.lisp")
    (load "Domains/hanoi-2.lisp")
    (let ((result (historical-hanoi2-plan initial goal
                                          :hierarchy (quote '"$hierarchy"')
                                          :planner-mode (quote abtweak)
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
  historical_file=$2
  historical_expanded=$3
  historical_generated=$4
  historical_abs_generated=$5
  log_file=$6

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

  printf '| `%s` | %s | %s | %s | %s | %s | `%s / %s / %s` | `%s` |\n' \
    "$hierarchy" \
    "$outcome" \
    "${expanded:-"-"}" \
    "${generated:-"-"}" \
    "${mp_pruned:-"-"}" \
    "$(extract_value "SOLUTION-COST" "$log_file" | sed 's/^$/-/')" \
    "$historical_expanded" \
    "$historical_generated" \
    "$historical_abs_generated" \
    "$historical_file"
}

cat <<EOF
# Hanoi-2 Historical Controls Comparison

This report exercises the recovered two-disk Hanoi hierarchy family against the
archived 1990 batch outputs.

Bounds used:

- expand bound: $EXPAND_BOUND
- generate bound: $GENERATE_BOUND
- open bound: $OPEN_BOUND
- CPU seconds: $CPU_SEC_LIMIT

| Hierarchy | Outcome | Expanded | Generated | MP Pruned | Cost | Historical (expanded/generated/abstract-gen) | Source |
| --- | --- | --- | --- | --- | --- | --- | --- |
EOF

log_file=$(run_case ibs ibs-default)
print_row ibs "crit1-raw.out" 11 19 2 "$log_file"

log_file=$(run_case sib sib-default)
print_row sib "crit2-raw.out" 25 47 4 "$log_file"

log_file=$(run_case bsi bsi-default)
print_row bsi "crit3-raw.out" 11 20 2 "$log_file"

log_file=$(run_case bis bis-default)
print_row bis "crit4-raw.out" 11 19 2 "$log_file"

log_file=$(run_case sbi sbi-default)
print_row sbi "crit5-raw.out" 23 46 3 "$log_file"

log_file=$(run_case isb isb-default)
print_row isb "crit6-raw.out" 24 46 3 "$log_file"

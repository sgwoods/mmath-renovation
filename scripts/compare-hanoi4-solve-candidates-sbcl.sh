#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
WORKDIR="$REPO_ROOT/working/abtweak-1993"
SBCL_BIN=${SBCL_BIN:-/opt/homebrew/bin/sbcl}
TMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/abtweak-hanoi4-solve-candidates.XXXXXX")
GENERATE_BOUND=${GENERATE_BOUND:-800000}
OPEN_BOUND=${OPEN_BOUND:-800000}
CPU_SEC_LIMIT=${CPU_SEC_LIMIT:-90}

cleanup() {
  rm -rf "$TMP_DIR"
}

trap cleanup EXIT INT TERM

run_case() {
  hierarchy=$1
  expand_bound=$2
  slug=$3
  log_file="$TMP_DIR/${slug}.log"

  eval_form='(progn
    (load "init-sbcl.lisp")
    (load "Domains/hanoi-4.lisp")
    (let ((result (historical-hanoi4-plan initial goal
                                          :hierarchy (quote '"$hierarchy"')
                                          :planner-mode (quote abtweak)
                                          :msp-mode (quote weak)
                                          :msp-weak-mode (quote pos)
                                          :crit-depth-mode nil
                                          :determine-mode (quote stack)
                                          :left-wedge-mode t
                                          :output-file (quote no-output)
                                          :expand-bound '"$expand_bound"'
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
  expand_bound=$2
  log_file=$3

  solution_type=$(extract_value "SOLUTION-TYPE" "$log_file")
  solution_value=$(extract_value "SOLUTION-VALUE" "$log_file")
  expanded=$(extract_value "NUM-EXPANDED" "$log_file")
  generated=$(extract_value "NUM-GENERATED" "$log_file")
  mp_pruned=$(extract_value "MP-PRUNED" "$log_file")

  if [ "$solution_type" = "PLAN" ]; then
    outcome="solved"
  else
    outcome=${solution_value:-unknown}
  fi

  printf '| `%s` | `%s` | %s | %s | %s | %s |\n' \
    "$hierarchy" \
    "$expand_bound" \
    "$outcome" \
    "${expanded:-"-"}" \
    "${generated:-"-"}" \
    "${mp_pruned:-"-"}"
}

cat <<EOF
# Hanoi-4 Solve Candidate Comparison

This report keeps the candidate set intentionally narrow:

- \`isbm + weak-POS + stack + Left-Wedge\`
- \`legacy-1991-isbm + weak-POS + stack + Left-Wedge\`

The primary benchmark question is binary:

- did it solve classic three-peg \`hanoi-4\`, or not?

Bounds used:

- generate bound: $GENERATE_BOUND
- open bound: $OPEN_BOUND
- CPU seconds: $CPU_SEC_LIMIT

| Hierarchy | Expand bound | Outcome | Expanded | Generated | MP Pruned |
| --- | --- | --- | --- | --- | --- |
EOF

for bound in 20000 50000 100000 200000; do
  log_file=$(run_case isbm "$bound" "isbm-${bound}")
  print_row isbm "$bound" "$log_file"

  log_file=$(run_case legacy-1991-isbm "$bound" "legacy-1991-isbm-${bound}")
  print_row legacy-1991-isbm "$bound" "$log_file"
done

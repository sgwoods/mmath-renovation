#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
WORKDIR="$REPO_ROOT/working/abtweak-1993"
SBCL_BIN=${SBCL_BIN:-/opt/homebrew/bin/sbcl}
TMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/abtweak-hanoi4.XXXXXX")
EXPAND_BOUND=${EXPAND_BOUND:-20000}
GENERATE_BOUND=${GENERATE_BOUND:-80000}
OPEN_BOUND=${OPEN_BOUND:-80000}
CPU_SEC_LIMIT=${CPU_SEC_LIMIT:-30}

cleanup() {
  rm -rf "$TMP_DIR"
}

trap cleanup EXIT INT TERM

hierarchy_lisp() {
  case "$1" in
    critical-list-1)
      printf '%s\n' '*critical-list-1*'
      ;;
    critical-list-2)
      printf '%s\n' '*critical-list-2*'
      ;;
    ismb)
      printf '%s\n' '*ismb*'
      ;;
    *)
      echo "Unknown hierarchy: $1" >&2
      exit 2
      ;;
  esac
}

left_wedge_lisp() {
  case "$1" in
    critical-list-1)
      printf '%s\n' '*k-list-1*'
      ;;
    critical-list-2)
      printf '%s\n' '*k-list-2*'
      ;;
    ismb)
      printf '%s\n' "'(0 1 3 7)"
      ;;
    *)
      echo "Unknown hierarchy: $1" >&2
      exit 2
      ;;
  esac
}

run_tweak_case() {
  log_file="$TMP_DIR/hanoi4-tweak.log"
  eval_form='(progn
    (load "init-sbcl.lisp")
    (load "Domains/hanoi-4.lisp")
    (let ((result (plan initial goal
                        :planner-mode (quote tweak)
                        :output-file (quote no-output)
                        :expand-bound '"$EXPAND_BOUND"'
                        :generate-bound '"$GENERATE_BOUND"'
                        :open-bound '"$OPEN_BOUND"'
                        :cpu-sec-limit '"$CPU_SEC_LIMIT"')))
      (format t "CASE: hanoi4-tweak~%")
      (format t "PLAN-RESULT: ~S~%" result)
      (format t "SOLUTION-VALUE: ~S~%" *solution*)
      (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
      (format t "NUM-EXPANDED: ~S~%" *num-expanded*)
      (format t "NUM-GENERATED: ~S~%" *num-generated*)
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

run_abtweak_case() {
  hierarchy=$1
  mp_mode=$2
  left_wedge_mode=$3
  hierarchy_expr=$(hierarchy_lisp "$hierarchy")
  left_wedge_expr=$(left_wedge_lisp "$hierarchy")
  log_file="$TMP_DIR/${hierarchy}-${mp_mode}-${left_wedge_mode}.log"
  eval_form='(progn
    (load "init-sbcl.lisp")
    (load "Domains/hanoi-4.lisp")
    (setq *critical-list* '"$hierarchy_expr"')
    (setq *left-wedge-list* '"$left_wedge_expr"')
    (setq *critical-loaded* '"$hierarchy_expr"')
    (let ((result (plan initial goal
                        :planner-mode (quote abtweak)
                        :mp-mode '"$mp_mode"'
                        :left-wedge-mode '"$left_wedge_mode"'
                        :output-file (quote no-output)
                        :expand-bound '"$EXPAND_BOUND"'
                        :generate-bound '"$GENERATE_BOUND"'
                        :open-bound '"$OPEN_BOUND"'
                        :cpu-sec-limit '"$CPU_SEC_LIMIT"')))
      (format t "CASE: hanoi4-'"$hierarchy"'-mp-'"$mp_mode"'-lw-'"$left_wedge_mode"'~%")
      (format t "HIERARCHY: '"$hierarchy"'~%")
      (format t "MP-MODE: ~S~%" '"$mp_mode"')
      (format t "LEFT-WEDGE-MODE: ~S~%" '"$left_wedge_mode"')
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

print_row_from_log() {
  planner=$1
  hierarchy=$2
  mp_mode=$3
  left_wedge_mode=$4
  notes=$5
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

  if [ -z "$expanded" ]; then
    expanded="-"
  fi

  if [ -z "$generated" ]; then
    generated="-"
  fi

  if [ -z "$mp_pruned" ]; then
    mp_pruned="-"
  fi

  printf '| %s | %s | %s | %s | %s | %s | %s | %s |\n' \
    "$planner" \
    "$hierarchy" \
    "$mp_mode" \
    "$left_wedge_mode" \
    "$outcome" \
    "$expanded" \
    "$generated" \
    "$mp_pruned; $notes"
}

cat <<EOF
# Hanoi-4 Hierarchy Comparison

This report compares the historical hanoi-4 hierarchy options in the current SBCL working tree.

Bounds used:

- expand bound: $EXPAND_BOUND
- generate bound: $GENERATE_BOUND
- open bound: $OPEN_BOUND
- CPU seconds: $CPU_SEC_LIMIT

Notes:

- critical-list-1 and critical-list-2 use the domain-defined left-wedge lists.
- ismb has no dedicated left-wedge list in the domain file, so this script uses the four-level Hanoi list (0 1 3 7) as an explicit reconstruction assumption.

| Planner | Hierarchy | MP | Left-Wedge | Outcome | Expanded | Generated | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
EOF

tweak_log=$(run_tweak_case)
print_row_from_log "tweak" "-" "-" "-" "baseline without abstraction hierarchy" "$tweak_log"

for hierarchy in critical-list-1 critical-list-2 ismb; do
  for setting in "t t default-abtweak" "nil t no-mp" "t nil no-left-wedge" "nil nil no-mp-no-left-wedge"; do
    old_ifs=$IFS
    IFS=' '
    set -- $setting
    IFS=$old_ifs
    mp_mode=$1
    left_wedge_mode=$2
    notes=$3
    log_file=$(run_abtweak_case "$hierarchy" "$mp_mode" "$left_wedge_mode")
    print_row_from_log "abtweak" "$hierarchy" "$mp_mode" "$left_wedge_mode" "$notes" "$log_file"
  done
done

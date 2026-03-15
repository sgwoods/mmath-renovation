#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
SMOKE_SCRIPT="$REPO_ROOT/scripts/smoke-abtweak-1993-sbcl.sh"
TMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/abtweak-compare.XXXXXX")

cleanup() {
  rm -rf "$TMP_DIR"
}

trap cleanup EXIT INT TERM

run_case() {
  case_name=$1
  log_file="$TMP_DIR/$case_name.log"

  "$SMOKE_SCRIPT" "$case_name" >"$log_file" 2>&1

  solution_type=$(sed -n 's/^SOLUTION-TYPE: //p' "$log_file" | head -n 1)
  solution_value=$(sed -n 's/^SOLUTION-VALUE: //p' "$log_file" | head -n 1)
  solution_cost=$(sed -n 's/^SOLUTION-COST: //p' "$log_file" | head -n 1)
  solution_len=$(sed -n 's/^SOLUTION-LEN: //p' "$log_file" | head -n 1)
  solution_kval=$(sed -n 's/^SOLUTION-KVAL: //p' "$log_file" | head -n 1)

  if [ "$solution_type" = "PLAN" ]; then
    outcome="solves"
  else
    outcome=${solution_value:-unknown}
  fi

  if [ -z "$solution_cost" ]; then
    solution_cost="-"
  fi

  if [ -z "$solution_len" ]; then
    solution_len="-"
  fi

  if [ -z "$solution_kval" ]; then
    solution_kval="-"
  fi

  printf '%s|%s|%s|%s|%s\n' \
    "$outcome" \
    "$solution_cost" \
    "$solution_len" \
    "$solution_kval" \
    "$solution_type"
}

print_row() {
  domain=$1
  config=$2
  case_name=$3
  notes=$4
  result=$(run_case "$case_name")

  old_ifs=$IFS
  IFS='|'
  set -- $result
  IFS=$old_ifs

  outcome=$1
  cost=$2
  length=$3
  kval=$4
  solution_type=$5

  printf '| %s | %s | %s | %s | %s | %s | %s |\n' \
    "$domain" \
    "$config" \
    "$outcome" \
    "$cost" \
    "$length" \
    "$kval" \
    "$notes"
}

cat <<'EOF'
# AbTweak-1993 SBCL Comparison

This report compares the current core `tweak` and `abtweak` smoke cases under SBCL.

| Domain | Config | Outcome | Cost | Length | Kval | Notes |
| --- | --- | --- | --- | --- | --- | --- |
EOF

print_row "blocks / sussman" "tweak" "blocks-sussman-tweak" "canonical least-commitment baseline"
print_row "blocks / sussman" "abtweak" "blocks-sussman-abtweak" "same result as tweak at current bounds"
print_row "hanoi-3" "tweak" "hanoi3-tweak" "abstraction-heavy benchmark"
print_row "hanoi-3" "abtweak" "hanoi3-abtweak" "same result as tweak at current bounds"
print_row "hanoi-4" "tweak" "hanoi4-tweak" "larger abstraction benchmark at exploratory bounds"
print_row "hanoi-4" "abtweak" "hanoi4-abtweak" "same bounded failure at current exploratory bounds"
print_row "macro-hanoi" "tweak" "macro-hanoi-tweak" "macro operator variant"
print_row "macro-hanoi" "abtweak" "macro-hanoi-abtweak" "same compact solution as tweak"
print_row "simple-robot-2" "tweak" "robot2-tweak" "user-defined heuristic plus primary effects"
print_row "simple-robot-2" "abtweak" "robot2-abtweak" "solves with left-wedge enabled"
print_row "simple-robot-2" "abtweak, no left-wedge" "robot2-abtweak-no-lw" "same bounds, left-wedge disabled"

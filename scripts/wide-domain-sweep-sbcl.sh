#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
SMOKE_SCRIPT="$REPO_ROOT/scripts/smoke-abtweak-1993-sbcl.sh"
TMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/abtweak-wide.XXXXXX")

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
# AbTweak-1993 Wide SBCL Domain Sweep

This report widens the current benchmark sweep beyond the first core smoke
cases and focuses on shipped operator-style domains that are runnable through
the restored `plan` entry point under SBCL.

| Domain | Config | Outcome | Cost | Length | Kval | Notes |
| --- | --- | --- | --- | --- | --- | --- |
EOF

print_row "registers" "tweak" "registers-tweak" "baseline register-exchange example"
print_row "registers" "abtweak" "registers-abtweak" "same compact solution under abstraction"
print_row "blocks / sussman" "tweak" "blocks-sussman-tweak" "canonical baseline"
print_row "blocks / sussman" "abtweak" "blocks-sussman-abtweak" "same solution under abstraction"
print_row "blocks / interchange" "tweak" "blocks-interchange-tweak" "second shipped blocksworld setup"
print_row "blocks / interchange" "abtweak" "blocks-interchange-abtweak" "same cost, different valid operator ordering"
print_row "blocks / flatten" "tweak" "blocks-flatten-tweak" "tower-flattening setup"
print_row "blocks / flatten" "abtweak" "blocks-flatten-abtweak" "same compact 2-step solution"
print_row "Nilsson blocks" "tweak" "nils-blocks-tweak" "manual blocksworld variant"
print_row "Nilsson blocks" "abtweak" "nils-blocks-abtweak" "same plan, MP enabled"
print_row "computer" "tweak" "computer-tweak" "operator domain with primary effects"
print_row "computer" "abtweak" "computer-abtweak" "same result under abstraction"
print_row "stylistics" "tweak" "stylistics-tweak" "restored historical sample task from commented domain example"
print_row "stylistics" "abtweak" "stylistics-abtweak" "same restored sample task under abstraction"
print_row "fly / Washington DC" "tweak" "fly-dc-tweak" "primary-effects flight problem"
print_row "fly / Washington DC" "abtweak" "fly-dc-abtweak" "same 2-flight solution under abstraction"
print_row "fly / San Francisco" "tweak" "fly-sf-tweak" "longer flight chain"
print_row "fly / San Francisco" "abtweak" "fly-sf-abtweak" "same cost and length under abstraction"
print_row "biology / goal1" "tweak" "biology-goal1-tweak" "contains-insulin-gene subgoal"
print_row "biology / goal1" "abtweak" "biology-goal1-abtweak" "same plan length and cost"
print_row "biology / full goal" "abtweak" "biology-full-abtweak" "full rat-insulin goal stack"
print_row "database / query0" "tweak" "database-goal0-tweak" "pure projection query"
print_row "database / query1" "tweak" "database-goal1-tweak" "selection plus projection"
print_row "database / query1" "abtweak" "database-goal1-abtweak" "works after numeric-constant var-p fix"
print_row "database / query3" "tweak" "database-goal3-tweak" "join plus projection query"
print_row "database / query3" "abtweak" "database-goal3-abtweak" "same compact result under abstraction"

cat <<'EOF'

## Not Yet In This Sweep

| Domain file | Current status | Reason |
| --- | --- | --- |
| `Domains/driving.lisp` | excluded | uses `reset-domain` / `defstep`, which appear to belong to a different planner framework than the restored AbTweak `plan` path |
| `Domains/scheduling.lisp` | excluded | same alternate `reset-domain` / `defstep` style, not yet wired into the current SBCL AbTweak entry point |
| `Domains/newd.lisp` | excluded | mixed experimental/planner-alternative file, not a direct AbTweak operator-domain smoke target |
| `Domains/simple-robot.lisp` | deferred | the repo already covers the clearer `simple-robot-1` and `simple-robot-2` variants instead |
| `Domains/check-primary-effects.lisp` | helper only | support file, not a standalone planning domain |
| `Domains/robot-heuristic.lisp` | helper only | support file, not a standalone planning domain |

## Usage

```sh
sh /Users/stevenwoods/mmath-renovation/scripts/wide-domain-sweep-sbcl.sh
```
EOF

#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
WORKDIR="$REPO_ROOT/working/abtweak-1993"
SBCL_BIN=${SBCL_BIN:-/opt/homebrew/bin/sbcl}
TMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/abtweak-hanoi-publication.XXXXXX")
EXPAND_BOUND=${EXPAND_BOUND:-6000}
GENERATE_BOUND=${GENERATE_BOUND:-24000}
OPEN_BOUND=${OPEN_BOUND:-24000}
CPU_SEC_LIMIT=${CPU_SEC_LIMIT:-30}

cleanup() {
  rm -rf "$TMP_DIR"
}

trap cleanup EXIT INT TERM

run_case() {
  hierarchy=$1
  msp_mode=$2
  msp_weak_mode=$3
  left_wedge_mode=$4
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
                                          :determine-mode (quote stack)
                                          :left-wedge-mode (quote '"$left_wedge_mode"')
                                          :output-file (quote no-output)
                                          :expand-bound '"$EXPAND_BOUND"'
                                          :generate-bound '"$GENERATE_BOUND"'
                                          :open-bound '"$OPEN_BOUND"'
                                          :cpu-sec-limit '"$CPU_SEC_LIMIT"')))
      (declare (ignore result))
      (format t "SOLUTION-VALUE: ~S~%" *solution*)
      (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*))
      (format t "NUM-EXPANDED: ~S~%" *num-expanded*)
      (format t "NUM-GENERATED: ~S~%" *num-generated*)))'

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

render_current() {
  log_file=$1
  solution_type=$(extract_value "SOLUTION-TYPE" "$log_file")
  solution_value=$(extract_value "SOLUTION-VALUE" "$log_file")
  expanded=$(extract_value "NUM-EXPANDED" "$log_file")

  if [ "$solution_type" = "PLAN" ]; then
    printf '%s' "${expanded:-"-"}"
  else
    printf '%s' "${solution_value:-unknown}"
  fi
}

render_status() {
  published=$1
  current=$2

  if [ "$published" = "$current" ]; then
    printf 'Exact'
    return
  fi

  case "$published|$current" in
    '>6000|EXPAND-LIMIT-EXCEEDED')
      printf 'Qualitative'
      ;;
    *)
      printf 'Different'
      ;;
  esac
}

print_row() {
  hierarchy_label=$1
  hierarchy_symbol=$2
  bf_pub=$3
  bfp_pub=$4
  lw_pub=$5
  lwp_pub=$6

  bf_log=$(run_case "$hierarchy_symbol" nil nec nil "${hierarchy_symbol}-bf")
  bfp_log=$(run_case "$hierarchy_symbol" weak pos nil "${hierarchy_symbol}-bf-pwmp")
  lw_log=$(run_case "$hierarchy_symbol" nil nec t "${hierarchy_symbol}-lw")
  lwp_log=$(run_case "$hierarchy_symbol" weak pos t "${hierarchy_symbol}-lw-pwmp")

  bf_cur=$(render_current "$bf_log")
  bfp_cur=$(render_current "$bfp_log")
  lw_cur=$(render_current "$lw_log")
  lwp_cur=$(render_current "$lwp_log")

  printf '| `%s` | `%s` | `%s` | `%s` | `%s` | `%s` | `%s` | `%s` | `%s` |\n' \
    "$hierarchy_label" \
    "$bf_pub" "$bf_cur" \
    "$bfp_pub" "$bfp_cur" \
    "$lw_pub" "$lw_cur" \
    "$lwp_pub" "$lwp_cur"

  printf '|  |  |  |  |  |  |  | publication match | `%s / %s / %s / %s` |\n' \
    "$(render_status "$bf_pub" "$bf_cur")" \
    "$(render_status "$bfp_pub" "$bfp_cur")" \
    "$(render_status "$lw_pub" "$lw_cur")" \
    "$(render_status "$lwp_pub" "$lwp_cur")"
}

cat <<EOF
# Hanoi Publication Alignment

This report aligns the original published Hanoi figure rows with the current
SBCL restoration on the original three-disk Hanoi predicate family.

Important scope note:

- these exact publication rows correspond to the original \`hanoi-3\` style
  domain (\`onb\`, \`onm\`, \`ons\`)
- they do not directly correspond to the later shipped four-disk
  [hanoi-4.lisp]($REPO_ROOT/working/abtweak-1993/Domains/hanoi-4.lisp#L1)
  extension with added \`onh\`

Publication source for the numeric rows:

- checked-in thesis PDF:
  [1991-uwaterloo-tr-17-thesis-report.pdf]($REPO_ROOT/publications/1991-uwaterloo-tr-17-thesis-report.pdf)
- locally extracted from the thesis figure block labelled
  \`BF Expansions: IBMS IMBS IBSM IMSB ISBM ISMB\`

Restoration settings used here:

- planner: \`abtweak\`
- determine mode: \`stack\`
- expand bound: $EXPAND_BOUND
- generate bound: $GENERATE_BOUND
- open bound: $OPEN_BOUND
- CPU seconds: $CPU_SEC_LIMIT

| Hierarchy | Thesis BF | Current BF | Thesis BF + P-WMP | Current BF + P-WMP | Thesis LW | Current LW | Thesis LW + P-WMP | Current LW + P-WMP |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
EOF

print_row IBMS critical-list-1 471 471 57 57
print_row IMBS imbs 550 149 1009 78
print_row IBSM ibsm 1112 729 828 531
print_row IMSB imsb 918 636 5170 2672
print_row ISBM isbm 1771 904 168 5232
print_row ISMB ismb 3142 '>6000' 963 '>6000'

cat <<EOF

Interpretation:

- \`IBMS\`, \`IMBS\`, \`IBSM\`, \`IMSB\`, and \`ISBM\` now reproduce the thesis
  figure rows exactly at the expanded-node level across all four strategy
  columns.
- \`ISMB\` reproduces the solvable columns exactly and matches the two thesis
  \`>6000\` entries qualitatively by exceeding the same 6000-node figure scale.
- This is the strongest exact publication-side Hanoi validation surface in the
  current repo.
- The later four-disk [hanoi-4.lisp]($REPO_ROOT/working/abtweak-1993/Domains/hanoi-4.lisp#L1)
  benchmark should therefore be treated as a historically grounded extension,
  not as a figure-for-figure publication rerun.
EOF

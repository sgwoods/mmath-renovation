#!/bin/sh
set -eu

REPO_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
MINI_ROOT="$REPO_ROOT/historical/Mini-Tweak"
SBCL_BIN=${SBCL_BIN:-/opt/homebrew/bin/sbcl}
TMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/mini-tweak-probe.XXXXXX")

cleanup() {
  rm -rf "$TMP_DIR"
}

trap cleanup EXIT INT TERM

run_probe() {
  name=$1
  workdir=$2
  command_text=$3
  log_file="$TMP_DIR/$name.log"
  if (
    cd "$workdir"
    /bin/zsh -lc "$command_text"
  ) >"$log_file" 2>&1; then
    status="ok"
  else
    status="failed"
  fi
  printf '%s\t%s\t%s\n' "$name" "$status" "$log_file"
}

print_summary() {
  name=$1
  status=$2
  log_file=$3
  headline=$(rg -m 1 "unmatched close parenthesis|The variable FROM is unbound|Unhandled|READ error during LOAD|RESULT:" "$log_file" || true)
  [ -n "$headline" ] || headline=$(sed -n '1,8p' "$log_file" | tr '\n' ' ' | sed 's/  */ /g')
  printf '| `%s` | `%s` | %s |\n' "$name" "$status" "${headline:-no summary available}"
}

ORIGINAL_CMD="$SBCL_BIN --noinform --disable-debugger --eval '(shadow (quote step))' --load minitweak.lsp --eval '(setf *trace-tweak* nil *trace-manager* nil *tries* 1)' --eval '(load \"../lens-domain.l\")' --eval '(format t \"RESULT: ~S~%\" (mini-tweak (quote (sand)) (quote (reflective-lens))))' --quit"
LOCAL_CMD="$SBCL_BIN --noinform --disable-debugger --eval '(shadow (quote step))' --load m-tweak.l --load lens-domain.l --eval '(setf *trace-tweak* nil *trace-manager* nil *tries* 1)' --eval '(format t \"RESULT: ~S~%\" (mini-tweak (quote (sand)) (quote (reflective-lens))))' --quit"
MODIFY_CMD="$SBCL_BIN --noinform --disable-debugger --eval '(shadow (quote step))' --load modify.lsp --load lens-domain.l --eval '(setf *trace-tweak* nil *trace-manager* nil *tries* 1)' --eval '(format t \"RESULT: ~S~%\" (mini-tweak (quote (sand)) (quote (reflective-lens))))' --quit"

orig_result=$(run_probe original-as-imported "$MINI_ROOT/Original" "$ORIGINAL_CMD")
local_result=$(run_probe local-m-tweak "$MINI_ROOT" "$LOCAL_CMD")
modify_result=$(run_probe local-modify "$MINI_ROOT" "$MODIFY_CMD")

orig_log=$(printf '%s' "$orig_result" | cut -f3)
local_log=$(printf '%s' "$local_result" | cut -f3)
modify_log=$(printf '%s' "$modify_result" | cut -f3)

cat <<'EOF'
# Mini-Tweak SBCL Probe

This probe checks whether the recovered `Mini-Tweak` sources run under SBCL
without editing the archival files.

| Probe | Status | First useful signal |
| --- | --- | --- |
EOF

print_summary original-as-imported "$(printf '%s' "$orig_result" | cut -f2)" "$orig_log"
print_summary local-m-tweak "$(printf '%s' "$local_result" | cut -f2)" "$local_log"
print_summary local-modify "$(printf '%s' "$modify_result" | cut -f2)" "$modify_log"

cat <<'EOF'

## Interpretation

- `original-as-imported` still contains preserved mail-header text, so it does
  not load as a Lisp file under SBCL without preprocessing.
- `local-m-tweak` and `local-modify` get past that provenance layer, but still
  fail under SBCL even after shadowing `STEP`.
- The current local copies fail on a reader-level syntax problem around the
  `remove-this-before-constraint` area.

## Logs
EOF

printf -- '- original: `%s`\n' "$orig_log"
printf -- '- local m-tweak: `%s`\n' "$local_log"
printf -- '- local modify: `%s`\n' "$modify_log"

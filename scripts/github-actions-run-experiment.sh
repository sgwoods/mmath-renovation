#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
HARNESS_SCRIPT="$SCRIPT_DIR/abtweak-experiments.sh"

usage() {
  cat <<EOF >&2
Usage:
  sh scripts/github-actions-run-experiment.sh KIND NAME OUT_DIR

Kinds:
  status  NAME should be '-'
  run     NAME must be a listed case
  report  NAME must be a listed report
  trace   NAME must be a listed trace
EOF
  exit 2
}

normalize_kind() {
  case "$1" in
    status) printf '%s' "status" ;;
    run) printf '%s' "run" ;;
    report) printf '%s' "report" ;;
    trace) printf '%s' "trace" ;;
    *) return 1 ;;
  esac
}

validate_name() {
  kind=$1
  name=$2

  case "$kind" in
    status)
      [ "$name" = "-" ] || [ -z "$name" ]
      ;;
    run)
      sh "$HARNESS_SCRIPT" list cases | grep -Fx -- "$name" >/dev/null
      ;;
    report)
      sh "$HARNESS_SCRIPT" list reports | grep -Fx -- "$name" >/dev/null
      ;;
    trace)
      sh "$HARNESS_SCRIPT" list traces | grep -Fx -- "$name" >/dev/null
      ;;
    *)
      return 1
      ;;
  esac
}

write_summary() {
  kind=$1
  name=$2
  json_file=$3
  summary_file=$4
  plain_file=$5

  python3 - "$kind" "$name" "$json_file" "$summary_file" "$plain_file" <<'PY'
import json
import pathlib
import sys

kind, name, json_path, summary_path, plain_path = sys.argv[1:6]
data = json.loads(pathlib.Path(json_path).read_text())
lines = [
    "# Remote experiment result",
    "",
    f"- Kind: `{kind}`",
]
if kind != "status":
    lines.append(f"- Name: `{name}`")

if kind == "status":
    families = data.get("families", [])
    lines.append(f"- Families reported: `{len(families)}`")
elif kind == "run":
    for key, label in [
        ("plan_result", "Plan result"),
        ("solution_type", "Solution type"),
        ("solution_cost", "Solution cost"),
        ("solution_len", "Solution length"),
        ("solution_kval", "Solution kval"),
        ("num_expanded", "Expanded"),
        ("num_generated", "Generated"),
        ("mp_pruned", "MP pruned"),
    ]:
        value = data.get(key)
        if value not in (None, "", "null"):
            lines.append(f"- {label}: `{value}`")
elif kind == "report":
    title = data.get("title")
    if title:
        lines.append(f"- Title: `{title}`")
elif kind == "trace":
    for key, label in [
        ("plan_result", "Plan result"),
        ("solution_value", "Solution value"),
        ("num_expanded", "Expanded"),
        ("num_generated", "Generated"),
        ("mp_pruned", "MP pruned"),
    ]:
        value = data.get(key)
        if value not in (None, "", "null"):
            lines.append(f"- {label}: `{value}`")

lines.extend([
    "",
    "Files:",
    f"- JSON summary: `{pathlib.Path(json_path).name}`",
    f"- Plain output: `{pathlib.Path(plain_path).name}`",
])

pathlib.Path(summary_path).write_text("\n".join(lines) + "\n")
PY
}

copy_trace_dir() {
  json_file=$1
  out_dir=$2

  trace_dir=$(python3 - "$json_file" <<'PY'
import json
import sys

data = json.load(open(sys.argv[1]))
print(data.get("trace_dir") or "")
PY
)

  if [ -n "$trace_dir" ] && [ -d "$trace_dir" ]; then
    cp -R "$trace_dir" "$out_dir/trace-artifacts"
  fi
}

KIND=${1:-}
NAME=${2:-}
OUT_DIR=${3:-}

[ -n "$KIND" ] || usage
[ -n "$OUT_DIR" ] || usage

KIND=$(normalize_kind "$KIND") || usage
validate_name "$KIND" "$NAME" || {
  echo "Invalid curated experiment selection: kind=$KIND name=$NAME" >&2
  exit 1
}

mkdir -p "$OUT_DIR"

if [ -z "${SBCL_BIN:-}" ]; then
  SBCL_BIN=$(command -v sbcl || true)
fi

if [ -z "${SBCL_BIN:-}" ]; then
  echo "SBCL executable not found. Set SBCL_BIN or install sbcl." >&2
  exit 1
fi

export SBCL_BIN

command_file="$OUT_DIR/command.txt"
summary_file="$OUT_DIR/summary.md"

case "$KIND" in
  status)
    plain_file="$OUT_DIR/status.md"
    json_file="$OUT_DIR/status.json"
    printf 'sh %s status\n' "$HARNESS_SCRIPT" >"$command_file"
    sh "$HARNESS_SCRIPT" status >"$plain_file"
    sh "$HARNESS_SCRIPT" status --json >"$json_file"
    ;;
  run)
    plain_file="$OUT_DIR/run.txt"
    json_file="$OUT_DIR/run.json"
    printf 'sh %s run %s\n' "$HARNESS_SCRIPT" "$NAME" >"$command_file"
    sh "$HARNESS_SCRIPT" run "$NAME" >"$plain_file"
    sh "$HARNESS_SCRIPT" run "$NAME" --json >"$json_file"
    ;;
  report)
    plain_file="$OUT_DIR/report.md"
    json_file="$OUT_DIR/report.json"
    printf 'sh %s report %s\n' "$HARNESS_SCRIPT" "$NAME" >"$command_file"
    sh "$HARNESS_SCRIPT" report "$NAME" >"$plain_file"
    sh "$HARNESS_SCRIPT" report "$NAME" --json >"$json_file"
    ;;
  trace)
    plain_file="$OUT_DIR/trace.txt"
    json_file="$OUT_DIR/trace.json"
    printf 'sh %s trace %s\n' "$HARNESS_SCRIPT" "$NAME" >"$command_file"
    sh "$HARNESS_SCRIPT" trace "$NAME" >"$plain_file"
    sh "$HARNESS_SCRIPT" trace "$NAME" --json >"$json_file"
    copy_trace_dir "$json_file" "$OUT_DIR"
    ;;
esac

write_summary "$KIND" "$NAME" "$json_file" "$summary_file" "$plain_file"

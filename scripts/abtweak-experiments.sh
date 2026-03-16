#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
SMOKE_SCRIPT="$SCRIPT_DIR/smoke-abtweak-1993-sbcl.sh"

usage() {
  cat <<EOF
Usage:
  sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh help
  sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh list
  sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh list cases
  sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh list reports
  sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh list traces
  sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh status
  sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh status --json
  sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh run CASE
  sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh run CASE --json
  sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh report NAME
  sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh report NAME --json
  sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh trace NAME
  sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh trace NAME --json

Commands:
  help        Show this help.
  list        Show the standardized experiment surface.
  status      Show the benchmark-family status summary.
  run         Execute one named smoke case.
  report      Execute one named comparison/report script.
  trace       Execute one named trace workflow.

Examples:
  sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh run blocks-sussman-abtweak
  sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh run blocks-sussman-abtweak --json
  sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh status
  sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh report compare-core
  sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh report benchmark-status --json
  sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh trace hanoi4-isbm-weak-pos
EOF
}

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

json_escape_multiline() {
  awk 'BEGIN { sep="" }
       {
         gsub(/\\/,"\\\\");
         gsub(/"/,"\\\"");
         printf "%s%s", sep, $0;
         sep="\\n";
       }' "$1"
}

extract_value() {
  key=$1
  file=$2
  sed -n "s/^$key: //p" "$file" | head -n 1
}

emit_run_json() {
  case_name=$1
  file=$2
  plan_result=$(extract_value "PLAN-RESULT" "$file")
  solution_value=$(extract_value "SOLUTION-VALUE" "$file")
  solution_type=$(extract_value "SOLUTION-TYPE" "$file")
  solution_len=$(extract_value "SOLUTION-LEN" "$file")
  solution_cost=$(extract_value "SOLUTION-COST" "$file")
  solution_kval=$(extract_value "SOLUTION-KVAL" "$file")
  num_expanded=$(extract_value "NUM-EXPANDED" "$file")
  num_generated=$(extract_value "NUM-GENERATED" "$file")
  mp_pruned=$(extract_value "MP-PRUNED" "$file")

  [ -n "$plan_result" ] || plan_result="null"
  [ -n "$solution_value" ] || solution_value="null"
  [ -n "$solution_type" ] || solution_type="null"
  [ -n "$solution_len" ] || solution_len="null"
  [ -n "$solution_cost" ] || solution_cost="null"
  [ -n "$solution_kval" ] || solution_kval="null"
  [ -n "$num_expanded" ] || num_expanded="null"
  [ -n "$num_generated" ] || num_generated="null"
  [ -n "$mp_pruned" ] || mp_pruned="null"

  if [ "$solution_type" = "PLAN" ]; then
    solution_value="PLAN"
  fi

  cat <<EOF
{
  "kind": "run",
  "case": "$(json_escape "$case_name")",
  "plan_result": "$(json_escape "$plan_result")",
  "solution_value": "$(json_escape "$solution_value")",
  "solution_type": "$(json_escape "$solution_type")",
  "solution_len": "$(json_escape "$solution_len")",
  "solution_cost": "$(json_escape "$solution_cost")",
  "solution_kval": "$(json_escape "$solution_kval")",
  "num_expanded": "$(json_escape "$num_expanded")",
  "num_generated": "$(json_escape "$num_generated")",
  "mp_pruned": "$(json_escape "$mp_pruned")"
}
EOF
}

emit_trace_json() {
  trace_name=$1
  file=$2
  trace_dir=$(extract_value "TRACE-DIR" "$file")
  plan_result=$(extract_value "PLAN-RESULT" "$file")
  solution_value=$(extract_value "SOLUTION-VALUE" "$file")
  num_expanded=$(extract_value "NUM-EXPANDED" "$file")
  num_generated=$(extract_value "NUM-GENERATED" "$file")
  mp_pruned=$(extract_value "MP-PRUNED" "$file")

  [ -n "$trace_dir" ] || trace_dir="null"
  [ -n "$plan_result" ] || plan_result="null"
  [ -n "$solution_value" ] || solution_value="null"
  [ -n "$num_expanded" ] || num_expanded="null"
  [ -n "$num_generated" ] || num_generated="null"
  [ -n "$mp_pruned" ] || mp_pruned="null"

  cat <<EOF
{
  "kind": "trace",
  "trace": "$(json_escape "$trace_name")",
  "trace_dir": "$(json_escape "$trace_dir")",
  "plan_result": "$(json_escape "$plan_result")",
  "solution_value": "$(json_escape "$solution_value")",
  "num_expanded": "$(json_escape "$num_expanded")",
  "num_generated": "$(json_escape "$num_generated")",
  "mp_pruned": "$(json_escape "$mp_pruned")"
}
EOF
}

emit_status_json() {
  cat <<'EOF'
{
  "kind": "status",
  "families": [
    {"family":"blocks-baseline","status":"reproduced"},
    {"family":"hanoi-3","status":"reproduced"},
    {"family":"hanoi-4","status":"partially-reproduced"},
    {"family":"robot-with-user-heuristic","status":"reproduced"},
    {"family":"registers-and-tiny-regressions","status":"reproduced"},
    {"family":"macro-hanoi-variants","status":"reproduced"},
    {"family":"shipped-operator-style-sample-domains","status":"reproduced"},
    {"family":"1991-hanoi-msp-compatibility","status":"reproduced"},
    {"family":"alternate-reset-domain-framework","status":"open"}
  ]
}
EOF
}

emit_report_json() {
  report_name=$1
  file=$2
  title=$(sed -n 's/^# //p' "$file" | head -n 1)
  [ -n "$title" ] || title="$report_name"

  cat <<EOF
{
  "kind": "report",
  "report": "$(json_escape "$report_name")",
  "title": "$(json_escape "$title")",
  "report_markdown": "$(json_escape_multiline "$file")"
}
EOF
}

list_cases() {
  sed -n 's/^  \([a-z0-9][a-z0-9-]*\))$/\1/p' "$SMOKE_SCRIPT"
}

list_reports() {
  cat <<'EOF'
benchmark-status
compare-core
wide-domain-sweep
hanoi3-hierarchies
hanoi3-historical
hanoi4-controls
hanoi4-hierarchies
hanoi4-historical
EOF
}

list_traces() {
  cat <<'EOF'
hanoi3
hanoi4
hanoi4-ismb-weak-pos
hanoi4-isbm-weak-pos
hanoi4-legacy-1991
EOF
}

run_report() {
  report_name=$1

  case "$report_name" in
    benchmark-status)
      sh "$SCRIPT_DIR/benchmark-status-sbcl.sh"
      ;;
    compare-core)
      sh "$SCRIPT_DIR/compare-abtweak-1993-sbcl.sh"
      ;;
    wide-domain-sweep)
      sh "$SCRIPT_DIR/wide-domain-sweep-sbcl.sh"
      ;;
    hanoi3-hierarchies)
      sh "$SCRIPT_DIR/compare-hanoi3-hierarchies-sbcl.sh"
      ;;
    hanoi3-historical)
      sh "$SCRIPT_DIR/compare-hanoi3-historical-controls-sbcl.sh"
      ;;
    hanoi4-controls)
      sh "$SCRIPT_DIR/compare-hanoi4-controls-sbcl.sh"
      ;;
    hanoi4-hierarchies)
      sh "$SCRIPT_DIR/compare-hanoi4-hierarchies-sbcl.sh"
      ;;
    hanoi4-historical)
      sh "$SCRIPT_DIR/compare-hanoi4-historical-controls-sbcl.sh"
      ;;
    *)
      echo "Unknown report: $report_name" >&2
      echo >&2
      echo "Available reports:" >&2
      list_reports >&2
      exit 2
      ;;
  esac
}

run_trace() {
  trace_name=$1

  case "$trace_name" in
    hanoi3)
      sh "$SCRIPT_DIR/trace-hanoi3-sbcl.sh"
      ;;
    hanoi4)
      sh "$SCRIPT_DIR/trace-hanoi4-sbcl.sh"
      ;;
    hanoi4-ismb-weak-pos)
      HIERARCHY=ismb sh "$SCRIPT_DIR/trace-hanoi4-weak-pos-sbcl.sh"
      ;;
    hanoi4-isbm-weak-pos)
      HIERARCHY=isbm sh "$SCRIPT_DIR/trace-hanoi4-weak-pos-sbcl.sh"
      ;;
    hanoi4-legacy-1991)
      HIERARCHY=legacy-1991-default HISTORICAL_MODE=t MSP_MODE=weak MP_WEAK_MODE=pos LEFT_WEDGE_MODE=nil \
        sh "$SCRIPT_DIR/trace-hanoi4-sbcl.sh"
      ;;
    *)
      echo "Unknown trace workflow: $trace_name" >&2
      echo >&2
      echo "Available trace workflows:" >&2
      list_traces >&2
      exit 2
      ;;
  esac
}

COMMAND=${1:-help}

case "$COMMAND" in
  help|-h|--help)
    usage
    ;;
  list)
    topic=${2:-all}
    case "$topic" in
      all)
        cat <<'EOF'
Cases:
EOF
        list_cases
        cat <<'EOF'

Reports:
EOF
        list_reports
        cat <<'EOF'

Traces:
EOF
        list_traces
        ;;
      cases)
        list_cases
        ;;
      reports)
        list_reports
        ;;
      traces)
        list_traces
        ;;
      *)
        echo "Unknown list topic: $topic" >&2
        exit 2
        ;;
    esac
    ;;
  status)
    output_mode=${2:-text}
    case "$output_mode" in
      text)
        sh "$SCRIPT_DIR/benchmark-status-sbcl.sh"
        ;;
      --json)
        emit_status_json
        ;;
      *)
        echo "Unknown status option: $output_mode" >&2
        exit 2
        ;;
    esac
    ;;
  run)
    case_name=${2:-}
    if [ -z "$case_name" ]; then
      echo "Missing case name for run." >&2
      exit 2
    fi
    output_mode=${3:-text}
    case "$output_mode" in
      text)
        exec "$SMOKE_SCRIPT" "$case_name"
        ;;
      --json)
        tmp_file=$(mktemp "${TMPDIR:-/tmp}/abtweak-run.XXXXXX")
        trap 'rm -f "$tmp_file"' EXIT INT TERM
        "$SMOKE_SCRIPT" "$case_name" >"$tmp_file" 2>&1
        emit_run_json "$case_name" "$tmp_file"
        ;;
      *)
        echo "Unknown run option: $output_mode" >&2
        exit 2
        ;;
    esac
    ;;
  report)
    report_name=${2:-}
    if [ -z "$report_name" ]; then
      echo "Missing report name." >&2
      exit 2
    fi
    output_mode=${3:-text}
    case "$output_mode" in
      text)
        run_report "$report_name"
        ;;
      --json)
        tmp_file=$(mktemp "${TMPDIR:-/tmp}/abtweak-report.XXXXXX")
        trap 'rm -f "$tmp_file"' EXIT INT TERM
        run_report "$report_name" >"$tmp_file" 2>&1
        emit_report_json "$report_name" "$tmp_file"
        ;;
      *)
        echo "Unknown report option: $output_mode" >&2
        exit 2
        ;;
    esac
    ;;
  trace)
    trace_name=${2:-}
    if [ -z "$trace_name" ]; then
      echo "Missing trace workflow name." >&2
      exit 2
    fi
    output_mode=${3:-text}
    case "$output_mode" in
      text)
        run_trace "$trace_name"
        ;;
      --json)
        tmp_file=$(mktemp "${TMPDIR:-/tmp}/abtweak-trace.XXXXXX")
        trap 'rm -f "$tmp_file"' EXIT INT TERM
        run_trace "$trace_name" >"$tmp_file" 2>&1
        emit_trace_json "$trace_name" "$tmp_file"
        ;;
      *)
        echo "Unknown trace option: $output_mode" >&2
        exit 2
        ;;
    esac
    ;;
  *)
    echo "Unknown command: $COMMAND" >&2
    echo >&2
    usage >&2
    exit 2
    ;;
esac

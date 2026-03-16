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
  sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh run CASE
  sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh report NAME
  sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh trace NAME

Commands:
  help        Show this help.
  list        Show the standardized experiment surface.
  run         Execute one named smoke case.
  report      Execute one named comparison/report script.
  trace       Execute one named trace workflow.

Examples:
  sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh run blocks-sussman-abtweak
  sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh report compare-core
  HIERARCHY=isbm MP_WEAK_MODE=pos HISTORICAL_MODE=t LEFT_WEDGE_MODE=nil \\
    sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh trace hanoi4
EOF
}

list_cases() {
  sed -n 's/^  \([a-z0-9][a-z0-9-]*\))$/\1/p' "$SMOKE_SCRIPT"
}

list_reports() {
  cat <<'EOF'
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
EOF
}

run_report() {
  report_name=$1

  case "$report_name" in
    compare-core)
      exec "$SCRIPT_DIR/compare-abtweak-1993-sbcl.sh"
      ;;
    wide-domain-sweep)
      exec "$SCRIPT_DIR/wide-domain-sweep-sbcl.sh"
      ;;
    hanoi3-hierarchies)
      exec "$SCRIPT_DIR/compare-hanoi3-hierarchies-sbcl.sh"
      ;;
    hanoi3-historical)
      exec "$SCRIPT_DIR/compare-hanoi3-historical-controls-sbcl.sh"
      ;;
    hanoi4-controls)
      exec "$SCRIPT_DIR/compare-hanoi4-controls-sbcl.sh"
      ;;
    hanoi4-hierarchies)
      exec "$SCRIPT_DIR/compare-hanoi4-hierarchies-sbcl.sh"
      ;;
    hanoi4-historical)
      exec "$SCRIPT_DIR/compare-hanoi4-historical-controls-sbcl.sh"
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
      exec "$SCRIPT_DIR/trace-hanoi3-sbcl.sh"
      ;;
    hanoi4)
      exec "$SCRIPT_DIR/trace-hanoi4-sbcl.sh"
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
  run)
    case_name=${2:-}
    if [ -z "$case_name" ]; then
      echo "Missing case name for run." >&2
      exit 2
    fi
    exec "$SMOKE_SCRIPT" "$case_name"
    ;;
  report)
    report_name=${2:-}
    if [ -z "$report_name" ]; then
      echo "Missing report name." >&2
      exit 2
    fi
    run_report "$report_name"
    ;;
  trace)
    trace_name=${2:-}
    if [ -z "$trace_name" ]; then
      echo "Missing trace workflow name." >&2
      exit 2
    fi
    run_trace "$trace_name"
    ;;
  *)
    echo "Unknown command: $COMMAND" >&2
    echo >&2
    usage >&2
    exit 2
    ;;
esac

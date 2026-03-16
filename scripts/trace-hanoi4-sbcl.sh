#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
WORKDIR="$REPO_ROOT/working/abtweak-1993"
TRACE_ROOT="$REPO_ROOT/analysis/hanoi4-traces"
SBCL_BIN=${SBCL_BIN:-/opt/homebrew/bin/sbcl}
PLANNER_MODE=${PLANNER_MODE:-abtweak}
HIERARCHY=${HIERARCHY:-ismb}
MP_MODE=${MP_MODE:-t}
LEFT_WEDGE_MODE=${LEFT_WEDGE_MODE:-t}
DRP_MODE=${DRP_MODE:-nil}
EXPAND_BOUND=${EXPAND_BOUND:-50000}
GENERATE_BOUND=${GENERATE_BOUND:-200000}
OPEN_BOUND=${OPEN_BOUND:-200000}
CPU_SEC_LIMIT=${CPU_SEC_LIMIT:-60}
OPEN_SNAPSHOT_LIMIT=${OPEN_SNAPSHOT_LIMIT:-200}

timestamp=$(date +"%Y%m%d-%H%M%S")
case_slug="hanoi4-${PLANNER_MODE}-${HIERARCHY}-mp-${MP_MODE}-lw-${LEFT_WEDGE_MODE}-drp-${DRP_MODE}-${timestamp}"
trace_dir="$TRACE_ROOT/$case_slug"
mkdir -p "$trace_dir"

case "$HIERARCHY" in
  critical-list-1)
    CRIT_EXPR='*critical-list-1*'
    LW_EXPR='*k-list-1*'
    ;;
  critical-list-2)
    CRIT_EXPR='*critical-list-2*'
    LW_EXPR='*k-list-2*'
    ;;
  ismb)
    CRIT_EXPR='*ismb*'
    LW_EXPR="'(0 1 3 7)"
    ;;
  imbs)
    CRIT_EXPR='*imbs*'
    LW_EXPR="'(0 1 3 7)"
    ;;
  ibsm)
    CRIT_EXPR='*ibsm*'
    LW_EXPR="'(0 1 3 7)"
    ;;
  isbm)
    CRIT_EXPR='*isbm*'
    LW_EXPR="'(0 1 3 7)"
    ;;
  *)
    echo "Unknown hierarchy: $HIERARCHY" >&2
    exit 2
    ;;
esac

trace_lisp="$trace_dir/trace-run.lisp"
cat >"$trace_lisp" <<EOF
(load "init-sbcl.lisp")
(load "sbcl-trace-utils.lisp")
(load "Domains/hanoi-4.lisp")
(setq *critical-list* $CRIT_EXPR)
(setq *left-wedge-list* $LW_EXPR)
(setq *critical-loaded* $CRIT_EXPR)
(let* ((trace-dir "$trace_dir/")
       (planner-log (concatenate 'string trace-dir "planner-output.txt"))
       (summary-log (concatenate 'string trace-dir "summary.txt"))
       (open-log (concatenate 'string trace-dir "open-frontier.txt"))
       (quality-log (concatenate 'string trace-dir "frontier-quality.txt"))
       (solution-log (concatenate 'string trace-dir "solution.txt"))
       (drp-log (concatenate 'string trace-dir "drp-stack.txt"))
	       (result (plan initial goal
	                     :planner-mode '$PLANNER_MODE
	                     :mp-mode $MP_MODE
	                     :left-wedge-mode $LEFT_WEDGE_MODE
	                     :drp-mode $DRP_MODE
                     :output-file planner-log
                     :expand-bound $EXPAND_BOUND
                     :generate-bound $GENERATE_BOUND
                     :open-bound $OPEN_BOUND
                     :cpu-sec-limit $CPU_SEC_LIMIT)))
  (with-open-file (stream summary-log
                          :direction :output
                          :if-exists :supersede
                          :if-does-not-exist :create)
    (format stream "Case: $case_slug~%")
	    (format stream "Plan result: ~S~%" result)
	    (format stream "Requested planner mode: ~S~%" '$PLANNER_MODE)
	    (format stream "Hierarchy: ~S~%" '$HIERARCHY)
    (format stream "MP mode: ~S~%" '$MP_MODE)
    (format stream "Left-wedge mode: ~S~%" '$LEFT_WEDGE_MODE)
    (format stream "DRP mode: ~S~%" '$DRP_MODE)
    (format stream "Expand bound: ~S~%" $EXPAND_BOUND)
    (format stream "Generate bound: ~S~%" $GENERATE_BOUND)
    (format stream "Open bound: ~S~%" $OPEN_BOUND)
    (format stream "CPU limit: ~S~%" $CPU_SEC_LIMIT)
    (format stream "~%")
    (write-trace-summary stream))
  (write-open-frontier-snapshot open-log :limit $OPEN_SNAPSHOT_LIMIT)
  (write-frontier-quality-snapshot quality-log :limit $OPEN_SNAPSHOT_LIMIT)
  (write-solution-snapshot solution-log)
  (write-drp-stack-snapshot drp-log)
  (format t "TRACE-DIR: ~A~%" trace-dir)
  (format t "PLAN-RESULT: ~S~%" result)
  (format t "SOLUTION-VALUE: ~S~%" *solution*)
  (format t "NUM-EXPANDED: ~S~%" *num-expanded*)
  (format t "NUM-GENERATED: ~S~%" *num-generated*)
  (format t "MP-PRUNED: ~S~%" *mp-pruned*))
EOF

(
  cd "$WORKDIR"
  "$SBCL_BIN" --noinform --disable-debugger --script "$trace_lisp"
)

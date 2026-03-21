#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
WORKDIR="$REPO_ROOT/working/abtweak-1993"
REPLAY_ROOT="$REPO_ROOT/analysis/hanoi4-frontier-replays"
SBCL_BIN=${SBCL_BIN:-/opt/homebrew/bin/sbcl}

PLANNER_MODE=${PLANNER_MODE:-abtweak}
HIERARCHY=${HIERARCHY:-isbm}
HISTORICAL_MODE=${HISTORICAL_MODE:-t}
MP_MODE=${MP_MODE:-t}
MSP_MODE=${MSP_MODE:-weak}
MP_WEAK_MODE=${MP_WEAK_MODE:-pos}
CRIT_DEPTH_MODE=${CRIT_DEPTH_MODE:-nil}
LEFT_WEDGE_MODE=${LEFT_WEDGE_MODE:-t}
DRP_MODE=${DRP_MODE:-nil}
ABSTRACT_GOAL_MODE=${ABSTRACT_GOAL_MODE:-t}
SOURCE_EXPAND_BOUND=${SOURCE_EXPAND_BOUND:-20000}
SOURCE_GENERATE_BOUND=${SOURCE_GENERATE_BOUND:-80000}
SOURCE_OPEN_BOUND=${SOURCE_OPEN_BOUND:-80000}
SOURCE_CPU_SEC_LIMIT=${SOURCE_CPU_SEC_LIMIT:-30}
COHORT_LIMIT=${COHORT_LIMIT:-5}

REPLAY_PLANNER_MODE=${REPLAY_PLANNER_MODE:-$PLANNER_MODE}
REPLAY_MP_MODE=${REPLAY_MP_MODE:-$MP_MODE}
REPLAY_MP_WEAK_MODE=${REPLAY_MP_WEAK_MODE:-$MP_WEAK_MODE}
REPLAY_ABSTRACT_GOAL_MODE=${REPLAY_ABSTRACT_GOAL_MODE:-$ABSTRACT_GOAL_MODE}
REPLAY_LEFT_WEDGE_MODE=${REPLAY_LEFT_WEDGE_MODE:-nil}
REPLAY_DRP_MODE=${REPLAY_DRP_MODE:-nil}
REPLAY_HEURISTIC_MODE=${REPLAY_HEURISTIC_MODE:-user-defined}
REPLAY_CONTROL_STRATEGY=${REPLAY_CONTROL_STRATEGY:-bfs}
REPLAY_EXISTING_ONLY=${REPLAY_EXISTING_ONLY:-nil}
REPLAY_SOLUTION_LIMIT=${REPLAY_SOLUTION_LIMIT:-100}
REPLAY_EXPAND_BOUND=${REPLAY_EXPAND_BOUND:-10000}
REPLAY_GENERATE_BOUND=${REPLAY_GENERATE_BOUND:-50000}
REPLAY_OPEN_BOUND=${REPLAY_OPEN_BOUND:-50000}
REPLAY_CPU_SEC_LIMIT=${REPLAY_CPU_SEC_LIMIT:-30}

timestamp=$(date +"%Y%m%d-%H%M%S")
case_slug="hanoi4-replay-${PLANNER_MODE}-${HIERARCHY}-hist-${HISTORICAL_MODE}-mp-${MP_MODE}-msp-${MSP_MODE}-weak-${MP_WEAK_MODE}-lw-${LEFT_WEDGE_MODE}-${timestamp}"
run_dir="$REPLAY_ROOT/$case_slug"
mkdir -p "$run_dir"

case "$HIERARCHY" in
  legacy-1991-default)
    CRIT_EXPR='*legacy-1991-default*'
    LW_EXPR='*legacy-1991-k-list*'
    ;;
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
  imbs-h1)
    CRIT_EXPR='*imbs-h1*'
    LW_EXPR='*k-list-1*'
    ;;
  imbs-hb)
    CRIT_EXPR='*imbs-hb*'
    LW_EXPR='*k-list-1*'
    ;;
  recursive-clearance)
    CRIT_EXPR='*recursive-clearance*'
    LW_EXPR='*recursive-clearance-k-list*'
    ;;
  ibsm)
    CRIT_EXPR='*ibsm*'
    LW_EXPR="'(0 1 3 7)"
    ;;
  isbm)
    CRIT_EXPR='*isbm*'
    LW_EXPR="'(0 1 3 7)"
    ;;
  isbm-h1)
    CRIT_EXPR='*isbm-h1*'
    LW_EXPR='*k-list-1*'
    ;;
  isbm-hb)
    CRIT_EXPR='*isbm-hb*'
    LW_EXPR='*k-list-1*'
    ;;
  *)
    echo "Unknown hierarchy: $HIERARCHY" >&2
    exit 2
    ;;
esac

replay_lisp="$run_dir/replay-run.lisp"
cat >"$replay_lisp" <<EOF
(load "init-sbcl.lisp")
(load "sbcl-trace-utils.lisp")
(load "historical-hanoi-compat.lisp")
(load "Domains/hanoi-4.lisp")
(setq *critical-list* $CRIT_EXPR)
(setq *left-wedge-list* $LW_EXPR)
(setq *critical-loaded* '$HIERARCHY)

(defun replay-top-bucket-count ()
  (let ((buckets (open-priority-buckets)))
    (if (and buckets (equal *control-strategy* 'bfs))
        (second (first buckets))
      (length (flatten-open-nodes)))))

(let* ((run-dir "$run_dir/")
       (source-summary-path (concatenate 'string run-dir "source-summary.txt"))
       (priority-path (concatenate 'string run-dir "priority-replays.lisp"))
       (closure-path (concatenate 'string run-dir "closure-replays.lisp"))
       (report-path (concatenate 'string run-dir "report.md"))
       (source-result
        (if $HISTORICAL_MODE
            (historical-hanoi4-plan
             initial goal
             :hierarchy '$HIERARCHY
             :planner-mode '$PLANNER_MODE
             :msp-mode '$MSP_MODE
             :msp-weak-mode '$MP_WEAK_MODE
             :crit-depth-mode $CRIT_DEPTH_MODE
             :left-wedge-mode $LEFT_WEDGE_MODE
             :output-file 'no-output
             :expand-bound $SOURCE_EXPAND_BOUND
             :generate-bound $SOURCE_GENERATE_BOUND
             :open-bound $SOURCE_OPEN_BOUND
             :cpu-sec-limit $SOURCE_CPU_SEC_LIMIT)
          (plan initial goal
                :planner-mode '$PLANNER_MODE
                :mp-mode $MP_MODE
                :mp-weak-mode '$MP_WEAK_MODE
                :abstract-goal-mode $ABSTRACT_GOAL_MODE
                :left-wedge-mode $LEFT_WEDGE_MODE
                :drp-mode $DRP_MODE
                :output-file 'no-output
                :expand-bound $SOURCE_EXPAND_BOUND
                :generate-bound $SOURCE_GENERATE_BOUND
                :open-bound $SOURCE_OPEN_BOUND
                :cpu-sec-limit $SOURCE_CPU_SEC_LIMIT)))
       (nodes (flatten-open-nodes))
       (source-summary
        (list
         :source-result source-result
         :source-solution *solution*
         :source-solution-type (type-of *solution*)
         :open-count (length nodes)
         :best-unsat-count (frontier-best-unsat-count nodes)
         :top-bucket-count (replay-top-bucket-count)
         :num-expanded *num-expanded*
         :num-generated *num-generated*
         :mp-pruned *mp-pruned*))
       (priority-records
        (frontier-replay-cohort
         nodes 'priority $COHORT_LIMIT #'frontier-sort-by-priority
         :planner-mode '$REPLAY_PLANNER_MODE
         :mp-mode $REPLAY_MP_MODE
         :mp-weak-mode '$REPLAY_MP_WEAK_MODE
         :abstract-goal-mode $REPLAY_ABSTRACT_GOAL_MODE
         :left-wedge-mode $REPLAY_LEFT_WEDGE_MODE
         :drp-mode $REPLAY_DRP_MODE
         :heuristic-mode '$REPLAY_HEURISTIC_MODE
         :control-strategy '$REPLAY_CONTROL_STRATEGY
         :existing-only $REPLAY_EXISTING_ONLY
         :solution-limit $REPLAY_SOLUTION_LIMIT
         :expand-bound $REPLAY_EXPAND_BOUND
         :generate-bound $REPLAY_GENERATE_BOUND
         :open-bound $REPLAY_OPEN_BOUND
         :cpu-sec-limit $REPLAY_CPU_SEC_LIMIT))
       (closure-records
        (frontier-replay-cohort
         nodes 'closure $COHORT_LIMIT #'frontier-sort-by-unsat-count
         :planner-mode '$REPLAY_PLANNER_MODE
         :mp-mode $REPLAY_MP_MODE
         :mp-weak-mode '$REPLAY_MP_WEAK_MODE
         :abstract-goal-mode $REPLAY_ABSTRACT_GOAL_MODE
         :left-wedge-mode $REPLAY_LEFT_WEDGE_MODE
         :drp-mode $REPLAY_DRP_MODE
         :heuristic-mode '$REPLAY_HEURISTIC_MODE
         :control-strategy '$REPLAY_CONTROL_STRATEGY
         :existing-only $REPLAY_EXISTING_ONLY
         :solution-limit $REPLAY_SOLUTION_LIMIT
         :expand-bound $REPLAY_EXPAND_BOUND
         :generate-bound $REPLAY_GENERATE_BOUND
         :open-bound $REPLAY_OPEN_BOUND
         :cpu-sec-limit $REPLAY_CPU_SEC_LIMIT)))
  (with-open-file (stream source-summary-path
                          :direction :output
                          :if-exists :supersede
                          :if-does-not-exist :create)
    (format stream "~S~%" source-summary))
  (with-open-file (stream priority-path
                          :direction :output
                          :if-exists :supersede
                          :if-does-not-exist :create)
    (format stream "~S~%" priority-records))
  (with-open-file (stream closure-path
                          :direction :output
                          :if-exists :supersede
                          :if-does-not-exist :create)
    (format stream "~S~%" closure-records))
  (write-frontier-replay-report
   report-path
   "Hanoi-4 Frontier Replay"
   source-summary
   priority-records
   closure-records)
  (format t "REPLAY-DIR: ~A~%" run-dir)
  (format t "SOURCE-RESULT: ~S~%" source-result)
  (format t "SOURCE-SOLUTION: ~S~%" (getf source-summary :source-solution))
  (format t "SOURCE-OPEN: ~S~%" (getf source-summary :open-count))
  (format t "PRIORITY-COHORT-SOLVED: ~S~%" (count-if #'replay-solved-p priority-records))
  (format t "CLOSURE-COHORT-SOLVED: ~S~%" (count-if #'replay-solved-p closure-records))
  (format t "PRIORITY-BEST-LEN: ~S~%" (replay-best-solution-length priority-records))
  (format t "CLOSURE-BEST-LEN: ~S~%" (replay-best-solution-length closure-records)))
EOF

(
  cd "$WORKDIR"
  "$SBCL_BIN" --noinform --disable-debugger --script "$replay_lisp"
)

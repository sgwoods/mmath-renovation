#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
WORKDIR="$REPO_ROOT/working/abtweak-1993"
REPORT_ROOT="$REPO_ROOT/analysis/hanoi4-score-sensitivity"
SBCL_BIN=${SBCL_BIN:-/opt/homebrew/bin/sbcl}

SOURCE_EXPAND_BOUND=${SOURCE_EXPAND_BOUND:-10000}
SOURCE_GENERATE_BOUND=${SOURCE_GENERATE_BOUND:-40000}
SOURCE_OPEN_BOUND=${SOURCE_OPEN_BOUND:-40000}
SOURCE_CPU_SEC_LIMIT=${SOURCE_CPU_SEC_LIMIT:-30}
TOP_N=${TOP_N:-20}

timestamp=$(date +"%Y%m%d-%H%M%S")
run_dir="$REPORT_ROOT/hanoi4-score-sensitivity-${timestamp}"
mkdir -p "$run_dir"

report_lisp="$run_dir/report-run.lisp"
cat >"$report_lisp" <<EOF
(load "init-sbcl.lisp")
(load "sbcl-trace-utils.lisp")
(load "historical-hanoi-compat.lisp")
(load "Domains/hanoi-4.lisp")

(configure-historical-hanoi4 'isbm)

(defun summary-averages (records)
  (list
   :count (length records)
   :avg-kval (average-of-key records :plan-kval)
   :avg-cost (average-of-key records :plan-cost)
   :avg-length (average-of-key records :plan-length)
   :avg-unsat (average-of-key records :unsat-count)))

(defun frontier-top-plan-ids (nodes sort-fn count)
  (mapcar #'frontier-plan-id
          (frontier-top-distinct-nodes nodes sort-fn count)))

(defun overlap-count (ids1 ids2)
  (length (intersection ids1 ids2 :test 'equal)))

(defun write-score-sensitivity-report
    (pathname source-summary actual-top-summary closure-top-summary
              actual-top-ranks closure-top-ranks
              actual-averages no-lw-averages unsat-aware-averages
              actual-vs-no-lw-overlap actual-vs-unsat-overlap)
  (with-open-file (stream pathname
                          :direction :output
                          :if-exists :supersede
                          :if-does-not-exist :create)
    (format stream "# Hanoi-4 Score Sensitivity~%~%")
    (format stream "Source configuration: abtweak + isbm + weak-POS + left-wedge~%~%")
    (format stream "## Source Search~%~%")
    (format stream "- Expanded: ~S~%" (getf source-summary :expanded))
    (format stream "- Generated: ~S~%" (getf source-summary :generated))
    (format stream "- Open nodes: ~S~%" (getf source-summary :open-count))
    (format stream "- Best unsatisfied-pair count: ~S~%~%"
            (getf source-summary :best-unsat-count))
    (format stream "## Representative Nodes~%~%")
    (format stream "### Actual Top-Ranked Node~%~%")
    (format stream "- Plan id: ~S~%" (getf actual-top-summary :plan-id))
    (format stream "- Actual priority: ~S~%" (getf actual-top-summary :priority))
    (format stream "- Search cost: ~S~%" (getf actual-top-summary :search-cost))
    (format stream "- Base goal heuristic: ~S~%" (getf actual-top-summary :base-goal-heuristic))
    (format stream "- Left-wedge adjustment: ~S~%" (getf actual-top-summary :left-wedge-adjustment))
    (format stream "- Plan kval: ~S~%" (getf actual-top-summary :plan-kval))
    (format stream "- Plan cost: ~S~%" (getf actual-top-summary :plan-cost))
    (format stream "- Plan length: ~S~%" (getf actual-top-summary :plan-length))
    (format stream "- Unsatisfied-pair count: ~S~%" (getf actual-top-summary :unsat-count))
    (format stream "- Rank under actual score: ~S~%" (getf actual-top-ranks :actual))
    (format stream "- Rank without left-wedge: ~S~%" (getf actual-top-ranks :no-left-wedge))
    (format stream "- Rank under unsat-aware score: ~S~%~%"
            (getf actual-top-ranks :unsat-aware))
    (format stream "### Best Closure-Oriented Node~%~%")
    (format stream "- Plan id: ~S~%" (getf closure-top-summary :plan-id))
    (format stream "- Actual priority: ~S~%" (getf closure-top-summary :priority))
    (format stream "- Search cost: ~S~%" (getf closure-top-summary :search-cost))
    (format stream "- Base goal heuristic: ~S~%" (getf closure-top-summary :base-goal-heuristic))
    (format stream "- Left-wedge adjustment: ~S~%" (getf closure-top-summary :left-wedge-adjustment))
    (format stream "- Plan kval: ~S~%" (getf closure-top-summary :plan-kval))
    (format stream "- Plan cost: ~S~%" (getf closure-top-summary :plan-cost))
    (format stream "- Plan length: ~S~%" (getf closure-top-summary :plan-length))
    (format stream "- Unsatisfied-pair count: ~S~%" (getf closure-top-summary :unsat-count))
    (format stream "- Rank under actual score: ~S~%" (getf closure-top-ranks :actual))
    (format stream "- Rank without left-wedge: ~S~%" (getf closure-top-ranks :no-left-wedge))
    (format stream "- Rank under unsat-aware score: ~S~%~%"
            (getf closure-top-ranks :unsat-aware))
    (format stream "## Top-~D Frontier Averages~%~%" $TOP_N)
    (format stream "| Ranking | Avg kval | Avg cost | Avg length | Avg unsat |~%")
    (format stream "| --- | --- | --- | --- | --- |~%")
    (format stream "| Actual | ~,2F | ~,2F | ~,2F | ~,2F |~%"
            (getf actual-averages :avg-kval)
            (getf actual-averages :avg-cost)
            (getf actual-averages :avg-length)
            (getf actual-averages :avg-unsat))
    (format stream "| No left-wedge | ~,2F | ~,2F | ~,2F | ~,2F |~%"
            (getf no-lw-averages :avg-kval)
            (getf no-lw-averages :avg-cost)
            (getf no-lw-averages :avg-length)
            (getf no-lw-averages :avg-unsat))
    (format stream "| Unsat-aware | ~,2F | ~,2F | ~,2F | ~,2F |~%~%"
            (getf unsat-aware-averages :avg-kval)
            (getf unsat-aware-averages :avg-cost)
            (getf unsat-aware-averages :avg-length)
            (getf unsat-aware-averages :avg-unsat))
    (format stream "## Top-~D Overlap With Actual Ranking~%~%" $TOP_N)
    (format stream "- Actual vs no-left-wedge overlap: ~D / ~D~%"
            actual-vs-no-lw-overlap $TOP_N)
    (format stream "- Actual vs unsat-aware overlap: ~D / ~D~%~%"
            actual-vs-unsat-overlap $TOP_N)
    (format stream "## Interpretation~%~%")
    (format stream "- If the best closure-oriented node rises sharply when left-wedge is removed, the ranking pressure is dominated by refinement bias.~%")
    (format stream "- If it rises sharply again under an unsat-aware score, then the current score is also blind to unresolved obligations that matter for closure.~%")
    (format stream "- Large top-~D average differences indicate that the score shape is selecting a qualitatively different frontier, not just reordering similar plans.~%" $TOP_N)))

(let* ((report-path (concatenate 'string "$run_dir/" "report.md"))
       (result (historical-hanoi4-plan
                initial goal
                :hierarchy 'isbm
                :planner-mode 'abtweak
                :msp-mode 'weak
                :msp-weak-mode 'pos
                :left-wedge-mode t
                :output-file 'no-output
                :expand-bound $SOURCE_EXPAND_BOUND
                :generate-bound $SOURCE_GENERATE_BOUND
                :open-bound $SOURCE_OPEN_BOUND
                :cpu-sec-limit $SOURCE_CPU_SEC_LIMIT))
       (nodes (flatten-open-nodes))
       (actual-sorted (frontier-sort-by-priority nodes))
       (closure-sorted (frontier-sort-by-unsat-count nodes))
       (no-lw-sorted (frontier-sort-by-score nodes #'frontier-no-left-wedge-score))
       (unsat-aware-sorted (frontier-sort-by-score nodes #'frontier-unsat-aware-score))
       (actual-top (first actual-sorted))
       (closure-top (first closure-sorted))
       (actual-top-summary (frontier-node-quality-summary actual-top))
       (closure-top-summary (frontier-node-quality-summary closure-top))
       (actual-top-ranks
        (list
         :actual (frontier-rank-of-plan-id actual-sorted (frontier-plan-id actual-top))
         :no-left-wedge (frontier-rank-of-plan-id no-lw-sorted (frontier-plan-id actual-top))
         :unsat-aware (frontier-rank-of-plan-id unsat-aware-sorted (frontier-plan-id actual-top))))
       (closure-top-ranks
        (list
         :actual (frontier-rank-of-plan-id actual-sorted (frontier-plan-id closure-top))
         :no-left-wedge (frontier-rank-of-plan-id no-lw-sorted (frontier-plan-id closure-top))
         :unsat-aware (frontier-rank-of-plan-id unsat-aware-sorted (frontier-plan-id closure-top))))
       (actual-averages
        (summary-averages
         (frontier-top-n-summaries nodes #'frontier-sort-by-priority $TOP_N)))
       (no-lw-averages
        (summary-averages
         (frontier-top-n-summaries nodes
                                   #'(lambda (frontier)
                                       (frontier-sort-by-score frontier #'frontier-no-left-wedge-score))
                                   $TOP_N)))
       (unsat-aware-averages
        (summary-averages
         (frontier-top-n-summaries nodes
                                   #'(lambda (frontier)
                                       (frontier-sort-by-score frontier #'frontier-unsat-aware-score))
                                   $TOP_N)))
       (actual-vs-no-lw-overlap
        (overlap-count
         (frontier-top-plan-ids nodes #'frontier-sort-by-priority $TOP_N)
         (frontier-top-plan-ids nodes
                                #'(lambda (frontier)
                                    (frontier-sort-by-score frontier #'frontier-no-left-wedge-score))
                                $TOP_N)))
       (actual-vs-unsat-overlap
        (overlap-count
         (frontier-top-plan-ids nodes #'frontier-sort-by-priority $TOP_N)
         (frontier-top-plan-ids nodes
                                #'(lambda (frontier)
                                    (frontier-sort-by-score frontier #'frontier-unsat-aware-score))
                                $TOP_N)))
       (source-summary
        (list :result result
              :solution *solution*
              :expanded *num-expanded*
              :generated *num-generated*
              :open-count (length nodes)
              :best-unsat-count (frontier-best-unsat-count nodes))))
  (write-score-sensitivity-report
   report-path
   source-summary
   actual-top-summary
   closure-top-summary
   actual-top-ranks
   closure-top-ranks
   actual-averages
   no-lw-averages
   unsat-aware-averages
   actual-vs-no-lw-overlap
   actual-vs-unsat-overlap)
  (format t "REPORT-DIR: ~A~%" "$run_dir/")
  (format t "REPORT-PATH: ~A~%" report-path)
  (format t "ACTUAL-TOP-RANK-NO-LW: ~S~%" (getf actual-top-ranks :no-left-wedge))
  (format t "CLOSURE-TOP-RANK-ACTUAL: ~S~%" (getf closure-top-ranks :actual))
  (format t "CLOSURE-TOP-RANK-NO-LW: ~S~%" (getf closure-top-ranks :no-left-wedge))
  (format t "CLOSURE-TOP-RANK-UNSAT-AWARE: ~S~%" (getf closure-top-ranks :unsat-aware))
  (format t "ACTUAL-VS-NO-LW-OVERLAP: ~S~%" actual-vs-no-lw-overlap)
  (format t "ACTUAL-VS-UNSAT-OVERLAP: ~S~%" actual-vs-unsat-overlap))
EOF

tmp_output=$(mktemp "${TMPDIR:-/tmp}/h4-score-sensitivity.XXXXXX")
trap 'rm -f "$tmp_output"' EXIT INT TERM

(
  cd "$WORKDIR"
  "$SBCL_BIN" --noinform --disable-debugger --script "$report_lisp"
) >"$tmp_output"

report_path=$(sed -n 's/^REPORT-PATH: //p' "$tmp_output" | head -n 1)

if [ -z "$report_path" ] || [ ! -f "$report_path" ]; then
  cat "$tmp_output"
  exit 1
fi

cat "$report_path"

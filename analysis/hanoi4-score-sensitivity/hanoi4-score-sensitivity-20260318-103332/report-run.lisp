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
    (format stream "Source configuration: ~%~%")
    (format stream "## Source Search~%~%")
    (format stream "- Expanded: ~%" (getf source-summary :expanded))
    (format stream "- Generated: ~%" (getf source-summary :generated))
    (format stream "- Open nodes: ~%" (getf source-summary :open-count))
    (format stream "- Best unsatisfied-pair count: ~%~%"
            (getf source-summary :best-unsat-count))
    (format stream "## Representative Nodes~%~%")
    (format stream "### Actual Top-Ranked Node~%~%")
    (format stream "- Plan id: ~%" (getf actual-top-summary :plan-id))
    (format stream "- Actual priority: ~%" (getf actual-top-summary :priority))
    (format stream "- Search cost: ~%" (getf actual-top-summary :search-cost))
    (format stream "- Base goal heuristic: ~%" (getf actual-top-summary :base-goal-heuristic))
    (format stream "- Left-wedge adjustment: ~%" (getf actual-top-summary :left-wedge-adjustment))
    (format stream "- Plan kval: ~%" (getf actual-top-summary :plan-kval))
    (format stream "- Plan cost: ~%" (getf actual-top-summary :plan-cost))
    (format stream "- Plan length: ~%" (getf actual-top-summary :plan-length))
    (format stream "- Unsatisfied-pair count: ~%" (getf actual-top-summary :unsat-count))
    (format stream "- Rank under actual score: ~%" (getf actual-top-ranks :actual))
    (format stream "- Rank without left-wedge: ~%" (getf actual-top-ranks :no-left-wedge))
    (format stream "- Rank under unsat-aware score: ~%~%"
            (getf actual-top-ranks :unsat-aware))
    (format stream "### Best Closure-Oriented Node~%~%")
    (format stream "- Plan id: ~%" (getf closure-top-summary :plan-id))
    (format stream "- Actual priority: ~%" (getf closure-top-summary :priority))
    (format stream "- Search cost: ~%" (getf closure-top-summary :search-cost))
    (format stream "- Base goal heuristic: ~%" (getf closure-top-summary :base-goal-heuristic))
    (format stream "- Left-wedge adjustment: ~%" (getf closure-top-summary :left-wedge-adjustment))
    (format stream "- Plan kval: ~%" (getf closure-top-summary :plan-kval))
    (format stream "- Plan cost: ~%" (getf closure-top-summary :plan-cost))
    (format stream "- Plan length: ~%" (getf closure-top-summary :plan-length))
    (format stream "- Unsatisfied-pair count: ~%" (getf closure-top-summary :unsat-count))
    (format stream "- Rank under actual score: ~%" (getf closure-top-ranks :actual))
    (format stream "- Rank without left-wedge: ~%" (getf closure-top-ranks :no-left-wedge))
    (format stream "- Rank under unsat-aware score: ~%~%"
            (getf closure-top-ranks :unsat-aware))
    (format stream "## Top-~D Frontier Averages~%~%" 20)
    (format stream "| Ranking | Avg kval | Avg cost | Avg length | Avg unsat |~%")
    (format stream "| --- | --- | --- | --- | --- |~%")
    (format stream "| Actual |  |  |  |  |~%"
            (getf actual-averages :avg-kval)
            (getf actual-averages :avg-cost)
            (getf actual-averages :avg-length)
            (getf actual-averages :avg-unsat))
    (format stream "| No left-wedge |  |  |  |  |~%"
            (getf no-lw-averages :avg-kval)
            (getf no-lw-averages :avg-cost)
            (getf no-lw-averages :avg-length)
            (getf no-lw-averages :avg-unsat))
    (format stream "| Unsat-aware |  |  |  |  |~%~%"
            (getf unsat-aware-averages :avg-kval)
            (getf unsat-aware-averages :avg-cost)
            (getf unsat-aware-averages :avg-length)
            (getf unsat-aware-averages :avg-unsat))
    (format stream "## Top-~D Overlap With Actual Ranking~%~%" 20)
    (format stream "- Actual vs no-left-wedge overlap: ~%"
            actual-vs-no-lw-overlap 20)
    (format stream "- Actual vs unsat-aware overlap: ~%~%"
            actual-vs-unsat-overlap 20)
    (format stream "## Interpretation~%~%")
    (format stream "- If the best closure-oriented node rises sharply when left-wedge is removed, the ranking pressure is dominated by refinement bias.~%")
    (format stream "- If it rises sharply again under an unsat-aware score, then the current score is also blind to unresolved obligations that matter for closure.~%")
    (format stream "- Large top-~D average differences indicate that the score shape is selecting a qualitatively different frontier, not just reordering similar plans.~%" 20)))

(let* ((report-path (concatenate 'string "/Users/stevenwoods/mmath-renovation/analysis/hanoi4-score-sensitivity/hanoi4-score-sensitivity-20260318-103332/" "report.md"))
       (result (historical-hanoi4-plan
                initial goal
                :hierarchy 'isbm
                :planner-mode 'abtweak
                :msp-mode 'weak
                :msp-weak-mode 'pos
                :left-wedge-mode t
                :output-file 'no-output
                :expand-bound 10000
                :generate-bound 40000
                :open-bound 40000
                :cpu-sec-limit 30))
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
         (frontier-top-n-summaries nodes #'frontier-sort-by-priority 20)))
       (no-lw-averages
        (summary-averages
         (frontier-top-n-summaries nodes
                                   #'(lambda (frontier)
                                       (frontier-sort-by-score frontier #'frontier-no-left-wedge-score))
                                   20)))
       (unsat-aware-averages
        (summary-averages
         (frontier-top-n-summaries nodes
                                   #'(lambda (frontier)
                                       (frontier-sort-by-score frontier #'frontier-unsat-aware-score))
                                   20)))
       (actual-vs-no-lw-overlap
        (overlap-count
         (frontier-top-plan-ids nodes #'frontier-sort-by-priority 20)
         (frontier-top-plan-ids nodes
                                #'(lambda (frontier)
                                    (frontier-sort-by-score frontier #'frontier-no-left-wedge-score))
                                20)))
       (actual-vs-unsat-overlap
        (overlap-count
         (frontier-top-plan-ids nodes #'frontier-sort-by-priority 20)
         (frontier-top-plan-ids nodes
                                #'(lambda (frontier)
                                    (frontier-sort-by-score frontier #'frontier-unsat-aware-score))
                                20)))
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
  (format t "REPORT-DIR: ~A~%" "/Users/stevenwoods/mmath-renovation/analysis/hanoi4-score-sensitivity/hanoi4-score-sensitivity-20260318-103332/")
  (format t "REPORT-PATH: ~A~%" report-path)
  (format t "ACTUAL-TOP-RANK-NO-LW: ~S~%" (getf actual-top-ranks :no-left-wedge))
  (format t "CLOSURE-TOP-RANK-ACTUAL: ~S~%" (getf closure-top-ranks :actual))
  (format t "CLOSURE-TOP-RANK-NO-LW: ~S~%" (getf closure-top-ranks :no-left-wedge))
  (format t "CLOSURE-TOP-RANK-UNSAT-AWARE: ~S~%" (getf closure-top-ranks :unsat-aware))
  (format t "ACTUAL-VS-NO-LW-OVERLAP: ~S~%" actual-vs-no-lw-overlap)
  (format t "ACTUAL-VS-UNSAT-OVERLAP: ~S~%" actual-vs-unsat-overlap))

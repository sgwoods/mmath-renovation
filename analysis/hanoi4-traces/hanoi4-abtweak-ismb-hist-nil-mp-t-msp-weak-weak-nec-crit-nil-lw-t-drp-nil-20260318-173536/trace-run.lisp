(load "init-sbcl.lisp")
(load "sbcl-trace-utils.lisp")
(load "historical-hanoi-compat.lisp")
(load "Domains/hanoi-4.lisp")
(setq *critical-list* *ismb*)
(setq *left-wedge-list* '(0 1 3 7))
(setq *critical-loaded* *ismb*)
(let* ((trace-dir "/Users/stevenwoods/mmath-renovation/analysis/hanoi4-traces/hanoi4-abtweak-ismb-hist-nil-mp-t-msp-weak-weak-nec-crit-nil-lw-t-drp-nil-20260318-173536/")
       (planner-log (concatenate 'string trace-dir "planner-output.txt"))
       (summary-log (concatenate 'string trace-dir "summary.txt"))
       (open-log (concatenate 'string trace-dir "open-frontier.txt"))
       (quality-log (concatenate 'string trace-dir "frontier-quality.txt"))
       (score-log (concatenate 'string trace-dir "insertion-score-trace.txt"))
       (score-report-log (concatenate 'string trace-dir "insertion-score-report.md"))
       (lineage-report-log (concatenate 'string trace-dir "lineage-report.md"))
       (solution-log (concatenate 'string trace-dir "solution.txt"))
       (drp-log (concatenate 'string trace-dir "drp-stack.txt"))
       (result (progn
                 (reset-score-trace :limit 5000)
                 (if nil
                           (historical-hanoi4-plan initial goal
	                                             :hierarchy 'ismb
                                                     :planner-mode 'abtweak
                                                     :msp-mode 'weak
                                                     :msp-weak-mode 'nec
                                                     :crit-depth-mode nil
                                                     :left-wedge-mode t
                                                     :output-file planner-log
                                                     :expand-bound 50000
                                                     :generate-bound 200000
                                                     :open-bound 200000
                                                     :cpu-sec-limit 60)
                         (plan initial goal
	                       :planner-mode 'abtweak
	                       :mp-mode t
                               :mp-weak-mode 'nec
	                       :left-wedge-mode t
                       :drp-mode nil
                               :output-file planner-log
                               :expand-bound 50000
	                       :generate-bound 200000
	                       :open-bound 200000
	                       :cpu-sec-limit 60)))))
  (with-open-file (stream summary-log
                          :direction :output
                          :if-exists :supersede
                          :if-does-not-exist :create)
    (format stream "Case: hanoi4-abtweak-ismb-hist-nil-mp-t-msp-weak-weak-nec-crit-nil-lw-t-drp-nil-20260318-173536~%")
	    (format stream "Plan result: ~S~%" result)
	    (format stream "Requested planner mode: ~S~%" 'abtweak)
	    (format stream "Hierarchy: ~S~%" 'ismb)
    (format stream "Historical mode: ~S~%" nil)
    (format stream "MP mode: ~S~%" 't)
    (format stream "MSP mode: ~S~%" 'weak)
    (format stream "MP weak mode: ~S~%" 'nec)
    (format stream "Crit-depth mode: ~S~%" 'nil)
    (format stream "Left-wedge mode: ~S~%" 't)
    (format stream "DRP mode: ~S~%" 'nil)
    (format stream "Expand bound: ~S~%" 50000)
    (format stream "Generate bound: ~S~%" 200000)
    (format stream "Open bound: ~S~%" 200000)
    (format stream "CPU limit: ~S~%" 60)
    (format stream "~%")
    (write-trace-summary stream))
  (write-open-frontier-snapshot open-log :limit 200)
  (write-frontier-quality-snapshot quality-log :limit 200)
  (write-score-trace-snapshot score-log :limit 200)
  (write-score-trace-report score-report-log)
  (write-score-trace-lineage-report lineage-report-log :count 3)
  (disable-score-trace)
  (write-solution-snapshot solution-log)
  (write-drp-stack-snapshot drp-log)
  (format t "TRACE-DIR: ~A~%" trace-dir)
  (format t "PLAN-RESULT: ~S~%" result)
  (format t "SOLUTION-VALUE: ~S~%" *solution*)
  (format t "NUM-EXPANDED: ~S~%" *num-expanded*)
  (format t "NUM-GENERATED: ~S~%" *num-generated*)
  (format t "MP-PRUNED: ~S~%" *mp-pruned*))

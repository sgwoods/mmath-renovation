(load "init-sbcl.lisp")
(load "sbcl-trace-utils.lisp")
(load "Domains/hanoi-3.lisp")
(setq *critical-list* *critical-list-1*)
(setq *left-wedge-list* *k-list-1*)
(setq *critical-loaded* *critical-list-1*)
(let* ((trace-dir "/Users/stevenwoods/mmath-renovation/analysis/hanoi3-traces/hanoi3-abtweak-critical-list-1-mp-t-lw-t-drp-nil-20260316-155044/")
       (planner-log (concatenate 'string trace-dir "planner-output.txt"))
       (summary-log (concatenate 'string trace-dir "summary.txt"))
       (open-log (concatenate 'string trace-dir "open-frontier.txt"))
       (quality-log (concatenate 'string trace-dir "frontier-quality.txt"))
       (solution-log (concatenate 'string trace-dir "solution.txt"))
       (drp-log (concatenate 'string trace-dir "drp-stack.txt"))
       (result (plan initial goal
                     :planner-mode 'abtweak
                     :mp-mode t
                     :left-wedge-mode t
                     :drp-mode nil
                     :output-file planner-log
                     :expand-bound 5000
                     :generate-bound 20000
                     :open-bound 20000
                     :cpu-sec-limit 30)))
  (with-open-file (stream summary-log
                          :direction :output
                          :if-exists :supersede
                          :if-does-not-exist :create)
    (format stream "Case: hanoi3-abtweak-critical-list-1-mp-t-lw-t-drp-nil-20260316-155044~%")
    (format stream "Plan result: ~S~%" result)
    (format stream "Requested planner mode: ~S~%" 'abtweak)
    (format stream "Hierarchy: ~S~%" 'critical-list-1)
    (format stream "MP mode: ~S~%" 't)
    (format stream "Left-wedge mode: ~S~%" 't)
    (format stream "DRP mode: ~S~%" 'nil)
    (format stream "Expand bound: ~S~%" 5000)
    (format stream "Generate bound: ~S~%" 20000)
    (format stream "Open bound: ~S~%" 20000)
    (format stream "CPU limit: ~S~%" 30)
    (format stream "~%")
    (write-trace-summary stream))
  (write-open-frontier-snapshot open-log :limit 120)
  (write-frontier-quality-snapshot quality-log :limit 120)
  (write-solution-snapshot solution-log)
  (write-drp-stack-snapshot drp-log)
  (format t "TRACE-DIR: ~A~%" trace-dir)
  (format t "PLAN-RESULT: ~S~%" result)
  (format t "SOLUTION-VALUE: ~S~%" *solution*)
  (format t "NUM-EXPANDED: ~S~%" *num-expanded*)
  (format t "NUM-GENERATED: ~S~%" *num-generated*)
  (format t "MP-PRUNED: ~S~%" *mp-pruned*))

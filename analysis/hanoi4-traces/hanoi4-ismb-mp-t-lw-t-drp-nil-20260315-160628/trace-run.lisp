(load "init-sbcl.lisp")
(load "sbcl-trace-utils.lisp")
(load "Domains/hanoi-4.lisp")
(setq *critical-list* *ismb*)
(setq *left-wedge-list* '(0 1 3 7))
(setq *critical-loaded* *ismb*)
(let* ((trace-dir "/Users/stevenwoods/mmath-renovation/analysis/hanoi4-traces/hanoi4-ismb-mp-t-lw-t-drp-nil-20260315-160628/")
       (planner-log (concatenate 'string trace-dir "planner-output.txt"))
       (summary-log (concatenate 'string trace-dir "summary.txt"))
       (open-log (concatenate 'string trace-dir "open-frontier.txt"))
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
                     :cpu-sec-limit 20)))
  (with-open-file (stream summary-log
                          :direction :output
                          :if-exists :supersede
                          :if-does-not-exist :create)
    (format stream "Case: hanoi4-ismb-mp-t-lw-t-drp-nil-20260315-160628~%")
    (format stream "Plan result: ~S~%" result)
    (format stream "Hierarchy: ~S~%" 'ismb)
    (format stream "MP mode: ~S~%" 't)
    (format stream "Left-wedge mode: ~S~%" 't)
    (format stream "DRP mode: ~S~%" 'nil)
    (format stream "Expand bound: ~S~%" 5000)
    (format stream "Generate bound: ~S~%" 20000)
    (format stream "Open bound: ~S~%" 20000)
    (format stream "CPU limit: ~S~%" 20)
    (format stream "~%")
    (write-trace-summary stream))
  (write-open-frontier-snapshot open-log :limit 20)
  (write-solution-snapshot solution-log)
  (write-drp-stack-snapshot drp-log)
  (format t "TRACE-DIR: ~A~%" trace-dir)
  (format t "PLAN-RESULT: ~S~%" result)
  (format t "SOLUTION-VALUE: ~S~%" *solution*)
  (format t "NUM-EXPANDED: ~S~%" *num-expanded*)
  (format t "NUM-GENERATED: ~S~%" *num-generated*)
  (format t "MP-PRUNED: ~S~%" *mp-pruned*))

(load "init-sbcl.lisp")
(load "sbcl-trace-utils.lisp")
(load "historical-hanoi-compat.lisp")
(load "Domains/hanoi-4.lisp")
(setq *critical-list* *isbm*)
(setq *left-wedge-list* '(0 1 3 7))
(setq *critical-loaded* 'isbm)

(defun replay-top-bucket-count ()
  (let ((buckets (open-priority-buckets)))
    (if (and buckets (equal *control-strategy* 'bfs))
        (second (first buckets))
      (length (flatten-open-nodes)))))

(let* ((run-dir "/Users/stevenwoods/mmath-renovation/analysis/hanoi4-frontier-replays/hanoi4-replay-abtweak-isbm-hist-t-mp-t-msp-weak-weak-pos-lw-t-20260317-164841/")
       (source-summary-path (concatenate 'string run-dir "source-summary.txt"))
       (priority-path (concatenate 'string run-dir "priority-replays.lisp"))
       (closure-path (concatenate 'string run-dir "closure-replays.lisp"))
       (report-path (concatenate 'string run-dir "report.md"))
       (source-result
        (if t
            (historical-hanoi4-plan
             initial goal
             :hierarchy 'isbm
             :planner-mode 'abtweak
             :msp-mode 'weak
             :msp-weak-mode 'pos
             :crit-depth-mode nil
             :left-wedge-mode t
             :output-file 'no-output
             :expand-bound 10000
             :generate-bound 40000
             :open-bound 40000
             :cpu-sec-limit 30)
          (plan initial goal
                :planner-mode 'abtweak
                :mp-mode t
                :mp-weak-mode 'pos
                :abstract-goal-mode t
                :left-wedge-mode t
                :drp-mode nil
                :output-file 'no-output
                :expand-bound 10000
                :generate-bound 40000
                :open-bound 40000
                :cpu-sec-limit 30)))
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
         nodes 'priority 5 #'frontier-sort-by-priority
         :planner-mode 'abtweak
         :mp-mode t
         :mp-weak-mode 'pos
         :abstract-goal-mode t
         :left-wedge-mode nil
         :drp-mode nil
         :heuristic-mode 'user-defined
         :control-strategy 'bfs
         :existing-only nil
         :solution-limit 100
         :expand-bound 1000
         :generate-bound 5000
         :open-bound 5000
         :cpu-sec-limit 30))
       (closure-records
        (frontier-replay-cohort
         nodes 'closure 5 #'frontier-sort-by-unsat-count
         :planner-mode 'abtweak
         :mp-mode t
         :mp-weak-mode 'pos
         :abstract-goal-mode t
         :left-wedge-mode nil
         :drp-mode nil
         :heuristic-mode 'user-defined
         :control-strategy 'bfs
         :existing-only nil
         :solution-limit 100
         :expand-bound 1000
         :generate-bound 5000
         :open-bound 5000
         :cpu-sec-limit 30)))
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

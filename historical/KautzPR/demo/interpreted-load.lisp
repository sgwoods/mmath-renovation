;; You are running the demo program.  Hit <space> or y after each command
;; is printed to execute that command.  Hit n to skip that command, q
;; to quit, and e to enter an immediate expression for evaluation.

;;;; Imp-dir is set to the directory containing the implementation.
(setq *imp-dir*
   (translate-pathname "/usr/kautz/lisp/phd/imp/low-level.lisp"))
;; Test-dir is set to the directory containing the hierarchies.
(setq *test-dir*
   (translate-pathname "/usr/kautz/lisp/phd/test/cook-test1.lisp"))

;;;; Load the implementation.
(load (merge-pathnames "low-level" imp-dir))
(load (merge-pathnames "database" imp-dir))
(load (merge-pathnames "upward-infer" imp-dir))
(load (merge-pathnames "eq-constraints" imp-dir))
(load (merge-pathnames "time-constraints" imp-dir))
(load (merge-pathnames "matcher" imp-dir))
(load (merge-pathnames "update" imp-dir))
(load (merge-pathnames "list-matcher" imp-dir))
(load (merge-pathnames "parse-sentence" imp-dir))


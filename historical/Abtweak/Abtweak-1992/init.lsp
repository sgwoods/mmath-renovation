; /planner/init.lsp


; load object code files or lisp code files

; Load Search Routines
(load  "Search-routines/init")

; Load TWEAK
(load "Tw-routines/init")

; Load ABTWEAK
(load "Ab-routines/init")

; Load user defined heuristic
(load "My-routines/heuristic")

; Load Domain definitions
(load "Domains/hanoi-3")

(load "Plan-routines/init-global-vars")
(load "Plan-routines/planner-interface")
(load "Plan-routines/planner-heuristic")

(load "plan")

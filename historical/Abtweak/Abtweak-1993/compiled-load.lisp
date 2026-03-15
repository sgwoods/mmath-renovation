; /planner/init.lsp


; load object code files or lisp code files

; Load Search Routines
(load  "./Search-routines/compiled-load")

; Load TWEAK
(load "./Tw-routines/compiled-load")

; Load ABTWEAK
(load "./Ab-routines/compiled-load")

; Load user defined heuristic
(load "./My-routines/heuristic")

; Load Domain definitions
(load "./Domains/check-primary-effects")
(load "./Domains/hanoi-3.lsp")

(load "./Plan-routines/init-global-vars")
(load "./Plan-routines/planner-interface")
(load "./Plan-routines/planner-heuristic")

(load "./Mcallester-plan/compiled-load")

(load "./plan")


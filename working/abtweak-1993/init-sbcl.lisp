; SBCL-friendly source loader for the AbTweak 1993 working baseline.
; This keeps the historical init file intact while loading globals a bit
; earlier to reduce avoidable source-load issues on modern CLs.

; Establish common historical specials before source loading.
(load "sbcl-specials.lisp")

; Load TWEAK core first so plan/operator structs exist.
(load "Tw-routines/init")

; Load planner globals before search/planner source to establish specials.
(load "Plan-routines/init-global-vars")

; Load search and planner-specific layers.
(load "Search-routines/init")
(load "Ab-routines/init")
(load "My-routines/heuristic")
(load "Domains/check-primary-effects")
(load "Domains/hanoi-3")
(load "Plan-routines/planner-interface")
(load "Plan-routines/planner-heuristic")
(load "Mcallester-plan/init")
(load "plan")

; /planner/compile.lsp

; compile Search Routines
(load  "Search-routines/compile")

; compile TWEAK
(load "Tw-routines/compile")

; compile ABTWEAK
(load "Ab-routines/compile")

; compile user defined heuristic
(compile-file "My-routines/heuristic")

; compile Mcallester
(load "Mcallester-plan/compile")

(compile-file "Plan-routines/init-global-vars")

(compile-file "Plan-routines/planner-interface")
(compile-file "Plan-routines/planner-heuristic")

(compile-file "plan")

; load compiled version now
(load "init")


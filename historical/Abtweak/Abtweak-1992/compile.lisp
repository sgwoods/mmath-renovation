; /planner/compile.lsp

;; (proclaim '(optimize (compilation-speed 3)))  development
;; (proclaim '(optimize (compilation-speed 0)))  production

(proclaim '(optimize (compilation-speed 0)))

; compile Search Routines
(load  "Search-routines/compile")

; compile TWEAK
(load "Tw-routines/compile")

; compile ABTWEAK
(load "Ab-routines/compile")

; compile user defined heuristic
(compile-file "My-routines/heuristic")


(compile-file "Plan-routines/init-global-vars")

(compile-file "Plan-routines/planner-interface")
(compile-file "Plan-routines/planner-heuristic")

(compile-file "plan")

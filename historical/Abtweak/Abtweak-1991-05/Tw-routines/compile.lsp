; this file resides in:
; /tweak/init.lsp

; compile-file in general routines.
(compile-file "Tw-routines/general")

; compile-file in the plan structure definitions and plan specific functions
(compile-file "Tw-routines/structs")   

; compile-file mtc inference routines.
(compile-file "Tw-routines/mtc")

; compile-file successors generation routines.
(compile-file "Tw-routines/successors")
(compile-file "Tw-routines/tw-heuristic")

; tweak/Succ/
;
(compile-file "Tw-routines/Succ/find-new-ests")
(compile-file "Tw-routines/Succ/select-ops")
(compile-file "Tw-routines/Succ/find-exist-ests")
(compile-file "Tw-routines/Succ/find-pos-exist-ests")
(compile-file "Tw-routines/Succ/find-nec-exist-ests")

; tweak/Conf-infer/ . compile-file conflict  inference routines.  
;
(compile-file "Tw-routines/Conf-infer/classify")
(compile-file "Tw-routines/Conf-infer/declob")
(compile-file "Tw-routines/Conf-infer/conflict-detection")
(compile-file "Tw-routines/Conf-infer/intermed-access")

; tweak/Plan-infer: plan inference and modification routines.
;
(compile-file "Tw-routines/Plan-infer/plan-dependent")
(compile-file "Tw-routines/Plan-infer/plan-inference")
(compile-file "Tw-routines/Plan-infer/cr-access")
(compile-file "Tw-routines/Plan-infer/plan-modification")
(compile-file "Tw-routines/Plan-infer/show-plan")

; compile-file in the tweak main-planner interface routines.
;
(compile-file "Tw-routines/tweak-planner-interface")
(compile-file "Tw-routines/tw-heuristic")


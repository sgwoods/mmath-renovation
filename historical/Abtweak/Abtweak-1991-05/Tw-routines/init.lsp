; this file resides in:
; /tweak/init.lsp

; load in general routines.
(load "Tw-routines/general")

; load in the plan structure definitions and plan specific functions
(load "Tw-routines/structs")   

; load mtc inference routines.
(load "Tw-routines/mtc")

; load successors generation routines.
(load "Tw-routines/successors")
(load "Tw-routines/tw-heuristic")

; tweak/Succ/
;
(load "Tw-routines/Succ/find-new-ests")
(load "Tw-routines/Succ/select-ops")
(load "Tw-routines/Succ/find-exist-ests")
(load "Tw-routines/Succ/find-pos-exist-ests")
(load "Tw-routines/Succ/find-nec-exist-ests")

; tweak/Conf-infer/ . load conflict  inference routines.  
;
(load "Tw-routines/Conf-infer/classify")
(load "Tw-routines/Conf-infer/declob")
(load "Tw-routines/Conf-infer/conflict-detection")
(load "Tw-routines/Conf-infer/intermed-access")

; tweak/Plan-infer: plan inference and modification routines.
;
(load "Tw-routines/Plan-infer/plan-dependent")
(load "Tw-routines/Plan-infer/plan-inference")
(load "Tw-routines/Plan-infer/cr-access")
(load "Tw-routines/Plan-infer/plan-modification")
(load "Tw-routines/Plan-infer/show-plan")

; load in the tweak main-planner interface routines.
;
(load "Tw-routines/tweak-planner-interface")
(load "Tw-routines/tw-heuristic")


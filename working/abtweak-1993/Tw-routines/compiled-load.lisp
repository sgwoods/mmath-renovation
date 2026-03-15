; this file resides in:
; /tweak/init.lsp

; load in general routines.
(load "./general")

; load in the plan structure definitions and plan specific functions
(load "./structs")   

; load mtc inference routines.
(load "./mtc")

; load successors generation routines.
(load "./successors")
(load "./tw-heuristic")

; tweak/Succ/
;
(load "./Succ/find-new-ests")
(load "./Succ/select-ops")
(load "./Succ/find-exist-ests")
(load "./Succ/find-pos-exist-ests")
(load "./Succ/find-nec-exist-ests")

; tweak/Conf-infer/ . load conflict  inference routines.  
;
(load "./Conf-infer/classify")
(load "./Conf-infer/declob")
(load "./Conf-infer/conflict-detection")
(load "./Conf-infer/intermed-access")

; tweak/Plan-infer: plan inference and modification routines.
;
(load "./Plan-infer/plan-dependent")
(load "./Plan-infer/plan-inference")
(load "./Plan-infer/cr-access")
(load "./Plan-infer/plan-modification")
(load "./Plan-infer/show-plan")

; load in the tweak main-planner interface routines.
;
(load "./tweak-planner-interface")
(load "./tw-heuristic")


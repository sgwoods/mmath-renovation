; tweak implemented 1990
; code written by steve woods & qiang yang
; university of waterloo
; waterloo, ontario canada
; sgwoods@watdragon.uwaterloo.ca   qyang@watdragon.uwaterloo.ca
;

; this file resides in:
; /tweak/init.lsp

; load in general routines.
(load "../Tweak2/general")

; load in the plan structure definitions and plan specific functions
(load "../Tweak2/structs")   

; load mtc inference routines.
(load "../Tweak2/mtc")

; load successors generation routines.
(load "../Tweak2/successors")

; load tree routines for determine u and p
(load "../Tweak2/tree")

; tweak/Succ/
;
(load "../Tweak2/Succ/find-new-ests")
(load "../Tweak2/Succ/select-ops")
(load "../Tweak2/Succ/discard-ops")
(load "../Tweak2/Succ/find-exist-ests")
(load "../Tweak2/Succ/find-pos-exist-ests")
(load "../Tweak2/Succ/find-nec-exist-ests")

; tweak/Conf-infer/ . load conflict  inference routines.  
;
(load "../Tweak2/Conf-infer/classify")
(load "../Tweak2/Conf-infer/declob")
(load "../Tweak2/Conf-infer/conflict-detection")
(load "../Tweak2/Conf-infer/intermed-access")

; tweak/Plan-infer: plan inference and modification routines.
;
(load "../Tweak2/Plan-infer/plan-dependent")
(load "../Tweak2/Plan-infer/plan-inference")
(load "../Tweak2/Plan-infer/cr-access")
(load "../Tweak2/Plan-infer/plan-modification")
(load "../Tweak2/Plan-infer/show-plan")

; load in the tweak debugging routines.
;
(load "../Tweak2/debug")

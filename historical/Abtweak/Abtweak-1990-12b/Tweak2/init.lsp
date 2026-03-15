; tweak implemented 1990
; code written by steve woods & qiang yang
; university of waterloo
; waterloo, ontario canada
; sgwoods@watdragon.uwaterloo.ca   qyang@watdragon.uwaterloo.ca
;

; this file resides in:
; /tweak/init.lsp

; load in general routines.
(load "/u/sgwoods/Plan/Tweak2/general")

; load in the plan structure definitions and plan specific functions
(load "/u/sgwoods/Plan/Tweak2/structs")   

; load mtc inference routines.
(load "/u/sgwoods/Plan/Tweak2/mtc")

; load successors generation routines.
(load "/u/sgwoods/Plan/Tweak2/successors")

; load tree routines for determine u and p
(load "/u/sgwoods/Plan/Tweak2/tree")

; tweak/Succ/
;
(load "/u/sgwoods/Plan/Tweak2/Succ/find-new-ests")
(load "/u/sgwoods/Plan/Tweak2/Succ/select-ops")
(load "/u/sgwoods/Plan/Tweak2/Succ/find-exist-ests")
(load "/u/sgwoods/Plan/Tweak2/Succ/find-pos-exist-ests")
(load "/u/sgwoods/Plan/Tweak2/Succ/find-nec-exist-ests")

; tweak/Conf-infer/ . load conflict  inference routines.  
;
(load "/u/sgwoods/Plan/Tweak2/Conf-infer/classify")
(load "/u/sgwoods/Plan/Tweak2/Conf-infer/declob")
(load "/u/sgwoods/Plan/Tweak2/Conf-infer/conflict-detection")
(load "/u/sgwoods/Plan/Tweak2/Conf-infer/intermed-access")

; tweak/Plan-infer: plan inference and modification routines.
;
(load "/u/sgwoods/Plan/Tweak2/Plan-infer/plan-dependent")
(load "/u/sgwoods/Plan/Tweak2/Plan-infer/plan-inference")
(load "/u/sgwoods/Plan/Tweak2/Plan-infer/cr-access")
(load "/u/sgwoods/Plan/Tweak2/Plan-infer/plan-modification")
(load "/u/sgwoods/Plan/Tweak2/Plan-infer/show-plan")

; load in the tweak debugging routines.
;
(load "/u/sgwoods/Plan/Tweak2/debug")

;load in the tweak maintenance functions
;
(load "/u/sgwoods/Plan/Tweak2/Maint/compile")

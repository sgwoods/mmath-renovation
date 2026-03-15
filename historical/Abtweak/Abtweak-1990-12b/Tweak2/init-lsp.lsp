; tweak implemented 1990
; code written by steve woods & qiang yang
; university of waterloo
; waterloo, ontario canada
; sgwoods@watdragon.uwaterloo.ca   qyang@watdragon.uwaterloo.ca
;

; this file resides in:
; /tweak/init.lsp

; load in general routines.
(load "/u/sgwoods/Plan/Tweak2/general.lsp")

; load in the plan structure definitions and plan specific functions
(load "/u/sgwoods/Plan/Tweak2/structs.lsp")   

; load mtc inference routines.
(load "/u/sgwoods/Plan/Tweak2/mtc.lsp")

; load successors generation routines.
(load "/u/sgwoods/Plan/Tweak2/successors.lsp")

; load tree routines for determine u and p
(load "/u/sgwoods/Plan/Tweak2/tree.lsp")

; tweak/Succ/
;
(load "/u/sgwoods/Plan/Tweak2/Succ/find-new-ests.lsp")
(load "/u/sgwoods/Plan/Tweak2/Succ/select-ops.lsp")
(load "/u/sgwoods/Plan/Tweak2/Succ/find-exist-ests.lsp")
(load "/u/sgwoods/Plan/Tweak2/Succ/find-pos-exist-ests.lsp")
(load "/u/sgwoods/Plan/Tweak2/Succ/find-nec-exist-ests.lsp")

; tweak/Conf-infer/ . load conflict  inference routines.  
;
(load "/u/sgwoods/Plan/Tweak2/Conf-infer/classify.lsp")
(load "/u/sgwoods/Plan/Tweak2/Conf-infer/declob.lsp")
(load "/u/sgwoods/Plan/Tweak2/Conf-infer/conflict-detection.lsp")
(load "/u/sgwoods/Plan/Tweak2/Conf-infer/intermed-access.lsp")

; tweak/plan-infer: plan inference and modification routines.
;
(load "/u/sgwoods/Plan/Tweak2/Plan-infer/plan-dependent.lsp")
(load "/u/sgwoods/Plan/Tweak2/Plan-infer/plan-inference.lsp")
(load "/u/sgwoods/Plan/Tweak2/Plan-infer/cr-access.lsp")
(load "/u/sgwoods/Plan/Tweak2/Plan-infer/plan-modification.lsp")
(load "/u/sgwoods/Plan/Tweak2/Plan-infer/show-plan.lsp")

; load in the tweak debugging routines.
;
(load "/u/sgwoods/Plan/Tweak2/debug.lsp")

;load in the tweak maintenance functions
;
(load "/u/sgwoods/Plan/Tweak2/Maint/compile.lsp")

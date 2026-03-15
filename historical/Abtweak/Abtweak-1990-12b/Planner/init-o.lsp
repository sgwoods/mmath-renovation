; /Planner/init.lsp

; PLANNER implemented 1990
; Code written by Steve Woods & Qiang Yang
; University of Waterloo
; Waterloo, ONTARIO CANADA
; sgwoods@watdragon.uwaterloo.ca   qyang@watdragon.uwaterloo.ca

; Load Search Routines
(load "/u/sgwoods/Plan/Planner/Search/search-load")

; Load Planner Functions
(load "/u/sgwoods/Plan/Planner/planner")
(load "/u/sgwoods/Plan/Planner/branch")

; Load File Output Driver
(load "/u/sgwoods/Plan/Planner/driver")

; Load TWEAK
(load "/u/sgwoods/Plan/Tweak2/init")

; Load ABTWEAK
(load "/u/sgwoods/Plan/AbTweak2/init")

; Load Default Domain
(load "/u/sgwoods/Plan/Planner/Domains/load-functions.lsp")
(load-nils)

; Set KCL control items
(setq *ignore-maximum-pages* t)  ; refer to KCL operating manual, page 26
;(allocate 'structure 1000)       ; allocate 1000 pages to structure

(load "useful")

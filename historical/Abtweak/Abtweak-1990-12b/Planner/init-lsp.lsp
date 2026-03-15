; /planner/init.lsp

; planner implemented 1990
; code written by steve woods & qiang yang
; university of waterloo
; waterloo, ontario canada
; sgwoods@watdragon.uwaterloo.ca   qyang@watdragon.uwaterloo.ca

; load search routines ; special
(load "/u/sgwoods/Plan/Planner/Search/search-load-lsp.lsp")

; load planner functions
(load "/u/sgwoods/Plan/Planner/planner.lsp")
(load "/u/sgwoods/Plan/Planner/branch.lsp")

; load file output driver
(load "/u/sgwoods/Plan/Planner/driver.lsp")

; load tweak ; special
(load "/u/sgwoods/Plan/Tweak2/init-lsp.lsp")

; load abtweak ; special
(load "/u/sgwoods/Plan/AbTweak2/init-lsp.lsp")

; load default domain
(load "/u/sgwoods/Plan/Planner/Domains/load-functions.lsp")
(load-nils)

; set kcl control items
(setq *ignore-maximum-pages* t)  ; refer to kcl operating manual, page 26
(allocate 'structure 1000)       ; allocate 1000 pages to structure

(load "useful.lsp")

; /planner/init.lsp

; planner implemented 1990
; code written by steve woods & qiang yang
; university of waterloo
; waterloo, ontario canada
; sgwoods@watdragon.uwaterloo.ca   qyang@watdragon.uwaterloo.ca

; load object code files or lisp code files

; Load Search Routinesx
(load  "Search/search-load")

; Load Planner Functions
(load "planner")
(load "branch")   ; Branch factor computation
(load "driver")   ; Load File Output Driver
(load "compile")

; Load TWEAK
(load "../Tweak2/init")

; Load ABTWEAK
(load "../AbTweak2/init")

; Define Load functions
(defun h4 () 
 (load "Domains/hanoi-4"))
(defun h3 () 
 (load "Domains/hanoi-3"))
(defun h2 () 
 (load "Domains/hanoi-2"))
(defun nils () 
 (load "Domains/nils-blocks"))
(defun robot () 
 (load "Domains/robot"))
(defun chapman () 
 (load "Domains/blocks"))

; Load Default Domain
(h2)




; /planner/search/state-expansion.lsp
;
; note this version of gs has been modified via declarations to be planning 
; structure specific, and references are made to state as an instance of 
; type plan in order to speed up the compiled version of this code
;   sgw oct 2, 1990

; written by steve woods, april 1990
; modified by steve woods oct  1990

(defun compute-priority (priority-function state cost)
      "planner/search/state-expansion
       computes the priority of a node by applying pri function"
   (+ cost (funcall priority-function state)))

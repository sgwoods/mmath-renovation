; /tweak/debug.lsp

; written by steve woods, july 1990

; output each plan as it is expanded - show children
;  keep track of order plans are expanded for making diagramming
;  easier, and planner more understandable

(defun debug-s (parent plan-list)
  "/tweak/debug.lsp
   debug successor generation - output plan id and successors
   called only if *debug* flag is set in this run of planner"
   (let (
         (num-child (length plan-list)))
    (declare
         (type integer num-child))
        
    (princ "***debug*******************") (terpri) 
    (princ "node expanded       ::") (princ  (plan-id parent)) (terpri)
    (princ "expanded number     :: ") (princ *numexpanded*) (terpri) 
    (princ "number of children  :: ") (princ num-child) (terpri) 
    (princ "total gen so far    :: ") (princ *numgenerated*) (terpri)
    (princ "succs (raw)   ::") (terpri)
    (princ plan-list)      (terpri)
    (princ "***************************") (terpri) ))

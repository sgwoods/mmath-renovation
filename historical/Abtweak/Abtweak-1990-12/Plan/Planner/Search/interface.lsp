; /planner/search/interface.lsp
; interface routines
;
; note this version of gs has been modified via declarations to be planning structure
;  specific, and references are made to state as an instance of type plan
;  in order to speed up the compiled version of this code
;   sgw oct 2, 1990
;
; written by steve woods, june 1990
; modified by steve woods oct  1990

(defun print-open-list ()
   "planner/search/interface
    print out the open list at each iteration"
   (terpri)  (princ "open list:") 
   (terpri)  (princ *open*)
   (terpri)  (princ "end *open* list") (terpri) )

(defun print-node&depth (node)
   "planner/search/interface
    this procedure prints node's state and its solution depth"
   (declare 
       (type list node))
   (print-state (get-state node))
   (terpri) (terpri) )

(defun print-success ( node)
   "planner/search/interface
    output goal information when successfully terminated"
   (declare 
       (type list node) )
     (terpri)
     (princ "*************************************************") (terpri)
     (princ "*         solution plan found                    ") (terpri)
     (princ "*************************************************") (terpri)
     (terpri)

     (print-node&depth node)
     (print-stats)
  )



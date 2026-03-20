; ***
; Interface routines
; ***

;user defined functions:  (print-state state)

(defun print-open-list ()
"print out the open list at each iteration"
   (terpri)  (princ "open list:")                
	(mapcar #'print-node&ancests *open*)
	(princ "end *open* list")(terpri))


(defun print-node&ancests (node &aux listofstates currentnode)
   "this procedure prints node's state and all of state's ancestors"

   (terpri)
   (princ "Priority: ")
   (princ (get-priority node))
   (princ "  Cost: ")
   (princ (get-cost node))
   (setq list-of-states '())
   (terpri)
   ; find list-of-states by searching through ancestors
   (do ((currentnode node (cadr (cddr currentnode))))
       ((eq currentnode nil))
       (setq listofstates (cons (get-state currentnode) listofstates)))
   (mapcar #'(lambda (state) (print-state state) (terpri)) listofstates))  


(defun print-success (prt_flag node numexpanded numgenerated)
   "output goal information when successfully terminated"
   (if prt_flag
       (progn 
             (print-node&ancests node)
             (princ "number of nodes expanded: ")
             (princ numexpanded)
             (terpri)
             (princ "number of nodes generated: ")
             (princ numgenerated)
             (terpri))))



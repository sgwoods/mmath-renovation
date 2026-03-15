(defun goal-p (state)
  "/Tweak/Save/debug-goal-p.lsp
    Debugging termination condition"
  (declare 
      (type plan state) )
  (let (
        (a (length (plan-a state)))
       )
    (princ "ID = ") (princ (plan-id state))
    (princ "  OPS = ") (princ a) 
    (princ "  Exp = ") (princ numexpanded)
    (princ "  Gen = ") (princ numgenerated)
    (terpri)
    
    (if (= a 9)  
        (let ()
            (setq *save* (cons state *save*))
            (setq *count* (1+ *count*))
            (princ "Saved = ") (princ *count*) (terpri) ))

  (mtc state) ))

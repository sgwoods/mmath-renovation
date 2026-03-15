(defun goal-p (state)
  "/Tweak/Save/debug-goal-p.lsp
    Debugging termination condition"
  (declare 
      (type plan state) )
  (let (
        (a (length (plan-a state)))
       )
    (princ "  OPS = ") (princ a) 
    (princ "  Exp = ") (princ numexpanded)
    (princ "  Gen = ") (princ numgenerated)
    (terpri)

  (mtc state) ))

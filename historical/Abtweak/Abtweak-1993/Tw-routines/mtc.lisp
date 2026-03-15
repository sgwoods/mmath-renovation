; /tweak/mtc.lsp

; written by steve woods and qiang yang, 1990.


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; mtc---modal truth criterion.
; note: none of the functions here depends on how the plan and operators are 
; implemented.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;******** mtc ******************

(defun mtc (plan)
   "/tweak/mtc.lsp
    modal truth criterion - true if plan correct, nil if incorrect."
  (declare 
      (type plan plan))   
  (all_preconds_hold-p plan (get-opids-from-plan plan)))

; subroutines for mtc.

(defun all_preconds_hold-p (plan opids)
   "/tweak/mtc.lsp
    return true if all of the operators in opids have preconds that nec. hold"
  (declare 
        (type plan plan))
  (if (null opids)
      t                 ;no opids left to check 
    (and 
     (this_opid_ok-p      plan (car opids))
     (all_preconds_hold-p plan (cdr opids)))))

(defun this_opid_ok-p (plan opid)
   "/tweak/mtc.lsp
    return true if all of this operator's preconditions necessarily hold"
  (declare 
        (type plan plan)
        (type atom opid)
    )   
  (let (
         (preconds (get-preconditions-of-opid opid plan)))
    (declare 
        (type list preconds))
    (preconds_hold-p plan opid preconds)))

(defun preconds_hold-p (plan opid preconds)
   "/tweak/mtc.lsp
    return true if all of the preconditions hold for this opid"
   (declare
      (type plan plan)
      (type atom opid)
      (type list preconds)
    )
   (if (null preconds)
       t                   ; no more preconds to check
       (and
           (hold-p plan opid (car preconds))
           (preconds_hold-p plan opid (cdr preconds)))))

(defun hold-p (plan opid precond)
  "/tweak/mtc.lsp
    does this precondition necessarily hold for opid?"
   (declare
      (type plan plan)
      (type atom opid)
      (type list precond))

   (let ((establishers (find_establishers plan opid precond)))

       (declare 
          (type list establishers))

       (and establishers
	 (one-of-establishers-ok-p plan establishers opid precond))))


(defun one-of-establishers-ok-p (plan establishers opid precond)
  "/tweak/mtc.lsp
    t if no clobberers exist for at least one of these establishers."
   (declare
      (type plan plan)
      (type list establishers)
      (type atom opid)
      (type list precond)
    )   
   (and establishers
       (or 
              ; no clobberer exists for first establisher ?
            (not (clobberer-exists-p plan (car establishers) opid precond))
              ; maybe no clobberer exists for other establishers ?
            (one-of-establishers-ok-p plan (cdr establishers) opid precond))))


;************ clobberer-exists-p

(defun clobberer-exists-p(plan est user precond)
   "/tweak/mtc.lsp
    t if there is clobberer for (est user precond).  nil if not."
   (declare
      (type plan plan)
      (type atom est)
      (type atom user)
      (type list precond))
   (let (
          (candidates (all-poss-between est user plan)))
     (declare 
        (type list candidates))
     (dolist (operator candidates nil)   ;if no operator is a true
	                               ;clobberer, return nil.

	     (if   ;return t if this operator is a true clobberer.
		 (let (
                        (effects (get-effects-of-opid operator plan)))
                   (declare 
                      (type list effects))
		   (dolist (effect effects nil)
			   (if (poss-codesignates effect 
						  (negate-condition precond) plan)
				 (return t))))
		 (return t)))))

; /abtweak/ab-mtc.lsp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ab-mtc---modal truth criterion for abtweak
;  based on tweak mtc in /tweak/mtc.lsp
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;******** ab-mtc ******************

(defun ab-mtc (plan)
 "/abtweak/ab-mtc.lsp
  modal truth criterion -true if plan correct @ ab level k, nil if incorrect."
  (declare 
      (type plan plan))   
  (ab-all_preconds_hold-p plan (get-opids-from-plan plan)))

; subroutines for ab-mtc.

(defun ab-all_preconds_hold-p (plan opids)
   "/abtweak/ab-mtc.lsp
    return true if all of the operators in opids have preconds at current
    abstraction level k that nec. hold"
  (declare 
        (type plan plan))
  (if (null opids)
      t                 ;no opids left to check 
    (and 
     (ab-this_opid_ok-p      plan (car opids))
     (ab-all_preconds_hold-p plan (cdr opids)))) )

(defun ab-this_opid_ok-p (plan opid)
   "/abtweak/ab-mtc.lsp
    return true if all of this operator's preconditions at the
    current level of abstraction k necessarily hold"
;
; adjust-pre-list function is in ab-succ.lsp
;
  (declare 
        (type plan plan)
        (type atom opid)
    )   
  (let (
         (preconds (adjust-pre-list opid
                       (get-preconditions-of-opid opid plan)
                       (plan-kval plan)))
       )
    (declare 
        (type list preconds))
    (preconds_hold-p plan opid preconds)))


; /tweak/succ/find-pos-exist-ests.lsp

; written by steve woods and qiang yang

;*********************** exist - pos establishers ************************


;**************************************************************
;note that some op with 1 or more nec establishers of u p may 
;also possess 1 or more pos establisher effects of u p ; so we must
;consider all ops possibly before u with all effects such that 
; effect possibly satisfies p.  also we don't consider establishers that 
; nec precede u and nec satisfy p ,since this is covered in 
; est-nec-esist.lsp file already.
;***************************************************************

(defun find-pos-exist-ests (plan u p)
  "/tweak/succ/find-pos-exist-ests.lsp   (oct 11)
   returns list of (establisher modified-plan)
   list, where modified-plan is plan making establisher necessarily
   before  u, and effect-of-establisher necessarily co-designates with p
   "
  (declare
        (type plan plan)
        (type atom u)
        (type list p))

  (let* (
         (all-poss-before (all-poss-before u plan))
	 (pos-est-pairs (find_pos_est_pairs plan all-poss-before u p)))
    (declare 
        (type list all-poss-before)
        (type (list list) pos-est-pairs))
    (make-pos-intermediates pos-est-pairs u p plan)) )
    

;****** macros for pos_est-pairs **********

(defmacro get-establisher (pos-est-pairs)
  "/tweak/succ/find-pos-exist-ests.lsp"
 `(first (first ,pos-est-pairs)))

(defmacro get-establisher-effect (pos-est-pairs)
  "/tweak/succ/find-pos-exist-ests.lsp"
 `(second (first ,pos-est-pairs)))

;******** end macros. **************

(defun make-pos-intermediates (pos-est-pairs u p plan)
  "/tweak/succ/find-pos-exist-ests.lsp
   create list of (est p newplan),
   pos-est-pairs is a list of (est effect(est))."
  (declare
        (type (list list) pos-est-pairs)
        (type atom u)
        (type list p)
        (type plan plan))

   (if (null pos-est-pairs)
       nil
       (cons
        (list (get-establisher pos-est-pairs)
              (make-est 
        	     (add-cost-to-plan 0 plan)
			; add in cost of generating en intermediate
              (get-establisher pos-est-pairs) 
              (get-establisher-effect pos-est-pairs) u p)
	    ) 
        (make-pos-intermediates (cdr pos-est-pairs) u p plan)) ))


(defun make-est (plan estid effect-of-est u p)
  "/tweak/succ/find-pos-exist-ests.lsp
   create a new plan in which est, estu is a nec establisher"
  (declare
        (type plan plan)
        (type atom estid)
        (type list effect-of-est)
        (type atom u)
        (type list p) )
  (let (
        (new-plan (make-copy-of-plan plan)))
    (declare
        (type plan new-plan) )

    (mapcar #'(lambda (x y)
		(add-co-to-plan x y new-plan))
	    (get-proposition-params effect-of-est)
	    (get-proposition-params p))

; conflicts are not added.

     (add-order-to-plan estid u new-plan)
    new-plan))


(defun find_pos_est_pairs (plan pos-ests u p)
  "/tweak/succ/find-pos-exist-ests.lsp
   return a list of (est effect-of-est) where effect-of-est 
  in est pos codesignates p"
(declare
        (type plan plan)
        (type list pos-ests)
        (type atom u)
        (type list p))

  (if (null pos-ests)
      nil
      (append
        (find_est_effect_pairs_for_pos-est plan (car pos-ests) u p)
        (find_pos_est_pairs plan (cdr pos-ests) u p))))


(defun find_est_effect_pairs_for_pos-est (plan pos-estid u p)
  "/tweak/succ/find-pos-exist-ests.lsp
   returns a list of (estid ei(estid)) pairs 
   where ei(estid) is the ith effect of est that possibly codesignates p"
  (declare
        (type plan plan)
        (type atom pos-estid)
        (type atom u)
        (type list p) )
  
  (cond ( (and (member p (get-effects-of-opid pos-estid plan) :test 'equal)
	       (nece-before-p pos-estid u plan))
	    nil )
          (t      ;pos-estid is possible, but not necessarily yet.
	    (mapcar #'(lambda (effect) 
                         (list pos-estid effect))
		    (find-all-poss-codes-effects pos-estid p plan)) ) ))
          


(defun find-all-poss-codes-effects (pos-estid p plan)
 "/tweak/succ/find-pos-exist-ests.lsp
    returns a list of effects of pos-est that poss codes with p"
    (declare
        (type atom pos-estid)
        (type list p)
        (type plan plan))
   (remove-if #'null
    (mapcar #'(lambda (effect)
                  (if (poss-codesignates effect p plan)
                      effect))
               (get-effects-of-opid pos-estid plan) )))

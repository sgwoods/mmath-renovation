; /tweak/plan-infer/plan-inference.lsp

;************ note *****************
; the following functions are assumed plan-dependent.
;
; 1) (nece-before-p op1 op2 plan) done.
; 2) (non-codesignates-p x y plan), where x y are atoms. done
; 3) (get-opids-from-plan plan)  done
; 4) (get-operator-effects operator)  done.
;***********************************


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;              routines for finding special operators.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;**************** find-establishers in plan, for precond of operator, opid.

(defun find_establishers (plan opid precond)
   "/tweak/plan-infer/plan-inference.lsp
    returns a list of establishers of an operator precondition in plan so
   that 
   1 est->opid, and 
   2 an effect of est necessarily codesignates with precond and that 
   3 no other operator between operator and opid necessarily establishe
   precond."
   (declare
      (type plan plan)
      (type atom opid)
      (type list precond))
   (let (
         (candidates (all-nece-before opid plan)))  ; repaired to nece oct 9
     (declare
         (type list candidates) )
     (remove-redundant-establishers plan
      (remove nil
       (mapcar #'(lambda (operator) 
		   (if
		       (nece-est-p operator precond plan)
		       operator
		     nil))
	       candidates)))))

(defun remove-redundant-establishers (plan list-of-ops)
  "/tweak/plan-infer/plan-inference.lsp
    returns a list of operators so that for each ai, aj, ai is not before aj."
  (declare
      (type plan plan)
      (type (list operator) list-of-ops) )
  (do ((a-list list-of-ops (cdr a-list))
       (result nil))
      ((null a-list) result)
      (if
	  (do ((b-list list-of-ops (cdr b-list)))
	      ((null b-list) t)
	      (if (nece-before-p (car a-list) (car b-list) plan)
		  (return nil)))
	  (setq result (cons (car a-list) result)))))


(defun nece-est-p (opid precond plan)
  "/tweak/plan-infer/plan-inference.lsp
    t if an effect of  operator necessarily codesignates with precond."
  (declare
      (type atom opid)
      (type list precond)
      (type plan plan) )
  (let (
        (effects (get-effects-of-opid opid plan)))
    (declare
        (type (list list) effects) )
    (dolist (effect effects nil)
	    (if (nece-codesignates-p effect precond)
		(return t)))))

(defun poss-est-p (opid precond plan)
  "/tweak/plan-infer/plan-inference.lsp
    t if an effect of  operator possibly codesignates with precond."
  (declare
      (type atom opid)
      (type list precond)
      (type plan plan) )
  (let (
        (effects (get-effects-of-opid opid plan)))
    (declare
        (type (list list) effects) )
    (dolist (effect effects nil)
	    (if (poss-codesignates effect precond plan)
		(return t)))))

(defun np-est-p (opid precond plan)
  "/tweak/plan-infer/plan-inference.lsp
    t if an effect of  operator 
     necessarily codesignates with (1st param) of precond
     possibly    codesignates with (rest params) of precond"
  (declare
      (type atom opid)
      (type list precond)
      (type plan plan) )
  (let (
        (effects (get-effects-of-opid opid plan)))
    (declare
        (type (list list) effects) )
    (dolist (effect effects nil)
	    (if (np-codesignates-p effect precond plan)
		(return t)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		codesignation routines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;**** necessarily codesignates    

(defun nece-codesignates-p (prop1 prop2)
  "/tweak/plan-infer/plan-inference.lsp
    returns t iff prop1 necessarily codesignates with prop2."
  (declare
      (type list prop1)
      (type list prop2) )
  (equal prop1 prop2))

; ** necessarily codes 1st params , possibly codes rest params

(defun np-codesignates-p (prop1 prop2 plan)
  "/tweak/plan-infer/plan-inference.lsp
    returns t iff prop1 nec codes 1st param, pos codes rest params"
  (declare
      (type list prop1)
      (type list prop2) 
      (type plan plan) )
  (let* (
         (strip-prop1 (strip-negate prop1))
         (strip-prop2 (strip-negate prop2))
         (nec-prop1   (list (first strip-prop1) (second strip-prop1)))
         (nec-prop2   (list (first strip-prop2) (second strip-prop2))) )
   (if (nots-do-not-match prop1 prop2)
       nil
       (if (and
               (nece-codesignates-p nec-prop1 nec-prop2)
               (poss-codesignates   prop1 prop2 plan))
           t
           nil))))

;************ poss-codesignates function.  q. yang.

(defun atom-poss-codesignate (a1 a2 &optional plan)
  "/tweak/plan-infer/plan-inference.lsp
    returns substitution ((ai aj)) if ai=var, 
   and poss codesignate in plan. t if a1=a2.
   else return nil."
  (declare
      (type atom a1) 
      (type atom a2) 
      (type plan plan) )
  (cond 
   ((equal a1 a2) t)
   ((non-codesignate-p a1 a2 plan) nil)
   ((var-p a1) (list (list a1 a2)))
   ((var-p a2) (list (list a2 a1)))
   (t nil)))

(defun poss-codesignates (prop1 prop2 &optional plan)
   "/tweak/plan-infer/plan-inference.lsp
    t if prop1 prop2 necessarily codesignate.
    returns a mapping between prop1 prop2 if they poss codesignate.
    else return nil."
   (declare
      (type list prop1)
      (type list prop2)
      (type plan plan) )

   (cond  ((equal prop1 prop2) t)   ;nece codesignate.

;both are atoms:

	 ((and (atom prop1) (atom prop2))
	  (atom-poss-codesignate prop1 prop2 plan))
	  
;both are lists

	 ((and (listp prop1) (listp prop2) 
	       (equal (length prop1) (length prop2)))
; build mapping.
	    (do ((rem-prop1 prop1 (cdr rem-prop1))
		 (rem-prop2 prop2 (cdr rem-prop2))
		 (result nil))
	      ((null rem-prop1) (if result result t))
	      (let* (
                     (ele1 (car rem-prop1))
		     (ele2 (car rem-prop2))
		     (mapping 
		       (atom-poss-codesignate ele1 ele2 plan)))
                (declare
                    (type atom ele1)
                    (type atom ele2) 
                    (type list mapping) )
		(cond 
		 ((and mapping (not (equal mapping t)))
		  (setq result (append mapping result)))
		 ((null mapping) (return nil))))))))

		  
(defun nots-do-not-match (p1 p2)
  "/tweak/plan-infer/plan-inference.lsp
    true if the 'nots' of each item fail to match"
   (declare
      (type atom p1)
      (type atom p2))

 (or (and (eq p1 'not) (not (eq p2 'not)) )
     (and (not (eq p1 'not)) (eq p2 'not) ) ))

(defun negate (p1)
  "/tweak/plan-infer/plan-inference.lsp"
  (declare (type list p1))
  (if (eq (car p1) 'not)
      (cdr p1)
      (cons 'not p1)))

(defun strip-negate (p1)
  "/tweak/plan-infer/plan-inference.lsp"
  (declare (type list p1))
  (if (eq (car p1) 'not)
      (cdr p1)
      p1))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;            routines for precedence queries
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 


(defun all-poss-before (op plan)
 "/tweak/plan-infer/plan-inference.lsp
    returns the set of operator ids possibly before op.  "
 (declare  
     (type atom op)
     (type plan plan) )
 (remove nil (mapcar 
	      #'(lambda (operator) 
		  (if (poss-before-p operator op plan)
		      operator nil))
	      (remove op (get-opids-from-plan plan)))))

(defun all-nece-before (op plan)
 "/tweak/plan-infer/plan-inference.lsp
    returns the set of operator ids necessarily before op."
 (declare  
     (type atom op)
     (type plan plan) )  
 (remove nil (mapcar 
	      #'(lambda (operator) 
		  (if (nece-before-p operator op plan)
		      operator nil))
	      (remove op (get-opids-from-plan plan)))))


(defun all-poss-between (op1 op2 plan)
  "/tweak/plan-infer/plan-inference.lsp
    returns list of operators possibly between op1 and op2 in plan."
 (declare  
     (type atom op1)
     (type atom op2)
     (type plan plan) )
  (set-difference (all-poss-before op2 plan)
		  (cons op1 (all-nece-before op1 plan))))

(defun all-nece-between (op1 op2 plan)
  "/tweak/plan-infer/plan-inference.lsp
    returns list of operators necessarily between op1 and op2 in plan."
 (declare  
     (type atom op1)
     (type atom op2)
     (type plan plan) )
  (set-difference (all-nece-before op2 plan)
		  (cons op1 (all-poss-before op1 plan))))


(defun poss-before-p (op1 op2 plan)
  "/tweak/plan-infer/plan-inference.lsp
    t iff op1 is possibly before op2 in plan."
 (declare  
     (type atom op1)
     (type atom op2)
     (type plan plan) )
 (not (nece-before-p op2 op1 plan)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;			operator effects
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun get-ith-op-effect (op-template index)
  "/tweak/plan-infer/plan-inference.lsp
    returns the ith effect of op-template, where i=index."
  (declare
      (type operator op-template)
      (type integer index) )
  (ith index (get-operator-effects op-template)))



(defun ith (i a-list)
  "/tweak/plan-infer/plan-inference.lsp
   returns the ith element of a-list"
(declare 
    (type integer i)
    (type list a-list) )
(dotimes (index i (car a-list))
	(setq a-list (cdr a-list))))


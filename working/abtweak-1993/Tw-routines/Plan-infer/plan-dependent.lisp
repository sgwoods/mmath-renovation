; /Tweak/plan-infer/plan-dependent.lsp 

; note: the following functions are dependent upon how plan, and
; operators are implemented.

;******************** plan-dependent ****************************
;
;		(1) access functions
;
;****************************************************************

(defun get-plan-cost (plan)   
  "/tweak/plan-infer/plan-dependent.lsp "
  (plan-cost plan))

(defun get_kval (plan)   
  "/tweak/plan-infer/plan-dependent.lsp "
  (plan-kval plan))

(defun get_cr (plan)   
  "/tweak/plan-infer/plan-dependent.lsp "
  (plan-cr plan))

(defun get_a (plan)   
  "/tweak/plan-infer/plan-dependent.lsp "
  (plan-a plan))

(defun get_b (plan)   
  "/tweak/plan-infer/plan-dependent.lsp "
  (plan-b plan))

(defun get_nc (plan)   
  "/tweak/plan-infer/plan-dependent.lsp "
  (plan-nc plan))

(defun get_var (plan)   
  "/tweak/plan-infer/plan-dependent.lsp "
  (plan-var plan))

(defun get_op-count (plan)   
  "/tweak/plan-infer/plan-dependent.lsp "
  (plan-op-count plan))

(defun get_conflicts (plan)   
  "/tweak/plan-infer/plan-dependent.lsp "
  (plan-conflicts plan))

(defun get_invalid (plan)   
  "/tweak/plan-infer/plan-dependent.lsp "
  (plan-invalid plan))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;             validity
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun invalid-p (plan)
  "/tweak/plan-infer/plan-dependent.lsp 
   t if plan is invalid: exists violation of precedence relation,
   or non-codesignation constraints."
  (declare
      (type plan plan) )
  (plan-invalid plan))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;             co-designation 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun non-codesignate-p (ele1 ele2 plan)
  "/tweak/plan-infer/plan-dependent.lsp 
   t ele1 ele2 are both constants and different.
   or if plan is not nil, and (ele1 ele2) in nc of plan"
  (declare
      (type atom ele1)
      (type atom ele2)
      (type (or null plan) plan) )
  (if
      (or
       (and (constant-p ele1) (constant-p ele2) (not (equal ele1 ele2)))
       (and plan 
	    (or (member (list ele1 ele2) (plan-nc plan) :test 'equal)
		(member (list ele2 ele1) (plan-nc plan) :test 'equal))))
      t nil))
		    

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;           precedence
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun nece-before-p (op1 op2 plan)
  "/tweak/plan-infer/plan-dependent.lsp 
   t iff op1 is necessarily before op2 in plan."
  (declare
      (type atom op1)
      (type atom op2)
      (type plan plan) )
  (let (
        (pairs (plan-b plan)))
    (declare
        (type list pairs) )
    (transitive-test-before-p op1 op2 pairs) ))

;;; precedence, leonard-1
;;; From leonard@nssdcs.gsfc.nasa.gov Sat Jul 25 07:27:27 1992
;;; NOTE three versions present in this directory - see notes in each

;;; Reachability in the precedence graph.
;;; The historical tree includes several alternative implementations of
;;; this routine because it dominated planning time on Hanoi. Use an
;;; iterative sweep-and-mark walk here so we answer the same boolean query
;;; without rebuilding or copying the order graph for every recursive step.

(defun transitive-test-before-p (op1 op2 pairs)
  "/tweak/plan-infer/plan-dependent.lisp 
   returns t iff op1 precedes op2 (possibly transitively) in pairs"
 (declare
  (type atom op1)
  (type atom op2)
  (type list pairs) )

  (cond 
   ((eq op2 'i) nil)
   ((eq op1 'g) nil)
   ((null pairs) nil)
   (t
    (let ((agenda (list op2))
          (visited nil))
      (declare
       (type list agenda)
       (type list visited))
      (do ()
          ((null agenda) nil)
        (let ((current (pop agenda)))
          (unless (member current visited :test 'eq)
            (push current visited)
            (dolist (pair pairs)
              (let ((before (first pair))
                    (after (second pair)))
                (when (eq after current)
                  (if (eq before op1)
                      (return-from transitive-test-before-p t))
                  (unless (or (eq before 'i)
                              (member before visited :test 'eq))
                    (push before agenda))))))))))))
		

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;               conflicts
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun get-conflicts-from-plan (plan)
  "/tweak/plan-infer/plan-dependent.lsp 
   returns a list of conflicts in plan."
  (declare
      (type plan plan) )
  (plan-conflicts plan))

(defun get-conflict-pro (conflict)
  "/tweak/plan-infer/plan-dependent.lsp 
   returns the provider of conflict."
  (declare 
      (type list conflict) )
  (first conflict))

(defun get-conflict-u (conflict)
  "/tweak/plan-infer/plan-dependent.lsp 
   returns the user of conflict."
  (declare 
      (type list conflict) )
  (second conflict))

(defun get-conflict-n (conflict)
  "/tweak/plan-infer/plan-dependent.lsp 
   returns the clobberer of conflict."
  (declare 
      (type list conflict) )
  (third conflict))

(defun get-conflict-p (conflict)
  "/tweak/plan-infer/plan-dependent.lsp 
   returns the p of conflict."
  (declare 
      (type list conflict) )
  (fourth conflict))

(defun get-conflict-q (conflict)
  "/tweak/plan-infer/plan-dependent.lsp 
   returns the q of conflict."
  (declare 
      (type list conflict) )
  (fifth conflict))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;              access operator ids,               
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; ********* get operator from plan

(defun get-operators-from-plan (plan)
  "/tweak/plan-infer/plan-dependent.lsp 
   returns list of operator instances in plan"
  (declare 
      (type plan plan) )
  (plan-a plan))


; ******** get-opids-from-plan

(defun get-opids-from-plan (plan)
  "/tweak/plan-infer/plan-dependent.lsp 
   returns a list of opids from plan."
  (declare 
      (type plan plan) )
  (mapcar #'operator-opid (plan-a plan)))

;****************** operator dependent **********************

(defun  get-effects-of-opid (opid plan)
 "/tweak/plan-infer/plan-dependent.lsp 
   returns a list of operator effects of opid, which is an operator instance."
  (declare 
      (type atom opid)
      (type plan plan) )
  (operator-effects 
   (car (member 
	 opid (plan-a plan)
	 :test #'(lambda (opid op-inst)
		   (equal opid 
			  (operator-opid op-inst)))))))

(defun get-preconditions-of-opid (opid plan)
 "/tweak/plan-infer/plan-dependent.lsp 
   returns the preconditions of operator in plan."
  (declare 
      (type atom opid)
      (type plan plan) )
 (operator-preconditions
   (car (member 
	 opid (plan-a plan)
	 :test #'(lambda (opid op-inst)
		   (equal opid 
			  (operator-opid op-inst)))))))
 

(defun get-cost-of-opid (opid plan)
  "/tweak/plan-infer/plan-dependent.lsp 
   returns the cost of opid in plan"
  (declare 
      (type atom opid)
      (type plan plan) )
   (operator-cost
     (car (member 
	   opid (plan-a plan)
	   :test #'(lambda (opid op-inst)
		     (equal opid 
			    (operator-opid op-inst)))))))

;;;;;;;;;; access operator structure.

(defun get-operator-effects (operator)
  "/tweak/plan-infer/plan-dependent.lsp 
   returns the set of effects of operator"
  (declare 
      (type operator operator) )
  (operator-effects operator))

(defun get-operator-primary-effects (operator)
  "/tweak/plan-infer/plan-dependent.lsp 
   returns the set of effects of operator"
  (declare 
      (type operator operator) )
  (operator-primary-effects operator))

(defun get-operator-params (operator)
 "/tweak/plan-infer/plan-dependent.lsp 
   returns parameters in operator name."
  (declare 
      (type operator operator) )
  (cdr (operator-name operator)))

(defun get-operator-opid (operator)
 "/tweak/plan-infer/plan-dependent.lsp 
   returns parameters in operator name."
  (declare 
      (type operator operator) )
  (operator-opid operator))

(defun get-operator-cost (operator)
  "returns the cost of the operator structure."
  (declare 
      (type operator operator) )
  (operator-cost operator))


;*******************************************************************
;
;			(2) modification
;
;*******************************************************************

;;;;;;;;;;;;;;;;;;;;;;;;    operator   ;;;;;;;;;;;;;;;;;;;


(defun create-new-op-instance (op-template)
  "/tweak/plan-infer/plan-dependent.lsp 
   returns a new operator instance, making sure that 
   variables names are differnet form the template."
  (declare
      (type operator op-template) )
  (let (temp-op
        (mapping 
	 (clean-up-mapping 
	  nil 
          (get-operator-params op-template))) )
    (declare
        (type list mapping) )
; returns a list of substitutions to be made to op-template.

    (setq temp-op 
	  (make-operator
	   :opid (create-opid)
	   :name          (substitute-one-list 
	                   (operator-name op-template) 
			   mapping)
	   :preconditions (substitute-all-lists
	                   (operator-preconditions op-template)
			   mapping)
	   :effects       (substitute-all-lists
	                   (operator-effects op-template)
			   mapping)
	   :primary-effects       (substitute-all-lists
	                   (operator-primary-effects op-template)
			   mapping)
	   :cost       (operator-cost op-template)))
    temp-op))


(defun apply-mapping-to-op-instance (operator mapping)
  "/tweak/plan-infer/plan-dependent.lsp 
   returns op-instance with variables substituted by 
  subs specified in mapping."
  (declare
      (type operator operator)
      (type (or list (eql t)) mapping) )
  (if (not (equal mapping t))
      (let ()
	(setf (operator-name operator)
	      (substitute-one-list 
	       (operator-name operator)
	       mapping))
	(setf (operator-preconditions operator)
	      (substitute-all-lists
	       (operator-preconditions operator)
	       mapping))
	(setf (operator-effects operator)
	      (substitute-all-lists
	       (operator-effects operator)
	       mapping))))
    operator)


(defun make-copy-of-op-list (op-list)
  "/tweak/plan-infer/plan-dependent.lsp 
   returns a list of new copies of op-list: list of templates."
  (declare
      (type list op-list) )
  (mapcar 'make-copy-of-operator op-list))

(defun make-copy-of-operator (operator)
  "returns a copy of operator, with all new stuff"
  (declare 
      (type operator operator) )
  (make-operator
   :opid (operator-opid operator)
   :name (operator-name operator)
   :preconditions    (operator-preconditions operator)
   :cost (operator-cost operator)
   :effects (operator-effects operator)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;; plan modification ;;;;;;;;;;;

;***************** make-copy-of-plan (plan)

(defun make-copy-of-plan (plan)
  "/tweak/plan-infer/plan-dependent.lsp 
   returns a new plan structure."
  (declare 
      (type plan plan) )
  (remove-constant-nonco
   (make-plan
        :id        (create-planid)
        :a         (make-copy-of-op-list (plan-a plan))
        :b         (plan-b plan)
        :nc        (plan-nc plan)
        :cr        (plan-cr plan)
        :cost      (plan-cost plan)
        :kval      (plan-kval plan)
        :conflicts (plan-conflicts plan)
        :op-count  (plan-op-count plan)
        :invalid   (plan-invalid plan))))
  


;********** add-nc-to-plan (x y plan)

(defun add-nc-to-plan (x y plan)
  "/tweak/plan-infer/plan-dependent.lsp 
   add to plan non-codesignation constraint that x /= y."
  (declare
      (type atom x) 
      (type atom y)
      (type plan plan) )
  (cond ((nece-codesignates-p x y)
	 (mark-invalid-plan plan))
	((not (non-codesignate-p x y plan))      ; prevents addition of 
	 (setf (plan-nc plan)                    ;  duplicates ncs
	       (cons (list x y) (plan-nc plan)))
	 plan)))


(defun remove-constant-nonco (plan)
  "/tweak/plan-infer/plan-dependent.lsp 
   remove pairs of noncodesignation constraint where 
   pair=(e1 e2), and both are constants"
  (declare
      (type plan plan) )
  (let (
        (nc-list (plan-nc plan)))
    (declare
        (type list nc-list) )
    (setq nc-list
	  (remove nil
		  (mapcar #'(lambda (pair)
			      (if (and (constant-p (first pair))
				       (constant-p (second pair)))
				  nil
				pair))
			  nc-list)))
    (setf (plan-nc plan) nc-list)
    plan))

	

;********** add-conflicts-to-plan (conflicts plan)

(defun add-conflicts-to-plan (conflicts plan)
  "/tweak/plan-infer/plan-dependent.lsp 
   add conflicts list to plan."
   (declare 
       (type list conflicts)
       (type plan plan) )
   (let ()
      (setf (plan-conflicts plan)
	    (append conflicts
		    (plan-conflicts plan)))
     plan))


;********** add-cost-to-plan ( plan cost)

(defun add-cost-to-plan (cost plan)
  "/tweak/plan-infer/plan-dependent.lsp 
   add to plan cost"
    (declare 
        (type plan plan)
        (type integer cost) )
    (let ()
      (setf (plan-cost plan)
	    (+ cost (plan-cost plan)))
      plan))


(defun replace-a (x y plan)
  "/tweak/plan-infer/plan-dependent.lsp 
   x replaced by y in plan-a."
  (declare
      (type atom x) 
      (type atom y)
      (type plan plan) )  
  (mapcar #'(lambda (operator)
	      (setf (operator-preconditions operator)
		    (substitute-all-lists
		     (operator-preconditions operator)
		     (list (list x y))))
	      
	      (setf (operator-effects operator)
		    (substitute-all-lists
		     (operator-effects operator)
		     (list (list x y))))

	      (setf (operator-name operator)
		    (substitute-one-list
		     (operator-name operator)
		     (list (list x y))))
	      ) (plan-a plan))
  plan)


(defun replace-nc (x y plan)
  "/tweak/plan-infer/plan-dependent.lsp 
   x replaced by y in plan-nc."
  (declare
      (type atom x) 
      (type atom y)
      (type plan plan) )  
  (setf (plan-nc plan)
        (clean-up-nc 
    	   (substitute-all-lists
	         (plan-nc plan)
	         (list (list x y)))))
  plan)

(defun clean-up-nc (nc)
  "/tweak/plan-infer/plan-dependent.lsp 
   remove any non codesignation duplicates that have crept in to nc via
   addition of codesignations"
     (declare
         (type list nc))

     (if (eq nc nil)
         nil
         (remove-duplicates nc
          :test #'(lambda (pair1 pair2) (or (equal pair1 pair2)
                                            (equal (reverse pair1) pair2)))) ))

(defun replace-cr (x y plan)
 "/tweak/plan-infer/plan-dependent.lsp 
  replace x by y in cr"
  (declare
      (type atom x) 
      (type atom y)
      (type plan plan) )
  (if (var-p x)
      (setf (plan-cr plan)
	    (mapcar #'(lambda (cr-ele)
			(list
			 (get-user-in-cr cr-ele)
			 (substitute y x (get-condition-in-cr cr-ele))
			 (get-producer-list-in-cr cr-ele)))
		    (plan-cr plan))))
  plan)




(defun replace-conflicts (x y plan)
  "/tweak/plan-infer/plan-dependent.lsp 
   x replaced by y in plan-conflicts."
  (declare
      (type atom x) 
      (type atom y)
      (type plan plan) )  
  (setf (plan-conflicts plan)
	(mapcar 
	 #'(lambda (conflict)
	     (list (get-conflict-pro conflict)
		   (get-conflict-u conflict)
		   (get-conflict-n conflict)
		   (substitute-one-list
		    (get-conflict-p conflict)
		    (list (list x y)))
		   (substitute-one-list
		    (get-conflict-q conflict)
		    (list (list x y)))))
	 (plan-conflicts plan)))
  plan)


;***************** add-order-to-plan (opid1 opid2 plan)

(defun add-order-to-plan (opid1 opid2 plan)
  "/tweak/plan-infer/plan-dependent.lsp 
   add opid1<opid2 in plan."

; repaired oct 9, 1990 - sgw
; maintain transitive nature of orderings - ie 
; if a < c & a < d , then adding c < d makes a < d redundant

  (declare
      (type atom opid1) 
      (type atom opid2)
      (type plan plan) )  

  (let (
        (old-orderings (plan-b plan)) )

    (declare
        (type list old-orderings))

    (cond ((nece-before-p opid2 opid1 plan)
            (mark-invalid-plan plan))
           (t (if (not (nece-before-p opid1 opid2 plan))
                  (let ()
                   (setf (plan-b plan)
                         (remv-redun-orders 
                            (cons (list opid1 opid2) old-orderings)
                            old-orderings))
                    plan)
                   plan))) ))

(defun remv-redun-orders (b candidates)
  "/tweak/plan-infer/plan-dependent.lsp 
   remove any candidate orderings that hold without their sep assertion
   ie check each old ordering and see if it has become redundant"
   (declare 
      (type list b)
      (type list candidates)
    )
   (if (or (eq nil candidates) (eq nil b))
       b
       (let* (
              (ck    (car   candidates))     ; get a possible redundancy
              (ckop1 (first ck))             ; ckop1 < ckop2
              (ckop2 (second ck)) )
         
         (declare
                 (type list ck)
                 (type atom ckop1)
                 (type atom ckop2) )

                   ; is this constraint ck:: ckop1 < ckop2 redundant?
             (if (transitive-test-before-p ckop1 ckop2 (my-delete ck b))
                   ; ie the constraint holds without explicit ckop1 < ckop2
                 (remv-redun-orders (my-delete ck b) (cdr candidates)) 
                   ; get rid of it, check the rest
                 (remv-redun-orders b (cdr candidates))  
                   ; keep it, check the rest
              ))))



;**************** add-operator-to-plan (op-instance plan)

(defun add-operator-to-plan (op-instance plan)
  "/tweak/plan-infer/plan-dependent.lsp 
   add an operator instance to plan.  note after adding
   operator to plan-a, also add ordering (i < op-instance)
   and (op-instance < g); and parameter noncodesignations"

  (declare
      (type operator op-instance)
      (type plan plan) )  

    (let* (
           (id       (get-operator-opid op-instance))
           (neworder (cons (list 'i id) (cons (list id 'g) (plan-b plan)))) 
           (op-params (get-operator-params op-instance)) )

      (declare
          (type atom id) 
          (type list neworder)
          (type list op-params))

      (setf (plan-a plan)
	    (cons op-instance 
		  (plan-a plan)))

      (setf (plan-b plan)
            (remv-redun-orders 
	        neworder neworder))

      (setf (plan-nc plan)
            (clean-up-nc 
              (plan-nc (add-para-ncodes op-params plan))))
                 
      plan))


(defun add-para-ncodes (list-of-vars plan)
 "tweak/succ/find-new-ests.lsp
  add into plan non-codesignation constraints so that everyone in 
  list-of-vars non-codesignate with the other."
(declare
    (type list list-of-vars)
    (type plan plan) )
(cond (
      (null (cdr list-of-vars)) plan)
      (t 
       (let (
             (current-pairs 
	       (mapcar #'(lambda (x) (list (car list-of-vars) x))
		       (cdr list-of-vars))))
         (declare
               (type list current-pairs) )
	 (dolist (pair current-pairs)
		 (add-nc-to-plan (first pair)
				 (second pair) plan)))
	 (add-para-ncodes (cdr list-of-vars) plan))) )

(defun mark-invalid-plan (plan)
  "/tweak/plan-infer/plan-dependent.lsp 
    mark the invalid bit of plan."
 (declare
     (type plan plan) )
 (setf (plan-invalid plan) t)
 plan)

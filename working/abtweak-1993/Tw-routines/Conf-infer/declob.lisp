; /tweak/conf-infer/declob.lsp

; written by steve woods and qiang yang 1990


; ;***********declobbering

(defun declobber-all (intermediates u precond-index)
  "/tweak/conf-infer/declob.lsp
   returns a list of all plans created from 
   result of declobbering each intermediate all ways possible"
   (declare 
       (type list intermediates)
       (type atom u)
       (type number precond-index) )

   (if (eq (car intermediates) nil) ; no one to expand.
       nil
     (apply 'append
	    (mapcar #'(lambda (inter)
			(let (
                              (estid (get-inter-estid inter))
			      (plan (get-inter-plan inter)))
                           (declare
                                (type atom estid)
                                (type plan plan) )                        
                           (declobber estid u precond-index plan)))
            intermediates))))


; changed in oct. 29

(defun declobber (estid  u precond-index plan)
  "/tweak/conf-infer/declob.lsp
   create list of successors from intermediate node"
  (declare
       (type atom estid)
       (type atom u)
       (type number precond-index)
       (type plan plan) )
  (let* (
	(precond (index-to-precond precond-index u plan))
        (alternative-constraints
                  (create-alternative-constraints
                  	  estid u precond plan)))
    (declare
        (type list alternative-constraints) )

    (mapcar #'(lambda (conjunctive-constraint)
		(apply-constraints-to-plan
		 conjunctive-constraint plan))
	    alternative-constraints)))


(defun create-alternative-constraints (estid u precond plan)
  "/tweak/conf-infer/declob.lsp
   returns a list of sublists, each sublist is a set of
   constraints for resolving all conflcits for 
   (estid u precond) in plan."
  (declare 
     (type atom estid)
     (type atom u)
     (type list precond)
     (type plan plan) )
  (let ( 
         (conflicts 
        	 (create-conflict-list-for-tuple
           	  precond estid u plan))
         (clauses nil))

    (declare
        (type list conflicts)
        (type list clauses) )

    (if (> (length conflicts) *confl-count*)
        (setq *confl-count* (length conflicts)))

    (if (null conflicts) 
	(list nil)   ;no conflict, should return the original plan.
       (let (cart-products)
         
         (declare
              (type list cart-products))

	 (setq clauses
	    (mapcar #'(lambda (conflict)
			(create-set-of-constraints
			 conflict plan))
		    conflicts))

	 (setq cart-products (create-cart-products clauses))))))


;********* create-set-of-constraints (conflict plan)

(defun create-set-of-constraints (conflict plan)
  "/tweak/conf-infer/declob.lsp
   given conflict, returns a list of sets of resolution methods."
  (declare 
     (type list conflict)
     (type plan plan) )
  (let (
         ; identify conflict classification
        (class (classify  conflict plan))
	(u     (get-conflict-u conflict))
        (pro     (get-conflict-pro   conflict))
        (n     (get-conflict-n  conflict))
        (q     (get-conflict-q conflict))
	(p     (get-conflict-p conflict)))

   (declare 
       (type atom class)
       (type atom u)
       (type atom pro)
       (type atom n)
       (type list p)
       (type list q)
     )
    (cond 
     ( (eq class 'ln)  ; linear 
	(separation-list p q))
;removed rde.
       
     ((eq class 'lf)  ; left fork
      (if (equal p q)

	  (list (list 'dem n pro))
	
	(cons
	  (list 'dem n pro)
	  (separation-list p q))))
;  removed rde.

     ((eq class 'rf)  ; right fork
      (if (equal p q)
	(list (list 'pro u n))

	 (cons
	  (list 'pro u n)
	  (separation-list p q))))

;  removed rde.
   
     ((eq class 'p)   ; parallel 
      (if (equal p q)
	(list (list 'dem n pro)
	      (list 'pro u n))
       (cons
	(list 'dem n pro)
	(cons (list 'pro u n)
	      (separation-list p q))))))))
; removed rde.


; ***************** 
(defun create-cart-products (clauses)
  "/tweak/conf-infer/declob.lsp
   if clauses=((a b c) ( d e f)), then return
   ((a d) (a e) (a f) (b d) ...)."
  (declare 
      (type list clauses))
  (cond ((null clauses) nil)
	((null (cdr clauses))
	 (mapcar 'list (car clauses)))
	(t
	 (apply 'append
		(mapcar #'(lambda (element)
			    (mapcar #'(lambda (cdr-product)
					(cons element
					      cdr-product))
				    (create-cart-products 
				     (cdr clauses))))
			(car clauses))))))
		    

; ********** apply-constraints-to-plan

(defun apply-constraints-to-plan (constraints plan)
 "/tweak/conf-infer/declob.lsp
   returns a new plan with constraints applied to."		
 (declare
    (type list constraints)
    (type plan plan) )
 (let (
       (new-plan (make-copy-of-plan plan)))
   (declare 
       (type plan new-plan) )
   (mapcar #'(lambda (constraint)
	       (apply-this-constraint-to-plan
		constraint new-plan))
	   constraints)
   new-plan))


(defun apply-this-constraint-to-plan (constraint plan)
  "/tweak/conf-infer/declob.lsp
   returns plan with constraint added."
  (declare 
      (type list constraint)
      (type plan plan) )
  (cond ((eq (type-of-constraint constraint) 'sep)
	 (add-nc-to-plan 
	  (second constraint)
	  (third constraint)
	  plan))
	((eq (type-of-constraint constraint) 'dem)
	 (add-order-to-plan
	  (second constraint)
	  (third constraint)
	  plan))
	((eq (type-of-constraint constraint) 'pro)
	 (add-order-to-plan
	  (second constraint)
	  (third constraint)
	  plan))
	(t plan)))


;********** constraint classification

(defun type-of-constraint (constraint)
  "/tweak/conf-infer/declob.lsp
   retruns type of constraint"
  (declare 
      (type list constraint))
  (first constraint))


;****** create separation list

(defun separation-list (p q)
  "/tweak/conf-infer/declob.lsp
   if p= (p1 $x a) q=(p1 $y $z), then return 
    (('sep $x $y) ('sep a $z))"
  (declare 
       (type list p)
       (type list q) )
  (remove nil
	  (mapcar #'(lambda (ele1 ele2)
			     (if (not (equal ele1 ele2))
				 (list 'sep ele1 ele2)
			       nil))
		  p q)))

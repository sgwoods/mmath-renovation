; /Tweak/Conf-infer/declob.lsp

; Written by Steve Woods, June 1990
; Modified by Qiang Yang, Sept 1990
;             Steve Woods Oct  1990

; ;***********DECLOBBERING

(defun declobber-all (intermediates U precond)
  "/Tweak/Conf-infer/declob.lsp
   Returns a list of all plans created from 
   result of Declobbering each intermediate all ways possible"
   (declare 
       (type (list list) intermediates)
       (type atom U)
       (type list precond) )

   (if (eq (car intermediates) nil) ; No one to expand.
       nil
     (apply 'append
	    (mapcar #'(lambda (inter)
			(let (
                              (estid (get-inter-estid inter))
			      (plan (get-inter-plan inter)))
                           (declare
                                (type atom estid)
                                (type plan plan) )                        
                           (declobber estid U precond plan)))
            intermediates))))

(defun declobber (estid  U precond plan)
  "/Tweak/Conf-infer/declob.lsp
   Create list of Successors from INTERMEDIATE node"
  (declare
       (type atom estid)
       (type atom U)
       (type list precond)
       (type plan plan) )
  (let (
        (alternative-constraints
                  (create-alternative-constraints
                  	  estid U precond plan)))
    (declare
        (type (list list) alternative-constraints) )

    (mapcar #'(lambda (conjunctive-constraint)
		(apply-constraints-to-plan
		 conjunctive-constraint plan))
	    alternative-constraints)))

(defun create-alternative-constraints (estid U precond plan)
  "/Tweak/Conf-infer/declob.lsp  OLD
   returns a list of sublists, each sublist is a set of
   constraints for resolving all conflcits for 
   (estid u precond) in plan."
  (declare 
     (type atom estid)
     (type atom U)
     (type list precond)
     (type plan plan) )

  (let ( 
         (conflicts 
        	 (create-conflict-list-for-tuple
           	  precond estid U plan))
         (clauses nil))
    (declare
        (type (list list) conflicts)
        (type list clauses) )
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
  "/Tweak/Conf-infer/declob.lsp
   given conflict, returns a list of sets of resolution methods."
  (declare 
     (type list conflict)
     (type plan plan) )
  (let (
         ; Identify conflict classification
        (class (classify  conflict plan))
	(U     (get-conflict-u conflict))
        (Pro     (get-conflict-Pro   conflict))
        (N     (get-conflict-N  conflict))
        (q     (get-conflict-q conflict))
	(p     (get-conflict-p conflict)))

   (declare 
       (type atom class)
       (type atom U)
       (type atom Pro)
       (type atom N)
       (type list p)
       (type list q)
     )
    (cond 
     ( (eq class 'ln)  ; LINEAR 
	(separation-list p q))
;removed rde.
       
     ((eq class 'lf)  ; LEFT FORK
      (if (equal p q)

	  (list (list 'dem N Pro))
	
	(cons
	  (list 'dem N Pro)
	  (separation-list p q))))
;  removed rde.

     ((eq class 'rf)  ; RIGHT FORK
      (if (equal p q)
	(list (list 'pro U N))

	 (cons
	  (list 'pro U N)
	  (separation-list p q))))

;  removed rde.
   
     ((eq class 'p)   ; PARALLEL 
      (if (equal p q)
	(list (list 'dem N Pro)
	      (list 'pro U N))
       (cons
	(list 'dem N Pro)
	(cons (list 'pro U N)
	      (separation-list p q))))))))
; removed rde.


; ***************** 
(defun create-cart-products (clauses)
  "/Tweak/Conf-infer/declob.lsp
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
 "/Tweak/Conf-infer/declob.lsp
   returns a new plan with constraints applied to."		
 (declare
    (type (list list) constraints)
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
  "/Tweak/Conf-infer/declob.lsp
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
  "/Tweak/Conf-infer/declob.lsp
   retruns type of constraint"
  (declare 
      (type list constraint))
  (first constraint))


;****** create separation list

(defun separation-list (p q)
  "/Tweak/Conf-infer/declob.lsp
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

(defun mr-declob (single-step-conflicts plan)
  "returns a set of successors plans, each is free of conflicts
by the single step."

  (let (complete-set
	all-constraints 
	dem-constraint 
	pro-constraint 
	nonco-constraints
	(constraints 
	 (mapcar #'(lambda (conflict)
		     (create-set-of-constraints conflict plan))
		 single-step-conflicts)))
    
    (setq all-constraints
	  (remove-duplicates
	   (apply 'append constraints)
	   :test 'equal))

    (setq dem-constraint
	  (first (member-if
		  #'(lambda (constraint)
		      (equal 'dem (first constraint)))
		  all-constraints)))

    (setq pro-constraint
	  (first (member-if
		  #'(lambda (constraint)
		      (equal 'pro (first constraint)))
		  all-constraints)))

    (setq nonco-constraints
	  (mapcar #'(lambda (constraint)
		      (remove-if-not
		       #'(lambda (list)
			   (member 'sep list))
		       constraint))
		  constraints))

    (setq nonco-constraints
	  (create-cart-products nonco-constraints))

    (setq complete-set 
	  (remove nil
		  (remove (list nil)
			  (cons (list dem-constraint )
				(cons (list pro-constraint)
				      nonco-constraints))
			  :test 'equal))
	  )


    (mapcar #'(lambda (conjunctive-constraint)
		(apply-constraints-to-plan
		 conjunctive-constraint plan))
	    complete-set)))



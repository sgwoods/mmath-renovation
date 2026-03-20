;;; -*- Syntax: Common-lisp; Package: USER -*-
;;; Copyright 1987 by Henry A. Kautz
;;; No warranty as to the correctness or usefulness of this software
;;; is given or implied.
;;;
;;; The author may be contacted at the following addresses:
;;; :uucp:	allegra!kautz		
;;; :arpa: or :csnet:	kautz@research.att.com
;;; :old style csnet: 	kautz%allegra@btl.csnet
;;; :mail:	AT&T Bell Laboratories	
;;;		Room 2C-407
;;;		600 Mountain Ave.	
;;;		Murray Hill, N.J. 07974	

(defvar *constraint-propagated* nil)

;;;; roleval (node role)
;;;   returns value of node's role, or nil if not known.  Also returns nil
;;;   if first argument is nil.

;;;; rolechain-val (node rolechain)
;;;   like roleval, but rolechain may be either a role name, or a list of
;;;   role names.  A path to the value is found by tracing roles left to right.
;;;   Note: we never use more than 2 elements in a rolechain list.
;;;      Actually returns a secret second value, which is t if the rolechain
;;;      is prematurely terminated:  example:
;;;         (rolechain-val 'N1 '(fee fum))  => nil
;;;            means (roleval 'N1 'fee) is not nil, but
;;;            (roleval (roleval 'N1 'fee) 'fum) is nil.
;;;         (rolechain-val 'N1 '(fee fum))  => nil t
;;;            means (roleval 'N1 'fee) is nil

(defun rolechain-val (node rolechain)
   (cond
      (  (and (null node) (not (null rolechain)))
         (values nil t)
      )
      (  (null node)
         (values nil)
      )
      (  (null rolechain)
         (values node)
      )
      (  (atom rolechain)
         (roleval node rolechain)
      )
      (  t
         (rolechain-val (roleval node (car rolechain)) (cdr rolechain))
      )
   )
)

;;;; refs are of the form:
;;;;  role
;;;;  (role1 role2 ...)
;;;;  (quote value)
;;;;  (^ function-name ref1 ref2 ...) 
;;;;      applies function to list of args
;;;;  (^^ function-name ref1 ref2 ... ref-last) 
;;;;      applies function to value of ref-last, with earlier args consed on front of ref-last
;;;; immediate-ref? (ref)
(defun immediate-ref? (ref)
   (and (consp ref) (eql (car ref) 'quote))
   )

;;;; function-ref? (ref)
(defun function-ref? (ref)
  (and (consp ref) (or (eql (car ref) '^) (eql (car ref) '^^)))
  )

;;;; relative-ref? (ref)
(defun relative-ref? (ref)
  (and (not (immediate-ref? ref)) (not (function-ref? ref)))
  )

;;;; direct-parameter? (rolechain)
(defun direct-parameter? (rolechain)
  (or (atom rolechain)
      (and (relative-ref? rolechain) (null (cdr rolechain)))
      )
  )
   
;;;; add-rolechain-val (node rolechain value)
;;;   like add-parameter-arc, but rolechain may be either a role name, or 
;;;   a list of role names.  Does nothing if the rolechain yields no node
;;;   on its next-to-last element.  Returns nil if not added, okay value.
(defun add-rolechain-val (node rolechain value)
   (cond
      (  (null node)
         nil
      )
      (  (null rolechain)
         (error "bad rolechain")
      )
      (  (atom rolechain)
         (add-roleval node rolechain value)
         value
      )
      (  (null (cdr rolechain))
         (add-rolechain-val node (car rolechain) value)
      )
      (  t
         (add-rolechain-val (roleval node (car rolechain)) (cdr rolechain) value)
      )
   )
)


;;;; (eq-constraints kind)
;;;   returns list of equality constraints for kind, which equate a parameter
;;;   of kind to a parameter of some step of kind.  
;;;      Access functions:  if (member x (param-eq-constraints kind))
;;;         (eq-constr-left x)        
;;;         (eq-constr-right x)      
;;;   It does not handle true "functional" parameter constraints, as used
;;;   by e.g. loc(obj(e)) = dest(step1(e))
;;;   Why not?  For one thing, such functions are actually fluents, so we
;;;   would have to deal with a temporal argument as well, and not just
;;;   use pointers.


;;;; check-equality-constraints (node kind &optional modify-steps)
;;;   evaluate all constraints associated with kind which compute parameters
;;;   of node based on steps of node.  Assert parameter roles.  If a role
;;;   is assigned two different values, then mark node as failed and return
;;;   false; otherwise, return okay.
;;;   If the optional parameter modify-steps is true, then constraints are passed downward
;;;   to steps.

(defun check-eq-constraints (node kind &optional modify-steps)
   (let (leftval no-left rightval no-right)
      (dolist (constr (eq-constraints kind))
	 (msetq (leftval no-left) (normalize node (eq-constr-left constr)))
	 (msetq (rightval no-right) (normalize node (eq-constr-right constr)))
	 (unless
	    (or
	       no-right
	       no-left
	       (and
		  (check-eq-oneway node (eq-constr-left constr)
		     leftval 
		     rightval modify-steps)
		  (check-eq-oneway node (eq-constr-right constr)
		     rightval 
		     leftval modify-steps)
		  )
	       )
	    (mark-as-failed node)
	    (return-from check-eq-constraints fail)
	    )
	 )
      (return-from check-eq-constraints okay)
      ))


;;;; check-eq-oneway (node leftpath leftval rightval &optional modify-steps)
;;;    constrain the leftpath role of node, which currently has
;;;    leftval, to be equal to rightval.  If leftval is
;;;    nil, and leftpath is a direct parameter of node, or the
;;;    modify-step option is given, then add rightval as the value
;;;    of leftpath.
;;;    Return ok or fail if
;;;    the constraint cannot be satisfied.

(defun check-eq-oneway (node leftpath leftval rightval &optional modify-steps)
   (cond
      ((null rightval))
      ((and
	  (null leftval)
	  (or
	     (direct-parameter? leftpath)
	     (and (relative-ref? leftpath) modify-steps)))
	 (add-rolechain-val node leftpath rightval)
	 (setq *constraint-propagated* t)
	 )
      ((and leftval rightval)
	 (if (provably-unequal-values? leftval rightval)
	    (then
	       (blab "equality constraint violated ~A = ~A" leftval rightval)
	       (mark-as-failed node)
	       (return-from check-eq-oneway fail)
	       )
	    )
	 )
      )
   (return-from check-eq-oneway okay)
   )

;;;; (normalize node ref)
(defun normalize (node ref)
  (cond
      ((immediate-ref? ref) (cadr ref))
      ((function-ref? ref)
	  (if (eql (car ref) '^)
	      (then
		  (apply (cadr ref)
		      (mapcar #'(lambda (arg) (or (normalize node arg)
						  (return-from normalize nil)))
			  (cddr ref)
			  )
		      )
		  )
	      (else
		  (apply (cadr ref)
		      (apply #'list*
			  (mapcar #'(lambda (arg) (or (normalize node arg)
						      (return-from normalize nil)))
			      (cddr ref)
			      )
			  )
		      )
		  )
	      )
	  )
      (t (rolechain-val node ref))
      )
  )

;;;; normalize-fact (node fact-constr)
;;;   converts node-relative constraint to normal propositional form.
;;;   arguments to proposition are parameters of node.
;;;   if any arguments are missing, nil is returned.
;;;       Each fact constraint is of the form
;;;          (predicate arg1 arg2 ...)
;;;       where each argument is either:
;;;            an immediate value, of the form (quote value)
;;;            a function reference, of the form (^ function ref1 ref2 ...)
;;;            a node-relative rolechain
(defun normalize-fact (node fact-constr)
  (cons (car fact-constr)
      (mapcar
	  (function 
	      (lambda (arg)
		(or (normalize node arg) (return-from normalize-fact nil))
		)
	      )
	  (cdr fact-constr)
	  )
      )
  )

;;;; check-fact-constraints (node kind)
;;;   use known parameters of node to evaluate non-temporal predicate
;;;   constraints.  If any are provably false, then mark node as failed 
;;;   and return false; otherwise, return okay.
(defun check-fact-constraints (node kind)
   (let (proposition)
      (dolist (constr (fact-constraints kind))
	 (setq proposition (normalize-fact node constr))
	 (if (and proposition (provably-false? proposition))
	    (then
	       (blab "fact constraint violated ~A" proposition)
	       (mark-as-failed node)
	       (return-from check-fact-constraints fail)
	       )
	    )
	 )
      (return-from check-fact-constraints okay)
      ))

;;;; check-constraints (node kind)
;;;   check equality constraints; if successful, check fact
;;;   and property (temporally relative) constraints.
(defun check-constraints (node kind)
   (blab "checking constraints on ~A" node)
   (setq *constraint-propagated* t)
   (do () ((null *constraint-propagated*) t)
      (setq *constraint-propagated* nil)
      (blab "*  checking ...")
      (unless (and 
		 (check-eq-constraints node kind)
		 (check-time-constraints node kind)
		 (check-fact-constraints node kind)
		 )
	 (return-from check-constraints fail)
	 )
      )
   (blab "~A is okay" node)
   (return-from check-constraints okay)
   )

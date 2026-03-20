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


;;;; match-down (n1 g1 n2 g2 g3) returns n3 or nil
;;;    try to match node n1 in g1 to node n2 in g2.  
;;;    check kinds of n1 and n2 for compatibility.
;;;    Either find or create node n3, which has the most specific kind
;;;    of n1 and n2.  If new, record that n3 is the result of matching
;;;    n1 and n2.
;;;    Copy parameters from n1 and n2 to n3, and check constraints.
;;;    Recursively match the structure below n1 and n2 and hook it up
;;;    to n3.
;;;    Check the constraints at n3 again.  
;;;    If n3 passes all these test, return it.  O/w, mark n3 as failed
;;;    and return nil.  
;;;    NOTE:  If we want to pass constraints downward, then will have
;;;    to do a final recursive constraint check on all nodes.  If
;;;    downward constraints check for multiple uses, then whenever a
;;;    node is eliminated, then a constraint may be allowed to pass
;;;    downward... requiring yet another constraint check down below.
;;;    So what we need is to have a loop which keeps doing the
;;;    recursive consistency check until no constraints are
;;;    propagated.  Can check for this by adding a second return value
;;;    to the check constraint routines, which is true just in case
;;;    checking the constraint actually caused some parameter to be
;;;    modified. 

(defun match-graphs (g1 g2 g3 &optional fact-list)
  (let*
      (   (n1 (end-node-of g1))
	  (n2 (end-node-of g2))
	  )
     (unless (and n1 n2)
	(error "no end node"))
    (initialize-graph g3)
    (use-graph g3)
    (add-facts fact-list)
    (match-down n1 g1 n2 g2)
    )
  )

(defun alternatives-or-self (node graph)	
  (let ((answ (alternatives-for node graph)))
    (if (null answ)
	(list node)
	answ)
    )
  )

(defun match-down (n1 g1 n2 g2)
   (let (n3 n1-step n2-step n3-step status alt3
	 n1-kind n2-kind n3-kind)
      (blab "trying to match ~A with ~A" n1 n2)
      (setq n3 (match-of n1 g1 n2 g2))
      (if n3
	 (if (failed? n3)
	    (then (return-from match-down fail))
	    (else (return-from match-down n3))
	    )
	 )
      (setq   n1-kind (kind-of n1 g1))
      (setq n2-kind (kind-of n2 g2))
      (setq n3-kind (lower-bound-kind n1-kind n2-kind))
      (if (null n3-kind) (return-from match-down fail))
      (setq n3 (new-node n3-kind))
      (add-node n3 n3-kind)
      (add-match n1 g1 n2 g2 n3)
      (add-roleval-list n3 (known-param&time-rolevals n1 n1-kind g1))
      (dolist (rv (known-param-rolevals n2 n2-kind g2))
	 (unless (check-eq-oneway n3 (roleval-descr-role rv)
		    (roleval n3 (roleval-descr-role rv))
		    (roleval-descr-value rv))
	    (mark-as-failed n3)
	    (return-from match-down fail)
	    )
	 )
      (dolist (rv (known-time-rolevals n2 n2-kind g2))
	 (unless (check-time-oneway n3 (roleval-descr-role rv)
		    (roleval n3 (roleval-descr-role rv))
		    'equals
		    (roleval-descr-value rv))
	    (mark-as-failed n3)
	    (return-from match-down fail)
	    )
	 )
      (unless (check-constraints n3 n3-kind)
	 (return-from match-down fail)
	 )
      (dolist (step-role (steps-of n3-kind))
	 (setq n1-step (roleval n1 step-role g1))
	 (setq n2-step (roleval n2 step-role g2))
	 (if (or n1-step n2-step)
	    (then
	       (setq n3-step
		  (cond
		     ((and n1-step n2-step)
			(match-down n1-step g1 n2-step g2))
		     (n1-step (copy-down n1-step g1))
		     (n2-step (copy-down n2-step g2))
		     )
		  )
	       (unless n3-step
		  (mark-as-failed n3)
		  (return-from match-down fail)
		  )
	       (add-step-arc n3 step-role n3-step)
	       )
	    )
	 )
      (unless (check-constraints n3 n3-kind)
	 (return-from match-down fail)
	 )
      (setq status fail)
      (dolist (alt1 (alternatives-or-self n1 g1))
	 (dolist (alt2 (alternatives-or-self n2 g2))
	    (if (and (eql alt1 n1) (eql alt2 n2))
	       (then
		  (setq status okay)
		  )
	       (else
		  (setq alt3 (match-down alt1 g1 alt2 n2))
		  (if alt3
		     (then
			(add-alternative alt3 n3)
			(setq status okay)
			)
		     )
		  )
	       )
	    )
	 )
      (unless status
	 (mark-as-failed n3)
	 (return-from match-down fail)
	 )
      ;; Note: we may have to add code here to raise
      ;; newly determined parameters and time bounds
      ;; from alternatives.  What if there are multiple
      ;; alternatives, which would force n3 to split?
      ;; Either only raise what is in common, or split.
      (blab "successful match of ~A and ~A yields ~A" n1 n2 n3)
      (return-from match-down n3)
      ))

     
(defun copy-down (n1 g1)
   (let (n3 n1-step n3-step status alt3 n1-kind n3-kind)
      (setq n3 (match-of n1 g1 n1 g1))
      (if n3
	 (if (failed? n3)
	    (then (return-from copy-down fail))
	    (else (return-from copy-down n3))
	    )
	 )
      (setq n1-kind (kind-of n1 g1))
      (setq n3-kind n1-kind)
      (setq n3 (new-node n3-kind))
      (add-node n3 n3-kind)
      (add-match n1 g1 n1 g1 n3)
      (add-roleval-list n3 (known-param&time-rolevals n1 n1-kind g1))
      (unless (check-constraints n3 n3-kind)
	 (return-from copy-down fail)
	 )
      (dolist (step-role (steps-of n3-kind))
	 (setq n1-step (roleval n1 step-role g1))
	 (if n1-step
	    (then
	       (setq n3-step (copy-down n1-step g1 ))
	       (unless n3-step
		  (mark-as-failed n3)
		  (return-from copy-down fail)
		  )
	       (add-step-arc n3 step-role n3-step)
	       )
	    )
	 )
      (unless (check-constraints n3 n3-kind)
	 (return-from copy-down fail)
	 )
      (setq status fail)
      (dolist (alt1 (alternatives-or-self n1 g1))
	 (if (eql alt1 n1)
	    (then
	       (setq status okay)
	       )
	    (else
	       (setq alt3 (copy-down alt1 g1))
	       (if alt3
		  (then
		     (add-alternative alt3 n3)
		     (setq status okay)
		     )
		  )
	       )
	    )
	 )
      (unless status
	 (mark-as-failed n3)
	 (return-from copy-down fail)
	 )
      ;; Note: we may have to add code here to raise
      ;; newly determined parameters and time bounds
      ;; from alternatives.  What if there are multiple
      ;; alternatives, which would force n3 to split?
      ;; Either only raise what is in common, or split.
      (blab "copying ~A yields ~A" n1 n3)
      (return-from copy-down n3)
      ))

     
   

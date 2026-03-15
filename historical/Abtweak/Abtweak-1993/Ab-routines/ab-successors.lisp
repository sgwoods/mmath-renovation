; /abtweak/ab-successors.lsp

;***************************************************************************
;*  abtweak successor creation
;***************************************************************************

(defun ab-successors (plan &aux level)
  "abtweak/ab-successors.lsp
   find successors of plan at level k of criticality:
   when level k plan completed, ie no prob exists, advance to
   level k-1, unless k=0, in which case there are no successors."
  (declare 
      (type array plan))
   
  (setq level (plan-kval plan))

  (cond (;(and (not *first-time*))  ; completeness for bad hierarchies.

	 (ab-mtc plan)  ; plan correct at level k.
	 (let* (
		;; descend abstraction hier to level k-1
		;; note op-count level indicators updated at this point
		(new-level-plan-list (list (add-a-level plan))) )

	(declare
	 (type (list array) new-level-plan-list))
	;; count # ab exp nodes
	(setq *abs-node-count* (1+ *abs-node-count*))
	(setq *first-time* t)
	(if *drp-mode*     ;downward refinement property.
	    (let ()
	      (if *open* (push *open* *drp-stack*))
	      (setq *open* nil)))
	(setf (aref *new-refinement-p* level) t)
	(increment-abs-branching-count level)
	(update-abs-ref-counts level)
	(update-abs-succ-counts (1+ level))
	(if *drp-debug-mode*
	    (let ()
	      (format *standard-output* 
		      "~% Solution (*sol*) found on level ~D ~&" level)
	      (show-ops (setq *sol* plan))
	      (break)))
	(setq *curr-level* (1- level))
	new-level-plan-list   ; return abstract plan in a list alone
	))

	;; if drp-mode is on, then check if *curr-level* is changed from
	;; i-1 to i.  If so, then an abstract level backtracking occured.
	;; Consequently, one should check *abs-branching-counts* at i,
	;; to see if it has exceeded the limit *abs-branching-limit*.
	;; If so, then *drp-stack* should be dumped till level i+1 plan
	;; appears.  

	;; Else normal tweak successors
	(t (let* (precond-index
		  (u-and-p  (ab-determine-u-and-p plan))
		  (u (first u-and-p))  ; sel an op w unsat preconds at level k
		(p (second u-and-p)) ; sel an unsat lev k pre p in this u
		intermediates 
		successors estid-list)

          (declare 
             (type list u-and-p)
             (type atom u)
             (type list p)   
             (type (list list) intermediates)
             (type (list plan) successors) )

	  (setq *abs-backtracking-flag* nil)
	  (setq precond-index (precond-to-index p u plan))

	  (setq *first-time* nil)

	  ;;if precond is abstract, and mp-mode on, then only resolving
	  ;; conflicts.  Modified by Qiang according to Josh's comments.  
	  ;; Oct 29, 91.

	  (cond ((and *mp-mode* 
		      (< (plan-kval plan) 
			 (find-crit p))
		      (setq estid-list 
			    (third (first (member
					   p
					   (plan-cr plan)
					   :test
					   #'(lambda (p cr)
					       (eq p (second cr))))))))
		 (setq intermediates
		       (mapcar #'(lambda (estid)
				   (list estid (copy-plan plan)))
			       estid-list)))

	   ;; each intermediates is a list of pairs 
	   ;;(establisher-id new-plan)

		  (t (setq intermediates 
			   (remove-if
			    #'(lambda (pair) (invalid-p (second pair)))
			    ;; remove pair when pair=(est-id invalid-plan)
			    (append 
			     (find-exist-ests plan u p)            
			     (find-new-ests plan u p))))))

	  (setq successors 
		(declobber-all intermediates u precond-index))

	  ;; remove plans flagged as invalid 
	  ;;-ie conflicting constraints exist
	  ;;and any that violate the mp property
	  (setq successors  (remove-if 
			     'violates-mp 
			     (remove-if 
			      'invalid-p successors)))

	  ;; check for current maximum successor size, 
	  ;;and update if nec.  
	  (if (< *max-succ-count* (length successors)) 
	      (setq *max-succ-count* (length successors)))
	  successors))))


; ------- Supporting Functions.-------------

(defun precond-to-index (precond userid plan)
  "returns the index of precond in user of plan"
   (1- 
    (length 
     (member precond 
	     (reverse (get-preconditions-of-opid userid plan))
	     :test 'equal))))


(defun index-to-precond (precond-index userid plan)
  (nth precond-index (get-preconditions-of-opid userid plan)))


; ---------- Determine User and Precond for Abtweak.

(defun ab-determine-u-and-p (plan)
  "
   returns (list u p) where u is an operator with precondition
   p possibly unsatisfied.
   note: the current implementation will find either a random up, a 
   tree up, or the first up in a list"

  (declare 
     (type array plan))

  (cond ((equal *subgoal-determine-mode* 'random)
					; random u and p
	 (ab-determine-random-u-and-p plan))
	((equal *subgoal-determine-mode* 'stack) 
	 (ab-determine-first-u-and-p  plan))))


(defun ab-determine-first-u-and-p (plan)
  "abtweak/ab-successors.lsp  
   returns (list u p) where u is an operator with precondition
   p possibly unsatisfied, where p has a criticality = kval of plan
   note: the current implementation will find the first u and p. "

  (declare 
     (type array plan))

  (let ( (result nil) )
   (dolist (opid (get-opids-from-plan plan)
		 result)
                   ; find all preconditions of opid at level k
	   (dolist (precondition 
		    (adjust-pre-list  opid
				      (get-preconditions-of-opid opid plan)
				      (plan-kval plan)) )
					; this opid-precondition does not hold
		   (if ;(or *first-time*  ;completeness for bad hierarchy.
			   (not (hold-p plan opid precondition))
		       (return (setq result (list opid precondition)))
		     nil)
		   )
	   (if result (return result))
	   )))

(defun ab-determine-random-u-and-p (plan)
  "abtweak/ab-successors.lsp
   returns (list u p) where u is an operator with precondition
   p possibly unsatisfied.
   note: the current implementation will find a random u and p. "
  (declare (type array plan))
  (random-element (ab-unsat-up-pairs plan)))

(defun ab-unsat-up-pairs (plan)
 "abtweak/successors.lsp 
  return a list of all unsatisfied (user precondition) pairs in plan"

  (declare (type array plan))

  (remove-if #'(lambda (pair)
		 (hold-p plan (first pair) (second pair)))
	     (mapcan #'(lambda (opid) 
		  (mapcar #'(lambda (pre) 
				(list opid pre ))
			    (adjust-pre-list opid
					   (get-preconditions-of-opid opid plan)
                             (get_kval plan) )))
            (get-opids-from-plan plan))))



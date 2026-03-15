;;; Successor generation procedure for the MR-plan successor routine.
;;; input: a plan structure instance.  
;;; output: a list of successor plans.

;;; Note.  Algorithm for successor generation.  
;;;(1) if a cr is threatened, then protect all cr.
;;;(2) else, 
;;;      (a) find a precond p with no cr,
;;;      (b) get all new and existing producers of p
;;;      (c) for each producer, generate a corresponding successor,
;;;          with a set of causal relations. 
;;;
;;; Note:   Each causal relation is a <user precondition (list producer)>.

;*********** successors ***********

(setq *mr-debug* nil)

(defun mr-successors ( plan )
  "AI-programs/Abtweak/Mcallester-plan/successors.lsp.
   It generates all successors of plan."

 (declare 
    (type array plan))

 (let (successors
       (one-mr-conflicts (find-one-mr-conflict plan)))
   (cond
    (one-mr-conflicts
     (setq successors (mr-declob one-mr-conflicts plan))
     (if *mr-debug*
	 (let ()
	   (format *standard-output* "~% Conflict! ~%")
	   (setq p plan)
	   (setq c one-mr-conflicts)
	   (setq s successors)
	   (break)))
     successors)

    (t ; No threatening exists.  Thus, achieve new precond.
     (let* (
	    (user-and-precond  (mr-determine-user-and-precond plan))
	    (user-id (first user-and-precond))
	    (precond (second user-and-precond))
	    (precond-index (precond-to-index precond user-id plan))
	    (intermediates
	     (append 
	      (find-exist-ests plan user-id precond)            
	      (find-new-ests plan user-id precond))))

       ;; each intermediate plan is like (producer-id new-successor).
   
       (declare 
	(type list user-and-precond)
	(type atom user-id)
	(type list precond)   
	(type list intermediates)
	(type (list plan) successors) )

       (setq producer-id-list (mapcar 'first intermediates))
       (setq successors 
	     (add-cr-to-successors user-id 
				   precond-index intermediates))
       (if *mr-debug* 
	   (let ()
	     (format *standard-output* "~% New Precond! ~%")
	     (setq s successors)
	     (setq p plan)
	     (setq up user-and-precond)
	     (break)))
       successors)))))

;***********************************************************
; Supporting Routines.
; 1. precond-to-index
; 2. index-to-precond
; 3. determine-user-and-precond
; 4. add-cr-to-successors
;***********************************************************

(defun precond-to-index (precond userid plan)
  "returns the index of precond in user of plan"
   (1- 
    (length 
     (member precond 
	     (reverse (get-preconditions-of-opid userid plan))
	     :test 'equal))))

(defun index-to-precond (precond-index userid plan)
  (nth precond-index (get-preconditions-of-opid userid plan)))


;***********************************************************
; determine-user-and-precond
;***********************************************************


(defun mr-determine-user-and-precond (plan)
  "Returns (list user precond) where user is 
   an operator with precondition
   precond possibly unsatisfied.
   note: the current implementation will find 
   either a random (user precond), a
   first (user precond) in the (plan-a plan) list"
   

  (declare 
     (type array plan))

  (let (
        (user-and-precond
          (cond 
	   ((equal *subgoal-determine-mode* 'random)            ; random user and precond
	    (determine-random-user-and-precond plan))
	   ((equal *subgoal-determine-mode* 'stack)            ; first user and precond
	    (mr-determine-first-user-and-precond  plan))))   ; first from a list (stack)
        )

     user-and-precond))

; Stack Mode, the first user and precond in the operator list is selected.

; ---  determine-first-user-and-precond (plan) ---

(defun mr-determine-first-user-and-precond (plan)
  "
   Returns (list user precond) where u is an operator with precondition
   p possibly unsatisfied.
   note: the current implementation will find the first u and p. "

  (declare 
     (type array plan))

  (let ( (result nil)
	 (level (plan-kval plan))
	 )
   (dolist (opid (get-opids-from-plan plan)
		 result)
      (dolist (precondition (get-preconditions-of-opid opid plan))
	      ;; this opid-precondition does not hold
                (if (and
		     (>= (find-crit precondition) level)
		     (not (produced-already-p plan opid precondition)))
                    (return (setq result (list opid precondition)))
                    nil)
        )
       (if result (return result))
    )))

(defun produced-already-p (plan user-id precondition)
  "returns T if and only if there is an entry of plan-cr for which
   the cdr of <userid precondition (list producerid)> exists already."
  (member (list user-id 
		precondition)
	  (plan-cr plan)
	  :test #'(lambda (list1 list2)
		    (equal list1 (list (first list2)
				       (second list2))))))
;****************************************************************
;        add-cr-to-successors
;****************************************************************

(defun add-cr-to-successors (user-id precond-index producer-plan-list)
  "Each element of plan-producerid-list is a list (plan producer-id).
   Returns each plan with <user-id precond (list producer-id)> added to  plan-cr."
  (mapcar #'(lambda (producer-plan-pair)
	      (let ((plan (second producer-plan-pair))
		    (producer-id (first producer-plan-pair)))
		(setf (plan-cr plan)
		      (cons (list user-id 
				  (index-to-precond precond-index
						    user-id plan)
				  (list producer-id ))
			    (plan-cr plan)))
		plan))
	  producer-plan-list))


;**************** routines below are not changed from Abtweak.*******
; May 23, 1991
;********************************************************************
					
; --- determine-random-user-and-precond (plan) ---

(defun determine-random-user-and-precond (plan)
  "tweak/successors.lsp
   returns (list user precond) where u is an operator with precondition
   p possibly unsatisfied.
   note: the current implementation will find a random u and p. "
  (declare (type plan plan))
  (random-element (unsat-user-precond-pairs plan)))


; --- (defun unsat-user-precond-pairs (plan) ---

(defun unsat-user-precond-pairs (plan)
 "tweak/successors.lsp 
  return a list of all unsatisfied (user precondition) pairs in plan"

  (declare (type plan plan))

  (remove-if #'(lambda (pair)
                  (hold-p plan (first pair) (second pair)))
      (mapcan #'(lambda (opid) 
                    (mapcar #'(lambda (pre) 
                                 (list opid pre ))
                          (get-preconditions-of-opid opid plan)))
            (get-opids-from-plan plan))))



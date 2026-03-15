; /Tweak/successors.lsp

; Successor generation procedure for the search routine.
;
; input: a plan structure instance.  
; output: a list of successor plans.
;

;*********** successors ***********

(defun successors ( plan )
  "/Tweak/successors.lsp
   generates all successors of plan: 1. finding out all establishers for 
   an unachieved precondition p of user u.  2. making each 
   establisher necessary."

 (declare 
    (type array plan))

 (let* (precond-index
        (user-and-precond  (determine-user-and-precond plan))
      
; sel an oper with unsat preconds
	(user (first user-and-precond))
	(precond (second user-and-precond))
	
					;sel an unsatisfied precond in this user
					; each intermediates is a list 
					;of pairs (establisher-id new-plan)
	(intermediates 
	 (remove-if
	  #'(lambda (pair) (invalid-p (second pair)))

					; remove pair when pair= 
					;(est-id invalid-plan)
	  (append 
	   (find-exist-ests plan user precond)            
	   (if (not *existing-only* )
		    (find-new-ests plan user precond)
	     nil))))
	successors)
   
   (declare 
      (type list user-and-precond)
      (type atom user)
      (type list precond)   
      (type list intermediates)
      (type (list plan) successors) )

   (setq precond-index (precond-to-index precond user plan))
   
   (setq successors (declobber-all intermediates user precond-index))

        ; remove plans flagged as invalid -ie conflicting constraints exist.
   (setq successors (remove-if 'invalid-p successors))

        ; check for current maximum successor size, and update if nec
   (if (< *max-succ-count* (length successors)) 
       (setq *max-succ-count* (length successors)))

   successors))


;***********************************************************
; Supporting Routines.
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
; Subgoal Selection Routines.
;***********************************************************


(defun determine-user-and-precond (plan)
  "Tweak/successors.lsp
   returns (list user precond) where user is 
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
	   (t            ; first user and precond
	    (determine-first-user-and-precond  plan))))   ; first from a list (stack)
        )

     user-and-precond))

; Stack Mode, the first user and precond in the operator list is selected.


; ---  determine-first-user-and-precond (plan) ---

(defun determine-first-user-and-precond (plan)
  "Tweak/successors.lsp
   returns (list user precond) where u is an operator with precondition
   p possibly unsatisfied.
   note: the current implementation will find the first u and p. "

  (declare 
     (type array plan))

  (let ( (result nil) )
   (dolist (opid (get-opids-from-plan plan)
		 result)
      (dolist (precondition (get-preconditions-of-opid opid plan))
                   ; this opid-precondition does not hold
                (if (not (hold-p plan opid precondition))
                    (return (setq result (list opid precondition)))
                    nil)
        )
       (if result (return result))
    )))

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

;;; Termination Condition for McAllester-Rosenblitt planner.

(defun mr-goal-p (plan)
  "T iff plan is correct:
  (1) No open preconditions, and (2) no threatened causal links."

  (if (zerop (plan-kval plan))
      (and (null (mr-determine-user-and-precond plan))
	   (null (find-one-mr-conflict plan)))

    (let ((level (plan-kval plan)))  ; else, kval not = 0.
      ;; use criticality to guide search.
      ;; crit values are stored in (plan-kval plan).
      (do ((i level (1- i)))
	  ((= (plan-kval plan) -1) t)
	  ;; if i=-1, then plan is correct at level 0.  Thus, True.
	  ;; Else, if plan is correct at current level, then 
	  ;; decrease level by 1, and continue checking.
	  (if 
	      (and (null (mr-determine-user-and-precond plan))
		   (null (find-one-mr-conflict plan)))
	      (setf (plan-kval plan) i)
	     (return nil))))))

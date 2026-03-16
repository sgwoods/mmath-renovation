; /abtweak/ab-mp-check.lsp

; ***************************************************************************
; check plan for msp protection violation, discard if violation exists
;***************************************************************************


(defun violates-mp (plan)
   "
    check plan for mp protection violation as indicated for this run"
  (declare (type plan plan))

   (if (null *mp-mode*)
       nil                    
					;return nil - no violation
     (violates-mp-weak plan)))


;***************************************************************************
;  monotonic property implementation
;***************************************************************************

(defun violates-mp-weak (plan )
  "t if there is weak monotonic violation.  That is, 
   every high level establisher of a precondition
   is either negated, or cease to be one because of 
   new establishment relations inserted in the plan."

  (let* ((causal-relations (get-cr-in-plan plan))
	 (result nil))

    (dolist (relation1 causal-relations result)
	    (if (exists-mp-violation-p relation1 plan) 
		(let()
		  (setq *mp-pruned* (1+ *mp-pruned*))
		  (return (setq result t)))))))


(defun exists-mp-violation-p (relation plan)
  "t if there is mp violation for this relation.
   each relation is of the form: (user precond (est1 est2 ...))"

  (let ((establishers (get-producer-list-in-cr relation))
	(mp-exists t))
    (dolist (est establishers mp-exists)
	    (setq mp-exists 
		  (and mp-exists
		       (this-one-violated 
			est 
			(get-condition-in-cr relation)
			(get-user-in-cr relation) plan))))))

(defun normalized-mp-weak-mode ()
  "Return the supported weak-MP compatibility mode."
  (if (eq *mp-weak-mode* 'pos)
      'pos
    'nec))

(defun mp-est-p (operator condition plan)
  "Test whether OPERATOR establishes CONDITION under the selected weak-MP mode."
  (case (normalized-mp-weak-mode)
    (pos
     (if (eq *domain* 'nilssons-blocks-world)
	 (np-est-p operator condition plan)
       (poss-est-p operator condition plan)))
    (t
     (nece-est-p operator condition plan))))

(defun mp-violates-condition-p (operator condition plan)
  "True when OPERATOR either clobbers CONDITION or re-establishes it."
  (or (mp-est-p operator (negate condition) plan)
      (mp-est-p operator condition plan)))

(defun this-one-violated (est condition user plan)
  "t iff this particular relation is violated."
  ;; The historical weak-MSP check scans necessarily-between operators, but
  ;; the clobbering test depends on *MP-WEAK-MODE* (NEC vs POS).  We retain
  ;; the copy-free scan to avoid allocator churn on larger Hanoi cases.
  (dolist (operator (get-opids-from-plan plan) nil)
    (when (and (not (equal operator est))
               (not (equal operator user))
               (nece-before-p est operator plan)
               (nece-before-p operator user plan)
               (mp-violates-condition-p operator condition plan))
      (return t))))

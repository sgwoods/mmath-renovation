; /abtweak/ab-mp-check.lsp

; ***************************************************************************
; check plan for msp protection violation, discard if violation exists
;***************************************************************************


(defun violates-mp (plan)
   "
    check plan for mp protection violation as indicated for this run"
  (declare (type plan plan))

   (cond ((null *mp-mode*)
          nil)
         ((eq *mp-mode* 'strong)
          (violates-mp-strong plan))
         (t
          (violates-mp-weak plan))))


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


;***************************************************************************
;  strong monotonic property implementation
;***************************************************************************

(defun violates-mp-strong (plan)
  "t if there is strong monotonic violation.
   Any necessarily clobbered establisher is enough to prune the plan."
  (declare (type plan plan))
  (let ((causal-relations (get-cr-in-plan plan))
        (result nil))
    (dolist (relation causal-relations result)
      (when (exists-strong-mp-violation-p relation plan)
        (setq *strong-mp-pruned* (1+ *strong-mp-pruned*))
        (return (setq result t))))))

(defun exists-strong-mp-violation-p (relation plan)
  "t iff any one establisher of RELATION is necessarily clobbered."
  (let ((establishers (get-producer-list-in-cr relation))
        (condition (get-condition-in-cr relation))
        (user (get-user-in-cr relation)))
    (dolist (est establishers nil)
      (when (strong-this-one-violated est condition user plan)
        (return t)))))

(defun strong-this-one-violated (est condition user plan)
  "t iff a necessarily-between operator necessarily reasserts or negates CONDITION."
  (dolist (operator (all-nece-between est user plan) nil)
    (when (or (nece-est-p operator (negate condition) plan)
              (nece-est-p operator condition plan))
      (return t))))

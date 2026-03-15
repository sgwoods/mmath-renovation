;;; A McAllester and Rosenblitt conflict is defined as:
;;; Producer ---> User with condition p, and a Step S
;;; with effect either p or \neg p, that is possibly between
;;; Producer and User.

;;; A conflict here is implemented as a list:
;;;  (list producer user condition clobberer)

(defun find-one-mr-conflict (plan)
  "returns the first conflict with cr, the causal relation (link)."

  (let ((crs (plan-cr plan))
	(conflicts-cr nil))
    (dolist (cr crs nil)
	    (let* (
		  (producer (first (third cr)))
		  (user (first cr))
		  (condition (second  cr)))
	      (setq conflicts-cr (create-conflicts-one-step
				  condition producer user plan))
		  (if conflicts-cr (return conflicts-cr))))))




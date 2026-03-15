;;; --- Successor generation routines. -----------------
(defun mr-successors&costs (plan)
"MR - returns a list of successor states and costs."
  (declare (type plan plan) )

  (mapcar #'(lambda (state) (list state (get-plan-cost state)))
               (mr-successors plan)) )

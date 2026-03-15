
(defun get-cr-in-plan (plan)
  "returns a set of causal relations in plan"
  (plan-cr plan))

(defun add-cr-to-plan (estid-list userid condition plan)
  "returns a new plan with new-cr-element added to plan-cr."
  (setf (plan-cr plan)
	(cons (list  userid condition estid-list) (plan-cr plan)))
  plan)

(defun get-producer-list-in-cr (cr-element)
  "returns producer in cr."
  (third cr-element))

(defun get-condition-in-cr (cr-element)
  "returns condition in cr-element."
  (second cr-element))

(defun get-user-in-cr (cr-element)
  "returns the user in cr"
  (first cr-element))


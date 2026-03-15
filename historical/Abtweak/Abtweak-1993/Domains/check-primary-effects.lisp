(defun check-primary-effects (ops)
  "Input:  a set of operators.  Output:  if primary effects
   of operators are nil, then set them by :effects."

  (mapcar #'(lambda (operator)
	      (if (null (operator-primary-effects operator))
		  (setf (operator-primary-effects operator)
			(operator-effects operator)))
	      operator)
	  ops))
;;; a conflict is a five-tuple: <p u n p q>, 
;;; where p---producer of p, u---user of p, n---clobberer of p for u,
;;; such that (poss-between-p n p u plan).
;;; q is condition such that (\neg q) is an effect of n, and
;;; (poss-codesignates q p plan).


(defun create-conflicts-one-step (precond establisher opid plan)
  "returns a list of conflicts for the tuple, that are due
 to one clobbering step."
  (declare
      (type list precond)
      (type atom establisher)
      (type atom opid)
      (type plan plan) )
  (let (
        (n-q-pairs (find-step-effect-pairs
		    precond establisher opid plan)))
    (declare
          (type list n-q-pairs) )
    (mapcar #'(lambda (n-q-pair)
		(list establisher opid (first n-q-pair)
		      precond (second n-q-pair)))
	    n-q-pairs)))

(defun find-step-effect-pairs (precond establisher opid plan)
  "
   returns a list of (n q), where n is a clobberer for precond
   of opid in plan, with \neg q."
  (declare 
      (type list precond)
      (type atom establisher)
      (type atom opid)
      (type plan plan) )
  (let (
        (candidates (all-poss-between establisher opid plan)))
    (declare 
     (type list candidates) )
    (dolist (candidate candidates nil)
	    (setq result 
		  (mr-n-q-pairs-for-this-candidate
		   candidate precond plan))
	    (if result (return result)))))

(defun mr-n-q-pairs-for-this-candidate  (candidate precond plan)
  "
   returns a list of (candidate q), for each effect \neg q such
   that (poss-codesignates precond q)."
  (declare 
      (type atom candidate)
      (type list precond)
      (type plan plan) )
  (let (
        (effects (get-effects-of-opid candidate plan)))
    (declare
       (type list effects) )
    (remove nil
	    (mapcar #'(lambda (q)
			(if (poss-codesignates
			     q precond plan)
			    (list candidate q) nil))
		    (append (mapcar 'negate-condition effects)
			    effects)))))




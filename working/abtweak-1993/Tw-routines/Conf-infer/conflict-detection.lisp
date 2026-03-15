; /tweak/conf-infer/conflict-detection.lsp

; written by steve woods and qiang yang 1990


; conflict detection.
;
; a conflict is a five-tuple: <p u n p q>, 
; where p---producer of p, u---user of p, n---clobberer of p for u,
; such that (poss-between-p n p u plan).
; q is condition such that (\neg q) is an effect of n, and
; (poss-codesignates q p plan).


(defun find-conflicts (plan)
  "/tweak/conf-infer/conflict-detection.lsp
   returns a list of  all conflicts in plan."
  (declare 
      (type plan plan) )
  (let (
        (opids (get-opids-from-plan plan)))
    (declare
        (type list opids))
    (apply 'append
	    (mapcar #'(lambda (opid)
			(create-conflict-list-for-opid opid plan))
		    opids))))

(defun create-conflict-list-for-opid (opid plan)
  "/tweak/conf-infer/conflict-detection.lsp
  returns a list of all conflicts with precond=u."
  (declare
      (type atom opid)
      (type plan plan) )
  (let (
        (preconds (get-preconditions-of-opid opid plan)))
    (declare
        (type list preconds) )
    (apply 'append
	    (mapcar #'(lambda (precond)
			(create-conflict-list-for-precond 
			 precond opid plan))
		    preconds))))

(defun create-conflict-list-for-precond (precond opid plan)
  "/tweak/conf-infer/conflict-detection.lsp
   if preocnd is possibly negated at opid in plan, then
   return <p opid n precond q>."
  (declare
     (type list precond)
     (type atom opid)
     (type plan plan) )
  (if (hold-p plan opid precond) nil
    (let (
          (establishers (find_establishers plan opid precond)))
      (declare 
          (type list establishers) )
      (if (null establishers)
;               p   u    n    p     q.
	  (list (list '? opid 'i precond nil))
; special structure signalling no establisher.
    (apply 'append
	    (mapcar #'(lambda (establisher)
			(create-conflict-list-for-tuple
			 precond establisher opid plan))
		    establishers))))))


(defun create-conflict-list-for-tuple (precond establisher opid plan)
  "/tweak/conf-infer/conflict-detection.lsp
   returns a list of conflicts"
  (declare
      (type list precond)
      (type atom establisher)
      (type atom opid)
      (type plan plan) )
  (let (
        (n-q-pairs (find-n-q-pairs precond establisher opid plan)))
    (declare
          (type list n-q-pairs) )
    (mapcar #'(lambda (n-q-pair)
		(list establisher opid (first n-q-pair)
		      precond (second n-q-pair)))
	    n-q-pairs)))

(defun find-n-q-pairs (precond establisher opid plan)
  "/tweak/conf-infer/conflict-detection.lsp
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
    (apply 'append
	   (mapcar #'(lambda (candidate)
		       (n-q-pairs-for-this-candidate
			candidate precond plan))
		   candidates))))

(defun n-q-pairs-for-this-candidate  (candidate precond plan)
  "/tweak/conf-infer/conflict-detection.lsp
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
		    (mapcar 'negate-condition effects)))))
			

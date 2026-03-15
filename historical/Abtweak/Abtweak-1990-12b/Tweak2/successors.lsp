; /tweak/successors.lsp

; written by steve woods, june 1990
; modified by qiang yang, sept 1990
;             steve woods oct  1990
;             qiang yang  oct  1990 - bug with establisher predicate

; successor procedure for the search routine.
;
; input: a plan structure instance.  output: a list of successor plans.
;

;*********** successors ***********

(defun successors ( plan )
  "tweak/successors.lsp
   generates all successors of plan: 1. finding out all establishers for 
   an unachieved precondition p of user u.  2. making each 
   establisher necessary."

 (declare 
    (type plan plan))

 (let* (precond-index
        (u-and-p  (determine-u-and-p plan))
      
; sel an oper with unsat preconds
	(u (first u-and-p))
	(p (second u-and-p))
	
;sel an unsatisfied precond p in this u

; each intermediates is a list of pairs (establisher-id new-plan)
	(intermediates 
	 (remove-if
	  #'(lambda (pair) (invalid-p (second pair)))

; remove pair when pair= (est-id invalid-plan)

	  (append 
	   (find-exist-ests plan u p)            
	   (find-new-ests plan u p))))
	successors)
   
   (declare 
      (type list u-and-p)
      (type atom u)
      (type list p)   
      (type (list list) intermediates)
      (type (list plan) successors) )

   (setq precond-index (precond-to-index p u plan))
   
   (setq successors (declobber-all intermediates u precond-index))

        ; display parent and children 
   (if *debug* (debug-s plan successors))

        ; remove plans flagged as invalid -ie conflicting constraints exist
   (setq successors (remove-if 'invalid-p successors))

        ; check for current maximum successor size, and update if nec
   (if (< *count* (length successors)) 
       (setq *count* (length successors)))

        ; record branching factor values for later averaging
	  (update-br-factor 0 (length successors) )

   successors))


; new-routines oct 29, qiang yang.
;*******************************************************

(defun precond-to-index (precond userid plan)
  "returns the index of precond in user of plan"
   (1- 
    (length 
     (member precond 
	     (reverse (get-preconditions-of-opid userid plan))
	     :test 'equal))))


(defun index-to-precond (precond-index userid plan)
  (nth precond-index (get-preconditions-of-opid userid plan)))

;********************************************************

(defun determine-u-and-p (plan)
  "tweak/successors.lsp
   returns (list u p) where u is an operator with precondition
   p possibly unsatisfied.
   note: the current implementation will find either a random up, a
   tree up, or the first up in a list"

  (declare 
     (type plan plan))

  (let (
        (uandp
          (if (eq *determine-mode* 'random)            ; random u and p
              (determine-random-u-and-p plan) 
              (if (eq *determine-mode* 'tree)          ; preorder tree u and p 
                  (determine-tree-u-and-p plan)
                  (determine-first-u-and-p  plan))))   ; first from a list
        )
     (if (or *debug* *show-up*)
         (progn
            (princ "<plan> selected u and p : ")
            (princ "<") (princ (plan-id plan)) (princ "> ")
            (princ uandp) (terpri)
          ))

     uandp))

(defun determine-tree-u-and-p (plan)
  "tweak/successors.lsp  nov 17/90
   returns (list u p) where u is an operator with precondition
   p possibly unsatisfied.
   note: the current implementation will find the first u and p- in the 
   preorder traversal of the plan operator tree"

  (declare 
     (type plan plan))

  (let ( (result nil) )
   (dolist (opid (pre-order (get_tree plan)) result)
      (dolist (precondition (get-preconditions-of-opid opid plan))
                   ; this opid-precondition does not hold
                (if (not (hold-p plan opid precondition))
                    (return (setq result (list opid precondition)))
                    nil)
        )
       (if result (return result))
    )))

(defun determine-first-u-and-p (plan)
  "tweak/successors.lsp
   returns (list u p) where u is an operator with precondition
   p possibly unsatisfied.
   note: the current implementation will find the first u and p. "

  (declare 
     (type plan plan))

  (let ( (result nil) )
   (dolist (opid 
	    (if *backwards* (reverse (get-opids-from-plan plan))
                            (get-opids-from-plan plan))
	    result)
      (dolist (precondition (get-preconditions-of-opid opid plan))
                   ; this opid-precondition does not hold
                (if (not (hold-p plan opid precondition))
                    (return (setq result (list opid precondition)))
                    nil)
        )
       (if result (return result))
    )))

(defun determine-random-u-and-p (plan)
  "tweak/successors.lsp
   returns (list u p) where u is an operator with precondition
   p possibly unsatisfied.
   note: the current implementation will find a random u and p. "
  (declare (type plan plan))
  (random-element (unsat-up-pairs plan)))

(defun unsat-up-pairs (plan)
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

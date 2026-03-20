;;; -*- Syntax: Common-lisp; Package: USER -*-
;;; Copyright 1987 by Henry A. Kautz
;;; No warranty as to the correctness or usefulness of this software
;;; is given or implied.
;;;
;;; The author may be contacted at the following addresses:
;;; :uucp:	allegra!kautz		
;;; :arpa: or :csnet:	kautz@research.att.com
;;; :old style csnet: 	kautz%allegra@btl.csnet
;;; :mail:	AT&T Bell Laboratories	
;;;		Room 2C-407
;;;		600 Mountain Ave.	
;;;		Murray Hill, N.J. 07974	

;  Temporal Reasoning
;  This file implements a simple system for propagating temporal information
;  through an explanation graph.  Every node has a time parameter, whose
;  value is a pair of fuzzy numbers:
;     (begin-min begin-max end-min end-max)
;  Temporal constraints are propagated like equality constraints,
;  except that the old and propagated values are merged.

;;;; check-time-constraints (node kind modify-steps)
;;;   verify and propagate temporal constraints associated with node.
;;;   if modify-steps is true, then possiblely adjust the time parameter(s)
;;;   of steps of the node.

(defun check-time-constraints (node kind &optional modify-steps)
   (let (leftval no-left rightval no-right)
      (dolist (constr (time-constraints kind))
	 (msetq (leftval no-left) 
	    (normalize node (time-constr-left constr)))
	 (msetq (rightval no-right) 
	    (normalize node (time-constr-right constr)))
	 (unless
	    (or
	       no-right
	       no-left
	       (and
		  (check-time-oneway node (time-constr-left constr)
		     leftval (time-constr-op constr) 
		     rightval modify-steps)
		  (check-time-oneway node (time-constr-right constr)
		     rightval (time-invert (time-constr-op constr)) 
		     leftval modify-steps)
		  )
	       )
	    (mark-as-failed node)
	    (return-from check-time-constraints fail)
	    )
	 )
      (return-from check-time-constraints okay)
      ))

;;;; check-time-oneway (node leftpath leftval op rightval &optional modify-steps)
;;;    constrain the leftpath role of node, which currently has
;;;    leftval, to be in the op relation to rightval.  If leftval is
;;;    nil, and leftpath is a direct parameter of node, or the
;;;    modify-step option is given, then create a time at the end of
;;;    the leftpath to receive the constraint.  Return ok or fail if
;;;    the constraint cannot be satisfied.
  

(defun check-time-oneway (node leftpath leftval op rightval
			    &optional modify-steps)
   (if (null rightval)
      (return-from check-time-oneway okay))
   (if (and 
	  (null leftval)
	  (or
	     (direct-parameter? leftpath)
	     (and (relative-ref? leftpath) modify-steps)))
      (then
	 (setq *constraint-propagated* t)
	 (setq leftval (add-rolechain-val node leftpath (make-time)))))
   (if (null leftval) (return-from check-time-oneway okay))
   (possible-time-reln? leftval op rightval 
      (or
	 (direct-parameter? leftpath)
	 (and (relative-ref? leftpath) modify-steps))      
      )
   )
   

;;;; possible-time-reln? (leftval op rightval &optional modify)
;;;   determine whether the relation (leftval op rightval) is possible.
;;;   If so, return leftval, otherwise return nil.
;;;   If modify is true, then destructively modify the structure leftval
;;;   to reflect the constraint.
;;;      This function can be used for merge, with op = 'equal
(defun possible-time-reln? (leftval op rightval &optional modify)
   (let (result)
      (setq result (legal-time 
		      (time-merge (time-pattern op rightval) leftval)))
      (if (null result) 
	 (blab "time constraint violated ~A ~A ~A" leftval op rightval))
      (if (and modify result (not (equalp leftval result)))
	 (then
	    (blab "*  time role updated")
	    (setq *constraint-propagated* t)
	    (copy-time-values leftval result)))
      (return-from possible-time-reln? result)
      ))

;;;; checks time i, returns nil if bad, i otherwise
(defun legal-time (i)
   (and
      (<=? (time-b- i) (time-b+ i))
      (<=? (time-e- i) (time-e+ i))
      (<=? (time-b- i) (time-e+ i))
      (return-from legal-time i)
   )
)

;;;; destructive merge of time j into time i
(defun time-merge (i j)
   (setf (time-b- i) (maximum (time-b- i) (time-b- j))
         (time-b+ i) (minimum (time-b+ i) (time-b+ j))
         (time-e- i) (maximum (time-e- i) (time-e- j))
         (time-e+ i) (minimum (time-e+ i) (time-e+ j))
   )
   (return-from time-merge i)
)

;;;; copies values from time j into i
(defun copy-time-values (i j)
   (setf (time-b- i) (time-b- j)
         (time-b+ i) (time-b+ j)
         (time-e- i) (time-e- j)
         (time-e+ i) (time-e+ j)
   )  
)

(defparameter static-time-var (make-time))

;;;; sets slots of global variable static-time-var to the four arguments.
(defun sett (w x y z)
   (setf (time-b- static-time-var) w
         (time-b+ static-time-var) x
         (time-e- static-time-var) y
         (time-e+ static-time-var) z
   )  
)

;;;; returns a time which gives the op constraints by time i.
;;;   i itself is not modified.  Does not create a new time between
;;;   calls, so copy result if needed.
(defun time-pattern (op i)
  (let 
      (  (w (time-b- i))
	  (x (time-b+ i))
	  (y (time-e- i))
	  (z (time-e+ i))
	  )
    (case op
      ((beforeMeet) (sett :-inf x :-inf x))
      ((during) (sett w z w z))
      ((contains) (sett :-inf x y :+inf))
      ((afterMeet) (sett y :+inf y :+inf))
      ((equals) (sett w x y z))
      ((overlaps) (sett :-inf x w z))
      ((overlapped-by) (sett w z y :+inf))
      (otherwise (error "unknown temporal relation ~A" op))
      )
    )
  (return-from time-pattern static-time-var)
  )

;;;; invert a temporal operator
(defun time-invert (op)
   (case op
      ((beforeMeet) 'afterMeet)
      ((during) 'contains)
      ((equals) 'equals)
      ((overlaps) 'overlapped-by)
      ((overlapped-by) 'overlaps)
      ((contains) 'during)
      ((afterMeet) 'beforeMeet)
   )
)

;;;; determine if two time intervals must intersect
(defun times-intersect? (i j)
   (not
      (or
	 (and (<=? (time-e- i) (time-b+ j)) (not (eql (time-b- i) (time-b+ j))))
	 (and (<=? (time-e- j) (time-b+ i)) (not (eql (time-b- j) (time-b+ i))))
	 )
      )
   )


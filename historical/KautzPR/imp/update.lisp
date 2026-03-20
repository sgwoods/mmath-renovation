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

(defvar *hypoths* nil "hypothesis set, a disjunction of conjunctions of e-graphs")

(defvar *update-type* 'i "current default update type")

(defun update (obs)
  "call the currently selected update type"
  (case *update-type*
    ((i incremental) (incremental-update obs))
    ((n non-dichronic) (non-dichronic-update obs))
    ((s sticky) (sticky-update obs))
    (otherwise (error "bad *update-type*"))
    )
  )

(defun display-hypoths (&optional long)
  "display current minimum hypothesis set"
  (let ((hypoths (minimum-hypoths)) (n 0))
      (format t "~%********************************************************")
      (format t "~%|  There are ~D ways of grouping the observations" (length hypoths))
      (dolist (hypo (minimum-hypoths))
	 (setq n (+ n 1))
        (format t "~%********************************************************")
        (format t "~%~%|  Hypthosis set ~D is ~A" n hypo)
        (format t   "~%|  where")
        (dolist (graph hypo)
          (format t "~%~%======================================~%")
          (draw-graph long graph)
          )
        )
      )
    )

(defun init-hypoths ()
  "initialize hypothesis set"
  (setq *hypoths* (list nil)))

(defun minimum-hypoths ()
  "returns current set of minimum size hypotheses"
  (let (minsize)
    (setq minsize (apply #'min 999999999 (mapcar #'length *hypoths*)))
    (remove-if #'(lambda (h) (> (length h) minsize)) *hypoths*)
    ))

(defun incremental-update (etype-and-descr)
   "incrementally update hypothesis given this observation"
   (let (new-g current-g new-hypoths)
      (blab ">I-Update: current hypo is ~A" *hypoths*)
      (setq current-g (gentemp "EG"))
      (blab ">I-Update: using graph ~A" current-g)
      (if (null (explain-observation etype-and-descr current-g))
	 (return-from incremental-update (values nil "Observation not explained")))
      (blab ">I-Update: completed ~A" current-g)
      (setq new-hypoths nil)
      (dolist (hypo *hypoths*)
	 (dolist (old-g hypo)
	    (setq new-g (intern 
			   (concatenate 'string 
			      (string old-g)
			      "+" (string current-g))))
	    (blab ">I-Update: trying match ~A" new-g)
	    (if (match-graphs old-g current-g new-g)
	       (then
		  (blab ">I-Update: match succeeds!")
		  (push (cons new-g (remove old-g hypo)) new-hypoths))
	       (else
		  (blab ">I-Update: match fails")))
	    )
	 )
      (if (null new-hypoths)
	 (dolist (hypo *hypoths*)
	    (push (cons current-g hypo) new-hypoths)))
      (setq *hypoths* new-hypoths)
      (blab ">I-Update: new hypo is ~A" *hypoths*)
      ))

(defun sticky-update (etype-and-descr)
   "sticky incremental update of hypothesis"
   (let (current-g new-hypoths new-g hypo)
      (blab ">S-Update: current hypo is ~A" *hypoths*)
      (setq current-g (gentemp "EG"))
      (blab ">S-Update: using graph ~A" current-g)
      (if (null (explain-observation etype-and-descr current-g))
	 (return-from sticky-update (values nil "Observation not explained")))
      (blab ">S-Update: completed ~A" current-g)
      (setq hypo (car *hypoths*))
      (block update-loop
	 (dolist (old-g hypo)
	    (setq new-g (intern 
			   (concatenate 'string 
			      (string old-g)
			      "+" (string current-g))))
	    (blab ">S-Update: trying match ~A" new-g)
	    (if (match-graphs old-g current-g new-g)
	       (progn
		  (blab ">S-Update: match succeeds!")
		  (setq new-hypoths (list (cons new-g (remove old-g hypo))))
		  (return-from update-loop))
	       (else
		  (blab ">S-Update: match fails")))
	    )
	 (setq new-hypoths (list (cons current-g hypo)))
	 )
      (setq *hypoths* new-hypoths)
      (blab ">S-Update: new hypo is ~A" *hypoths*)
      ))

(defun non-dichronic-update (etype-and-descr)
   "most complete version of update algorithm"
   (let (current-g new-hypoths new-g)
      (blab ">N-Update: current hypo is ~A" *hypoths*)
      (setq current-g (gentemp "EG"))
      (blab ">N-Update: using graph ~A" current-g)
      (if (null (explain-observation etype-and-descr current-g))
	 (return-from non-dichronic-update (values nil "Observation not explained")))
      (blab ">N-Update: completed ~A" current-g)
      (setq new-hypoths nil)
      (dolist (hypo *hypoths*)
	 (push (cons current-g hypo) new-hypoths)
	 (dolist (old-g hypo)
	    (setq new-g (intern 
			   (concatenate 'string 
			      (string old-g)
			      "+" (string current-g))))
	    (blab ">N-Update: trying match ~A" new-g)
	    (if (match-graphs old-g current-g new-g)
	       (progn
		  (blab ">N-Update: match succeeds!")
		  (push (cons new-g (remove old-g hypo)) new-hypoths))
	       (else
		  (blab ">N-Update: match fails")))
	    )
	 )
      (setq *hypoths* new-hypoths)
      (blab ">N-Update: new hypo is ~A" *hypoths*)
      ))



  

;;; -*- Mode: LISP; Syntax: Common-lisp; Package: MVL; Base: 10 -*-

(in-package "MVL")

;; First-order theorem prover; tracing and diagnostic stuff.

;;  *watched-nodes* is a list of nodes that can be referred to by number
;;  *save-nodes* allows us to describe each node once, referring to by
;;    number afterwards, if T
;;  *watched-preds* is a list of elements (pred . num), where num is
;;    the number of parents to display if a node is about the given
;;    predicate.  We display that many, unless we run out first.
;;  *break-node* is the number of a node that, if displayed, should
;;    cause a break.  (This is a debugging hook.)

(defvar *watched-nodes*)
(defparameter *save-nodes* t)
(defparameter *watched-preds* nil)
(defparameter *break-node* nil)

;; to output a goal, type the associated expression (including negation
;; if relevant), the parent, and any information about whether it's
;; opaque.

(defun print-goal (goal stream print-depth)
  (declare (ignore print-depth))
  (format stream 
	  #+ANSI "~@<~1I~:[~;referentially opaque ~]goal ~a of clause~:_ ~a~:>"
	  #-ANSI "~:[~;referentially opaque ~]goal ~a of clause~<~%~:; ~a~>"
	  (goal-opaque goal)
	  (or (goal-term goal)
	      (plug (car (goal-clause goal)) (goal-binding goal)))
	  (goal-clause goal)))

;; here we display information about a node that is in the process of
;; being expanded or created.  We look at the list of watched
;; predicates; if (car literal) is on it, we indicate that the node is
;; being considered.  Recall that *watched-preds* is a list of (pred . num),
;; where num is the number of parents to display.  The <string> arg says what
;; we're actually doing to the node.

;; There are a couple of additional subtleties.  If save-node is T, then
;; we save this node as something that we can refer to by number.  (The
;; node and the next available number are pushed onto *watched-nodes*.)
;; If the node is one to which we are referring by number, and the
;; number is the same as *break-node*, we break.  We also stop
;; displaying the parents as soon as we get to one that we have
;; identified by number.

(defun bc-display-info (node string &optional save-node &aux 
			(show (assoc (car (goal-literal node))
				     *watched-preds*)))
  (when show
    (cond ((assoc node *watched-nodes*)
	   (format t "~%~a node ~a" string (cdr (assoc node *watched-nodes*))))
	  (t (when save-node
	       (if *watched-nodes*
		   (push (cons node (1+ (cdar *watched-nodes*)))
			 *watched-nodes*)
		 (setq *watched-nodes* (list (cons node 1)))))
	     (format t "~%~a ~:[~*~;node ~a, ~]~a"
		     string save-node (cdar *watched-nodes*) node)
	     (if (and save-node (eq (cdar *watched-nodes*) *break-node*))
	       (break "Breaking to examine node ~a" *break-node*))
	     (pop show)			;get the number of nodes to show
					;(finish the assoc, basically)
	     (do ()
		 ((or (zerop show) (null (setq node (goal-parent node)))))
	       (decf show)
	       (cond ((assoc node *watched-nodes*)
		      (format t "~%  ... parent is node ~a"
			      (cdr (assoc node *watched-nodes*)))
		      (return))
		     (t (format t "~%  ... parent is ~a" node))))))))

;; Here is where we watch new predicates.

(defmacro bc-watch (&rest preds)
  `(progn ,.(mapcar #'(lambda (pred) `(bc-watch-1 ',pred)) preds)
	  (watched-preds)))

;; watch a single new predicate.  The depth is either -1 (list all
;; parents) or the second element of the predicate itself.  Parse the
;; predicate, warn him if he's trying to display a non-numeric number,
;; and adjust *watched-preds*.

(defun bc-watch-1 (pred &aux depth)
  (if (listp pred) (setq depth (cadr pred) pred (car pred)) (setq depth -1))
  (cond ((numberp depth)
	 (push (cons pred depth) *watched-preds*))
	(t (cerror "Use the default argument (display all parents)."
		   "The argument to BC-WATCH, ~a, was not an integer." depth)
	   (bc-watch pred))))

;; Here is where we unwatch predicates.  If there aren't any, we unwatch
;; them all.

(defmacro bc-unwatch (&rest preds)
  (if preds `(progn ,@(mapcar #'(lambda (pred) `(bc-unwatch-1 ',pred)) preds)
		    ',preds)
      '(mapc #'bc-unwatch-1 (watched-preds))))

;; unwatch a single predicate by removing it from *watched-preds*

(defun bc-unwatch-1 (pred)
  (if (assoc pred *watched-preds*)
      (popf *watched-preds* pred :key #'car)
      (warn "The predicate ~a is not currently WATCHed." pred)))

(defun watched-preds ()
  (mapcar #'car *watched-preds*))

;; watched predicates are also reported when bc-lookup succeeds on them.

(defun bc-display-lookup (node ansl)
  (when (and ansl (assoc (car (goal-literal node)) *watched-preds*))
    (format t 
	    #+ANSI "~@<~%~1IFound ~a~:_ in the database for binding list(s):~
                       ~{~:_ ~a~}~:>"
	    #-ANSI "~%Found ~a in the database for binding list(s):~
                    ~{~<~%~:; ~a~>~}"
	    (goal-term node) (mapcar #'answer-binding ansl))))

;; Report that the first-order prover returned successfully

(defun prover-show-return (bdg conj pending)
  (cond ((cdr conj)
	 (let (nums)
	   (dotimes (i (length conj)) (push (1+ i) nums))
	   (setq nums (nreverse nums))
	   (format t "~%Returns binding ~a using assumptions:~
		      ~:{~%~2d. ~a~}"
		   bdg
		   (mapcar #'(lambda (x y) (list x (show-assumption y)))
			   nums conj))))
	(conj (format t "~%Returns binding ~a using assumption~<~%~:; ~a~>."
		      bdg (show-assumption (car conj))))
	(t (format t "~%Returns binding ~a." bdg)))
  (when pending (format t "~% ... it's irrelevant.")))

(defun show-assumption (x)
  (case (car x)
    (truth-value (format nil "truth value: ~a" (mvl-print (second x))))
    (modal (format nil "modality: ~a" (second x)))
    (t x)))

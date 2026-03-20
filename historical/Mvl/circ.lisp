;;; -*- Mode: LISP; Syntax: Common-lisp; Package: MVL; Base: 10 -*-

(in-package "MVL")

(defvar *first-order-bilattice*)
(defvar *first-order-atms-bilattice*)

;; the circumscription bilattice is constructed by splicing the
;; first-order ATMS bilattice into the first-order bilattice.  The only
;; subtlety is that the default is to stash a sentence as a default, so
;; we need to poke the first-order bilattice so that it tries to stash
;; things as unknown.

(defun make-circumscription-bilattice
    (&aux (b (copy-bilattice *first-order-bilattice*)))
  (setf (bilattice-stash-val b) (bilattice-unstash-val b))
						;stash is default only
  (setq b (splice-bilattice b *first-order-atms-bilattice*))
  (describe-bilattice b "Circumscription." "Circumscription" #\c)
  b)

(defparameter *circumscription-bilattice* (make-circumscription-bilattice))

(bilattice *circumscription-bilattice*)

;; circumscription stuff.  Given a proposition, first try to prove it.
;; Then see if it holds in *all* contexts.

;; global variables defined:
;; 
;; *circum-trace*	print out diagnostics on circumscriptive prover
;; 
;; functions defined:
;; 
;; circum (prop)	does prop follow from circumscription? 
;;			(returns single answer)
;; circums (prop)	does prop follow from circumscription?
;;			(returns all answers)

(defparameter *circum-trace* nil)
(defvar *success-test*)

(defun circum (prop &key (cutoffs std-cutoffs) (succeeds *success-test*))
  (general-circum prop cutoffs succeeds #'check-circumscriptive-context))

(defun general-circum (prop cutoffs succeeds checker)
  (dolist (item (gc-1 prop cutoffs succeeds))
    (if (check-context checker (answer-value item))
	(return (make-answer :binding (answer-binding item))))))

(defun gc-1 (prop cutoffs succeeds &aux ans)
  (if *circum-trace* (format t "~2%Invoking multivalued prover on~<~%~:; ~a~>."
			     prop))
  (setq ans (bcs prop :cutoffs cutoffs :succeeds succeeds))
  (if *circum-trace* (format t "~2%Values returned are:
   binding lists: ~a
   truth values:  ~a"
			 (mapcar #'answer-binding ans)
			 (mapcar #'(lambda (x) (mvl-print (answer-value x)))
				 ans)))
  ans)

(defun circums (prop &key (cutoffs std-cutoffs) (succeeds *never-succeeds*))
  (general-circums prop cutoffs succeeds #'check-circumscriptive-context))

(defun general-circums (prop cutoffs succeeds checker &aux answer)
  (dolist (item (gc-1 prop cutoffs succeeds) (nreverse answer))
    (if (check-context checker (answer-value item))
	(push (make-answer :binding (answer-binding item)) answer))))

;; the guts of the circumscriptive prover are here, where we take an
;; answer (i.e., a truth value that has been assigned to the query), and
;; check to see if it holds in all contexts.  If (car value) is T, it's
;; on the top level of the bilattice, so it's fine.  If not, we need to
;; compute the proposition corresponding to the truth value, and then
;; check its consistency.

(defun check-context (check-fn value)
  (if *circum-trace*
      (format 
       t "~2%Checking circumscriptive context for truth value~<~%~:; ~a~>."
       (mvl-print value)))
  (funcall check-fn value))

(defun check-circumscriptive-context (value)
  (or (car value) (circ-check-consistency (induced-prop value))))

;; a proposition is consistent just in case we can't prove its negation.

(defun circ-check-consistency (prop)
  (if *circum-trace* (format t "~%Checking consistency for~<~%~:; ~a~>." prop))
  (not (bc (negate prop))))

;; proposition corresponding to a truth value, assumed of the form
;; (NIL . (t-just . f-just)) where t-just and f-just are in the
;; first-order ATMS bilattice.  Only t-just matters.

(defun induced-prop (value)
  (induced-prop-1 (cadr value)))

;; if t-just has a cdr, return (OR PROP-1 ... PROP-N).  Otherwise,
;; return PROP-1.  The prop-i are constructed by associating a
;; proposition to each conjunctive context.

(defun induced-prop-1 (value)
  (cond ((cdr value) (cons 'or (mapcar #'induced-conj value)))
	(value (induced-conj (car value)))))

;; proposition associated to a conjunction.  If the conjunction is
;; empty, it's trivial.

(defun induced-conj (c)
  (cond ((cdr c) (cons 'and (mapcar #'induced-p c)))
	(c (induced-p (car c)))
	(t '(= t t))))

;; proposition associated to a single term.

(defun induced-p (a)
  (plug (denotes (car a)) (cdr a)))

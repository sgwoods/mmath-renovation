;;; -*- Mode: LISP; Syntax: Common-lisp; Package: MVL; Base: 10 -*-

(in-package "MVL")

#-ANSI (proclaim '(declaration dynamic-extent))

;; This file contains a variety of functions that manipulate binding
;; lists and "answers" - structures containing a binding list and a
;; truth value.

(defvar true)

(defstruct (answer (:print-function print-answer))
  (binding nil)
  (value true))

(defstruct ans binding value)

(defun print-answer (answer stream print-depth)
  (declare (ignore print-depth))
  (format stream "~a" (make-ans :binding (answer-binding answer)
				:value (mvl-print (answer-value answer)))))

;; a few random utilities.
;;   make-answer-from-binding (bdg) takes a bindings list and produces
;;    	an answer with truth value true
;;   invert-answer takes an answer and negates the truth value
;;   equal-answer checks two answers for equality

(defun make-answer-from-binding (bdg)
  (make-answer :binding bdg))

(defun invert-answer (answer)
  (make-answer :binding (answer-binding answer)
	       :value (mvl-not (answer-value answer))))

(defun equal-answer (a1 a2)
  (and (typep a1 'answer) (typep a2 'answer)
       (equal-binding (answer-binding a1) (answer-binding a2))
       (mvl-eq (answer-value a1) (answer-value a2))))

;; popf				same keywords as delete
;; plug (x bdg-list)		plug binding list into x
;; delete-bdg (x bdg-list)	remove binding for x in bdg-list
;; get-bdg (x bdg-list)		find binding for x in bdg-list

(define-modify-macro popf (item &rest keywords) pop-fn)
(defun pop-fn (list item &rest key) (apply #'delete item list key))

;; plug.  If the binding list is empty, then you can just return x.  If
;; the binding list is not empty, then walk down the expression x; if x
;; is a variable on the binding list, do the substitution.  If x is an
;; atom not on the binding list, then just return it.  If x is a cons,
;; keep walking.  But as you walk, you have to be careful to handle
;; sequence variables correctly.  So if the car of x is a simple
;; variable, then you replace it with its value and continue.  If
;; the car of x is a sequence variable, it's complicated.

;; If the sequence variable is being replaced with NIL, then record the
;; variable on the list of such sequence variables; at the end, delete
;; all of these variables from the expression.  We can't do it earlier
;; becuase this deletion may interact in odd ways with the loop over the
;; elements of x.

;; If the sequence variable is being replaced with a list l, then we
;; want to destructively splice l into x at this point, resuming the
;; looping after the insertion.  We do this by storing the portion of
;; the original list still to be searched in the variable temp1 and then
;; splicing l onto the front of the list.  Since this splice is
;; destructive, this achieves the primary goal of modifying the original
;; expression in a way that reflects the binding of the sequence
;; variable.  We then set "list" (the portion of the list still to be
;; examined) to be temp1, which results in our continuing to do the plug
;; only on the portion of the list that still might have a match.

;; Finally, if the car of the list is not a variable but is a list, we
;; do a plug on that list and splice the result into the car of the
;; given expression; in any event, we then move down the expression to
;; the next slot.

(defun plug (x bdg-list)
  (if bdg-list (plug1 (copy-tree x) bdg-list) x))

(defun plug1 (x bdg-list &aux temp)
  (cond ((and (varp x) (setq temp (assoc x bdg-list))) (cdr temp))
	((atom x) x)
	(t (do ((list x) null-seq-vars)
	       ((null list)
                (dolist (null-var null-seq-vars x)
                  (setq x (delete null-var x))))
	     (declare (dynamic-extent null-seq-vars))
	     (case (vartype (car list))
	       (? (if (setq temp (assoc (car list) bdg-list))
		      (rplaca list (cdr temp)))
		  (setq list (cdr list)))
	       (?* (if (setq temp (assoc (car list) bdg-list))
		       (if (cdr temp)
			   (let ((temp1 (cdr list)))
			     (rplaca list (cadr temp))
			     (rplacd list (append (cddr temp) temp1))
			     (setq list temp1))
			 (pushnew (pop list) null-seq-vars))
		     (setq list (cdr list))))
	       (t (if (listp (car list))
		      (rplaca list (plug1 (car list) bdg-list)))
		  (setq list (cdr list))))))))

;; The following functions delete the binding for a given variable or
;; variables from a binding list.

(defun delete-bdg (x bdg-list)
  (delete x bdg-list :key #'car :count 1))

(defun remove-bdg (x bdg-list)
  (remove x bdg-list :key #'car :count 1))

(defun delete-bdgs (vars bdg-list)
  (delete-if #'(lambda (x) (member x vars)) bdg-list :key #'car))

(defun remove-bdgs (vars bdg-list)
  (remove-if #'(lambda (x) (member x vars)) bdg-list :key #'car))

;; Given a binding list and a list of variables, delete the bindings
;; for variables not on the list (which were spawned by intermediate
;; goals, presumably).

(defun meaningful-bdgs (bdgs vars)
  (remove-if-not #'(lambda (x) (member x vars)) bdgs :key #'car))

;; Get the binding for a given variable from a binding list.  Note that
;; this piece of code (and others!) makes implicit use of the fact that
;; binding lists are never "nested", so that the binding list binding x
;; to y and then y to z will never appear in the system -- x will always
;; be bound to z directly.

(defun get-bdg (x bdg-list) (cdr (assoc x bdg-list)))


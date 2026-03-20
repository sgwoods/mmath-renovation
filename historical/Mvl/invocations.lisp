;;; -*- Mode: LISP; Syntax: Common-lisp; Package: MVL; Base: 10 -*-

(in-package "MVL")

;; This file contains all of the stuff needed to handle multiple copies
;; of MVL running in parallel.  There are basically two things that are needed:
;;  1.  A facility to handle the fact that property lists are global, so
;;  multiple invocations must somehow share them, and
;;  2.  A facility to handle the global variables of which each
;;  invocation needs a separate copy.

;; In order to deal with loading test-mvl, we have to make sure we
;; can load the invocation structure.  Here's a generic way to do this:

#+ANSI
(defmethod make-load-form ((x clos::structure-object))
  (make-load-form-saving-slots x))

;; The value of the current invocation is stored in the global parameter
;; *mvl-invocation*.

(defvar *mvl-invocation* nil)
(defvar *active-bilattice*)
(defconstant *mvl-alist* '(nil))

;; A version of get that is invocation-specific.  The way it works is
;; that if (car (get symbol indicator)) begins with *mvl-alist* then the
;; cdr of (get symbol indicator) should be an a-list and the value used
;; is the value associated to the current *mvl-invocation*, or if there
;; isn't one, the value associated to t.  This function also accepts a
;; default value that is returned if nothing more specific can be found.

(defun get-mvl (symbol indicator &optional default 
		&aux (temp (get symbol indicator)))
  (if (extended-alist temp)
      (if (setq temp (or (assoc *mvl-invocation* (cdr temp))
			 (assoc t (cdr temp))))
	  (cdr temp)
	default)
    (or temp default)))

(defun extended-alist (alist)
  (and (consp alist) (eq (car alist) *mvl-alist*)))

;; setf method associated to the above.  Get the appropriate property,
;; and then:
;;  1.  If its car is *mvl-alist*, treat it as an a-list and either
;;  adjust the appropriate dotted pair or push on a new one.
;;  2.  If not, set it to the given value.
;;  3.  If it doesn't exist, set it up as an a-list.

(defsetf get-mvl (symbol indicator) (new-value)
  `(progn (let ((temp (get ,symbol ,indicator)))
	    (cond ((extended-alist temp)
		   (let ((x (assoc *mvl-invocation* (cdr temp))))
		     (if x (setf (cdr x) ,new-value)
			 (push (cons *mvl-invocation* ,new-value)
			       (cdr temp)))))
		  (temp (setf (get ,symbol ,indicator) ,new-value))
		  (t (setf (get ,symbol ,indicator)
			   (cons *mvl-alist* (list (cons *mvl-invocation*
							 ,new-value)))))))
	  ,new-value))

;; remove the indicator for a given symbol.  As usual, see if it's a
;; cons or not and then do the appropriate thing.

(defun rem-mvl (symbol indicator &aux (temp (get symbol indicator)))
  (cond ((extended-alist temp)
	 (popf (cdr temp) *mvl-invocation* :key #'car :count 1)
	 (unless (cdr temp) (remprop symbol indicator)))
	(t (remprop symbol indicator))))

;; a list of all of the global parameters that are invocation specific
;; is maintained in *invocation-fields*.  Each entry is either a symbol,
;; or a list consisting of the symbol and its initial value.

(defparameter *invocation-fields*
    '(*completed-database*		;bc-interface.lisp
      (rootnode (make-dnode))		;index.lisp
      *initial-limit*			;first-order prover
      *limit-delta*
      *final-limit*
      (*node-evaluation-fn* 'best-first-fn)
					;printout stuff
      *bc-trace* *anytime-trace*	;output diagnostics on bc?
      *fc-trace*			;on fc?
      *circum-trace*			;when circumscribing?
      (*show-truth-values* t)		;include truth values in
					;diagnostics?
      *watched-preds*			;display stuff for first-order
      *watched-nodes*
      (*save-nodes* t)
      *break-node*
					;theory mechanism stuff
      *active-theory*			;active theory (if theory mech active)
      true-in-theory			;truth value of a sentence
					;that is true in *active-theory*
					;bilattice-dependent stuff, set up by
					;load-logic
      true false unknown bottom *success-test* *knowledge-test*
      monotonic-cutoff std-cutoffs *active-bilattice* *modal-ops*
      bdg-to-truth-val
      (*if-translation* 'bc)
      (*equivalence-translation* 'bc)))

;; a list of the variables in *invocation-fields*, independent of their values

(defun raw-invocation-fields ()
  (mapcar #'(lambda (x) (if (listp x) (car x) x)) *invocation-fields*))

;; an invocation is in fact an array.  The first entry is the invocation name
;; (i.e., the value of *mvl-invocation*; the remaining entries are the
;; values of the various global variables.  To make a new invocation,
;; make a new invocation name (MVL-nnnn) and then fill in all the other
;; slots with either NIL or the given values.

(defun make-mvl-invocation ()
  (make-array (1+ (length *invocation-fields*))
	      :initial-contents
	      (cons (gentemp "MVL-")
		    (mapcar #'(lambda (x) (if (listp x) (eval (cadr x))))
			    *invocation-fields*))))

;; create-mvl-invocation sets up a new invocation of MVL, accepting an
;; optional argument that is an invocation itself.  The value returned
;; is the existing invocation, so you can get it back (with
;; create-mvl-invocation) if you want.  First set *mvl-invocation* to
;; the supplied value, and then work through the raw-invocation-fields,
;; setting each to the supplied value.  End by loading the first-order
;; bilattice, unless some other bilattice has been loaded as part of the
;; invocation.

(defvar *first-order-bilattice*)

(defun create-mvl-invocation (&optional (invocation (make-mvl-invocation))
			      &aux (old (existing-mvl-invocation)))
  (setf *mvl-invocation* (aref invocation 0))
  (do ((i 1 (1+ i)) (syms (raw-invocation-fields) (cdr syms)))
      ((null syms))
    (set (car syms) (aref invocation i)))
  (unless *active-bilattice* (load-logic *first-order-bilattice*))
  old)

;; construct the current MVL invocation.  Basically, just apply eval to
;; the raw-invocation-fields.

(defun existing-mvl-invocation ()
  (make-array (1+ (length *invocation-fields*))
	      :initial-contents
	      (cons *mvl-invocation*
		    (mapcar #'(lambda (x) (if (boundp x) (eval x)))
			    (raw-invocation-fields)))))

;; with-mvl-invocation is like with-open-file.  It accepts an optional
;; argument that is the invocation to be used (making up a new one if
;; nothing is supplied), and a body of forms to be evaluated.  The
;; symbols in raw-invocation-fields are locally bound to the given
;; values, the body is evaluated and the result is returned.

(defmacro with-mvl-invocation
    ((&optional (invocation (make-mvl-invocation))) &body body)
  `(progv (cons '*mvl-invocation* (raw-invocation-fields))
	  (invocation-values ,invocation)
     (unless *active-bilattice* (load-logic *first-order-bilattice*))
     ,.body))

;; the values in an MVL invocation are simply the values of the various
;; elements of the associated array.

(defun invocation-values (invocation)
  (do ((i (length *invocation-fields*) (1- i)) ans)
      ((minusp i) ans)
    (push (aref invocation i) ans)))

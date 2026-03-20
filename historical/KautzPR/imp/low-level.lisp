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



;;;; Structured Programming

(defparameter *noisy* nil)
(defun blab (msg &rest args)
  (if *noisy* (format t "~% ... ~?" msg args))
  )

(defconstant okay t)
(defconstant fail nil)
(defconstant false nil)
(defmacro then (&rest body) `(progn ,@body))
(defmacro else (&rest body) `(progn ,@body))

(defmacro or-in (var value) `(setq ,var (or ,value ,var)))

(defmacro msetq (&rest body) `(multiple-value-setq ,@body))

;;;; Declarations of structures

(defstruct (eq-constr (:type list)) left right)

;;;; fact-constr 
;;;       Each fact constraint is of the form
;;;          (predicate arg1 arg2 ...)
;;;       where each argument is either:
;;;            an immediate value, of the form (* value)
;;;            a node-relative rolechain

;(defstruct (use-descr (:type list)) role kind spec-flag abstr-flag)
(defstruct (use-descr (:type list)) role kind)

(defstruct (roleval-descr (:type list)) role value)

;;; event-descr is a list of the form
;;;    (node kind (role1 val1) (role2 val2) ...)

(setq *print-array* t)

(defstruct (time (:type vector)) (name 'time)
  (b- :-inf) (b+ :+inf) 
  (e- :-inf) (e+ :+inf))

(defun time-p (x)
  (and (vectorp x)
      (eq (aref x 0) 'time))
  )

(defstruct (time-constr (:type list)) left op right)

;;;; Routines for comparing numbers extended by :+inf and :-inf

(defun <=? (x y)
   (or (eql x y) (eql x :-inf) (eql y :+inf)
       (and (numberp x) (numberp y) (<= x y)))
)

(defun <? (x y)
   (and (not (eql x y)) (<=? x y))
)

(defun minimum (x y)
   (if (<? x y) x y)
)

(defun maximum (x y)
  (if (<? x y) y x)
)

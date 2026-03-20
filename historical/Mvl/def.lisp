;;; -*- Mode: LISP; Syntax: Common-lisp; Package: MVL; Base: 10 -*-

(in-package "MVL")

;; default bilattice described via surgery.  (Implementation via matrices
;; is somewhat faster but less clear)

(defvar *first-order-bilattice*)

(defparameter *default-bilattice*
    (splice-bilattice *first-order-bilattice* *first-order-bilattice*))

(describe-bilattice *default-bilattice* "Default logic." "Default" #\d)

(bilattice *default-bilattice*)

;; special denotations for elements of the default bilattice -- star, dt
;; and df.

(defparameter star (cons nil 'bottom) "*")
(defparameter dt (cons nil 'true) "dt")
(defparameter df (cons nil 'false) "df")

;; hierarchical bilattice is hierarcical version of default bilattice

(defparameter *hierarchy-bilattice* 
    (hierarchy-bilattice *first-order-bilattice*))

(describe-bilattice *hierarchy-bilattice* "Hierarchical default logic."
		    "Hierarchical default" #\h)

(bilattice *hierarchy-bilattice*)

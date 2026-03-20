;;; -*- Mode: Lisp; Syntax: Common-lisp; Package: MVL; Base: 10 -*-

;; Load the first-order bilattice.  At this point in the loading of MVL,
;; all of the basic bilattices have been defined and we need to get
;; *some* bilattice loaded in order to complete loading the system.

(in-package "MVL")

(load-logic #\f)

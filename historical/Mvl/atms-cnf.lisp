;;; -*- Mode: LISP; Syntax: Common-lisp; Package: MVL; Base: 10 -*-

(in-package "MVL")

;; constructs ATMS lattice using conjunctive normal form, so that a
;; justification is a conjunctive set of disjunctive "contexts".  The
;; minimal justification (unknown) is (nil), where the only disjunctive
;; context is empty.  The maximal justification is nil.

(defparameter cmax-j nil "maximal justification")
(defparameter cmin-j '(nil) "minimal justification")

;; The combination function are the same as for the ATMS bilattice, but
;; "backwards" because the form of the value has been inverted.

(defun cj-and (j k)
  (if (or (eq j cmin-j) (eq k cmin-j))
      cmin-j
    (djl-simplify (append j (copy-list k)))))

(defun cj-or (j k)
  (djl-simplify 
   (mapcan #'(lambda (x) (mapcar #'(lambda (y) (union x y)) j)) k)))

;; dot with star -- remove contexts that are *supersets* (is this
;; right??)

(defun cj-dws (j1 j2)
  (remove-if #'(lambda (x) (some #'(lambda (y) (subsetp x y)) j2)) j1))

;; the simplicity is given just as the length of the overall conjunction
;; corresponding to a particular truth value

(defun cj-simp (j)
  (list (length j)))

;; construct the lattice.  The default stashing function is the same as
;; for the conventional ATMS lattice.  We can also use the same equality
;; test as for the conventional lattice, since the form of the sentences
;; is irrelevant in that case.

(defparameter *cnf-atms-lattice*
	      (make-lattice :max cmax-j
			    :min cmin-j
			    :stash-val #'d-stash
			    :and #'cj-and
			    :or #'cj-or
			    :eq #'dj-eq
			    :dws #'cj-dws
			    :simplicity #'cj-simp
			    :long-desc "ATMS using justifications in CNF."
			    :short-desc "ATMS/CNF"
			    :char #\b))

(defparameter *cnf-atms-bilattice* (lattice-to-bilattice *cnf-atms-lattice*))

(bilattice *cnf-atms-bilattice*)

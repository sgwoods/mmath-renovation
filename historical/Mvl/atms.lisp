;;; -*- Mode: LISP; Syntax: Common-lisp; Package: MVL; Base: 10 -*-

(in-package "MVL")

;; constructs ATMS bilattice using disjunctive normal form

;; the bilattice is constructed from the ATMS *lattice* of
;; justifications; each justification is a list of contexts (each of
;; which is a conjunctive list of assumptions)

;; the maximal justification is true without any assumptions; the
;; minimal justification is never true.

(defparameter dmax-j '(()) "maximal justification")
(defparameter dmin-j nil "minimal justification")

;; lub is easy -- just append the two big disjunctions, and then call
;; djl-simplify to remove any contexts that are supersets of others.
;; There is a check to see if either disjunction is the empty context,
;; in which case we can simply return that.  For glb, we have to conjoin
;; the contexts individually, so we form the list of all contexts that
;; are obtained by conjoining a context in j1 with one in j2.  Then we
;; delete subsumed contexts as before.

(defun dj-or (j1 j2)
  (if (or (eq j1 dmax-j) (eq j2 dmax-j))
      dmax-j
    (djl-simplify (append j1 (copy-list j2)))))

(defun dj-and (j1 j2)
  (djl-simplify
   (mapcan #'(lambda (x) (mapcar #'(lambda (y) (union x y)) j1)) j2)))

;; delete subsumed contexts.  We just walk through the contexts; any
;; that is a superset of some other element is deleted.

(defun djl-simplify (l)
  (delete-subsumed-entries l #'(lambda (x y) (subsetp y x))))

;; remove subsumed entries from a list.  The story is that for x on the
;; list, if there is some y on the list such that (test y x), remove x
;; from the list.  Ans is the accumulated answer and list is what you
;; still have to look at.  So pop the top element off of list and
;;  1.  If some element of ans subsumes it, go on to the next.
;;  2.  Otherwise, remove subsumed elements of ans and push the new item
;;  on.
;; Popcell and pushcell are used to reuse the cons cells in the given
;; list.

(defun delete-subsumed-entries (list test)
  (if (cdr list)
      (do (ans item) ((null list) ans)
	(setq item (popcell list))
	(unless (some #'(lambda (x) (funcall test (car item) x)) ans)
	  (setq ans (delete-if #'(lambda (x) (funcall test x (car item))) ans))
	  (pushcell item ans)))
    list))

;; comparing two values -- the length has to be the same and every term
;; in one has to match a term in another.

(defun dj-eq (j1 j2)
  (or (eq j1 j2)
      (and (= (length j1) (length j2))
	   (subsetp j1 j2 :test #'dj-same))))

;; two contexts match if they are the same sets.

(defun dj-same (x y)
  (and (= (length x) (length y))
       (subsetp x y)))

;; j1 is less than j2 if every context in j1 is a superset of some
;; context in j2.

(defun dj-le (j1 j2)
  (or (eq j1 j2)
      (every #'(lambda (c1) (some #'(lambda (c2) (subsetp c2 c1)) j2)) j1)))

;; dot with star -- take every context in j1, and if it is a subset of
;; some context in j2, remove it.

(defun dj-dws (j1 j2)
  (remove-if #'(lambda (x) (some #'(lambda (y) (subsetp y x)) j2)) j1))

;; the simplicity of a lattice element is just the minimum length of a
;; context or, if there is no context, a big integer.

(defun dj-simp (j)
  (list (if j (apply #'min (mapcar #'length j)) most-positive-fixnum)))

;; to stash something, call index-with-negation to insert it into the
;; discrimination net, and then construct a context consisting of that
;; and nothing else.

(defun d-stash (p) `((,(index-with-negation p))))

(defparameter *atms-lattice*
	      (make-lattice :max dmax-j
			    :min dmin-j
			    :stash-val #'d-stash
			    :and #'dj-and
			    :or #'dj-or
			    :eq #'dj-eq
			    :leq #'dj-le
			    :dws #'dj-dws
			    :simplicity #'dj-simp
			    :long-desc "ATMS."
			    :short-desc "ATMS"
			    :char #\a))

;; the ATMS bilattice is constructed in the obvious fashion.

(defparameter *atms-bilattice* (lattice-to-bilattice *atms-lattice*))

;; this adds the bilattice to the list of bilattices about which the
;; system knows

(bilattice *atms-bilattice*)

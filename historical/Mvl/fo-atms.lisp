;;; -*- Mode: LISP; Syntax: Common-lisp; Package: MVL; Base: 10 -*-

(in-package "MVL")

;; constructs bilattice for first-order ATMS in disjunctive normal form

;; the bilattice is constructed from a lattice as usual; the trick is
;; that the members of a particular context are not just sentences, but
;; dotted pairs (p . b) where p is a proposition number and b is a
;; binding list.

;; maximal and minimal elements are just like ATMS.

(defvar dmin-j)
(defvar dmax-j)

;; one context is contained in another if every sentence in it is
;; subsumed by a sentence in the other.  We want (p . ((?a . fred)))
;; to be contained in (p . nil) but not the other way around, since the
;; second one contains more elements of the assumption "schema"
;; corresponding to p.

(defun contained (x y) (subsetp x y :test #'just-subsumed))

;; recall from the above that (p . ((?a . fred))) is supposed to be
;; just-subsumed by (p . nil), so that one sentence is subsumed by
;; another if they are the same proposition and the first bindings are
;; le the second

(defun just-subsumed (a b)
  (and (eq (car a) (car b)) (binding-le (cdr a) (cdr b))))

;; glb and lub are just like ATMS lattice, except instead of just
;; deleting duplicates, we have to remove *any* subsumed elements.

(defun j-or (j1 j2)
  (if (or (eq j1 dmax-j) (eq j2 dmax-j))
      dmax-j
    (jl-simplify (append j1 (copy-list j2)))))

(defun j-and (j1 j2)
  (jl-simplify (mapcan #'(lambda (x)
			   (mapcar #'(lambda (y) (j-simplify
						  (append x (copy-list y))))
				   j1)) j2)))

(defun j-simplify (l)
  (delete-subsumed-entries l #'just-subsumed))

(defun jl-simplify (l)
  (delete-subsumed-entries l #'(lambda (x y) (contained y x))))

;; special function for comparing two values -- same as ATMS, but
;; elements aren't just equal; they have to be the same proposition and
;; binding lists.

(defun j-eq (j1 j2)
  (or (eq j1 j2)
      (and (= (length j1) (length j2))
	   (subsetp j1 j2 :test #'j-same))))

(defun j-same (x y)
  (and (= (length x) (length y))
       (subsetp x y :test #'just-eq)))

(defun just-eq (x y)
  (and (eq (car x) (car y)) (equal-binding (cdr x) (cdr y))))

(defun j-le (j1 j2)
  (or (eq j1 j2)
      (every #'(lambda (c1) (some #'(lambda (c2) (contained c2 c1)) j2)) j1)))

;; dot with star is just like ATMS

(defun j-dws (j1 j2)
  (remove-if #'(lambda (x) (some #'(lambda (y) (contained y x)) j2)) j1))

;; stash uses empty binding list

(defun j-stash (p) `(((,(index-with-negation p) . nil))))

;; plugging is a little harder.  We could just do it with sublis, except
;; for * variables and such.  So we have to ground out in plug, eventually.
;; If the binding list is empty, we can just return the value.  Otherwise,
;; we have to plug into each context using jp-1 and simplify ...

(defun j-plug (value bdgs)
  (jl-simplify (mapcar #'(lambda (x) (jp-1 x bdgs)) value)))

;; ... to plug into a context, we plug into each term and simplify ...

(defun jp-1 (context bdgs)
  (j-simplify (mapcar #'(lambda (x) (jp-2 x bdgs)) context)))

;; ... to plug into a term (p . bdg), we have to get the new binding
;; list, which is obtained by combining the two binding lists and then
;; taking the meaninful bindings from what you get.

(defun jp-2 (term bdgs)
  (cons (car term)
	(meaningful-bdgs (append-binding-lists (cdr term) bdgs)
			 (get (car term) 'vars-in))))

(defparameter *first-order-atms-lattice*
	      (make-lattice :max dmax-j
			    :min dmin-j
			    :stash-val #'j-stash
			    :and #'j-and
			    :or #'j-or
			    :eq #'j-eq
			    :leq #'j-le
			    :dws #'j-dws
			    :simplicity #'dj-simp
			    :vars #'vars-in
			    :plug #'j-plug
			    :long-desc "First-order ATMS."
			    :short-desc "First-order ATMS"
			    :char #\o))

(defparameter *first-order-atms-bilattice* 
    (lattice-to-bilattice *first-order-atms-lattice*))

(bilattice *first-order-atms-bilattice*)

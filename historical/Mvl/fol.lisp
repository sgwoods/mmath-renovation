;;; -*- Mode: LISP; Syntax: Common-lisp; Package: MVL; Base: 10 -*-

(in-package "MVL")

;; constructs bilattice for first-order logic.  Distinguished elements
;; are defined as atoms

(defparameter f-true 'true "t in bilattice")
(defparameter f-false 'false "f in bilattice")
(defparameter f-unknown 'unknown "u in bilattice")
(defparameter f-bottom 'bottom "contradiction in bilattice")

;; The bilattice operations are given as tables, where X=0, f=1, t=2 and
;; u=3 (X is contradictory).  Experimentation shows that this
;; implementation is about as fast as (and a lot clearer than!) a
;; conditional one.  Ditto for implementing it from the two-point
;; lattice (because the output is hard to read).

(defmacro make-index (pt num)
  `(setf (get ,pt 'index) ',num))

(make-index f-bottom 0)
(make-index f-false 1)
(make-index f-true 2)
(make-index f-unknown 3)

(defparameter fol-name
	      (make-array 4 :initial-contents
			  `(,f-bottom ,f-false ,f-true ,f-unknown)))

(defparameter fol-plus
	      (make-array '(4 4) :initial-contents '((0 0 0 0)
						     (0 1 0 1)
						     (0 0 2 2)
						     (0 1 2 3))))

(defparameter fol-dot
	      (make-array '(4 4) :initial-contents '((0 1 2 3)
						     (1 1 3 3)
						     (2 3 2 3)
						     (3 3 3 3))))

(defparameter fol-and
	      (make-array '(4 4) :initial-contents '((0 1 0 1)
						     (1 1 1 1)
						     (0 1 2 3)
						     (1 1 3 3))))

(defparameter fol-or
	      (make-array '(4 4) :initial-contents '((0 0 2 2)
						     (0 1 2 3)
						     (2 2 2 2)
						     (2 3 2 3))))

(defparameter fol-not
	      (make-array 4 :initial-contents '(0 2 1 3)))

(defparameter fol-simplicity
	      (make-array 4 :initial-contents '(0 1 0 1)))

;; plus, for example, looks up the index numbers of the arguments, looks
;; up the answer in the array "fol-plus" and then gets the actual answer
;; in fol-name, which inverts the indexing function.  The other
;; functions are similar.

(defmacro fol-fn (fn)
  `(defun ,fn (x y)
     (aref fol-name (aref ,fn (get x 'index) (get y 'index)))))

(fol-fn fol-plus)
(fol-fn fol-dot)
(fol-fn fol-and)
(fol-fn fol-or)

(defun fol-not (x)
  (aref fol-name (aref fol-not (get x 'index))))

;; simplicity returns (0) for true or bottom; (1) for false or unknown

(defun fol-simplicity (x)
  (list (aref fol-simplicity (get x 'index))))

(defun fol-eq (x y) (eq x y))

;; dot-with-star.  If y is unknown or false, removing the contribution
;; corresponding to y does nothing.  Otherwise, removing it wipes out x.

(defun fol-dws (x y)
  (if (or (fol-eq y f-unknown) (fol-eq y f-false)) x f-unknown))

;; default stash is true; unstash is unknown

(defun f-stash (p) (declare (ignore p)) f-true)
(defun f-unstash (p) (declare (ignore p)) f-unknown)

;; Two other modal ops are L and M (the dual of L).

(defun L-fol (x)
  (if (member x (list f-true f-bottom)) f-true f-false))

(defparameter L-fol (make-modal-operator :name 'L :function #'L-fol))

(defun M-fol (x)
  (if (member x (list f-unknown f-true)) f-true f-false))

(defparameter M-fol (make-modal-operator :name 'M :function #'M-fol))

(defparameter *first-order-bilattice*
    (make-standard-modal-ops
     (make-bilattice :true f-true
		     :false f-false
		     :unknown f-unknown
		     :bottom f-bottom
		     :cutoff-val f-unknown
		     :stash-val #'f-stash
		     :unstash-val #'f-unstash
		     :plus #'fol-plus
		     :dot #'fol-dot
		     :and #'fol-and
		     :or #'fol-or
		     :not #'fol-not
		     :eq #'fol-eq
		     :dws #'fol-dws
		     :simplicity #'fol-simplicity
		     :long-desc "First-order logic."
		     :short-desc "First-order"
		     :char #\f)))

(bilattice-has-modal-operator *first-order-bilattice* L-fol)
(bilattice-has-modal-operator *first-order-bilattice* M-fol)

;; this adds the bilattice to the list of bilattices about which the
;; system knows

(bilattice *first-order-bilattice*)

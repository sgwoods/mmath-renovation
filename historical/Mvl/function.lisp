;;; -*- Mode: LISP; Syntax: Common-lisp; Package: MVL; Base: 10 -*-

(in-package "MVL")

;; functions to produce bilattice from a bilattice and a function.  The
;; way it works is that we just reinvoke the function at every chance;
;; bilattice elements are of the form (x . f(x)) for elements x of the
;; original bilattice and a fixed function f.

;; 1.  Fixed bilattice elements are obtained by applying the function to
;; the old values.

;; 2.  Functional slots are constructed as for the product bilattices,
;; with functions a-fn-??, etc.

;; 3.  The modal operators are computed by a-modal-ops.

;; 4.  The long and short descriptions include the original bilattice
;; and function; the one-character identifier used is the first one
;; available.

;; 5.  The type is "append" and the components are the original
;; bilattice and the supplied function.

(defun append-bilattice (b f)
  (make-standard-modal-ops
    (make-bilattice :true (append-elt #'bilattice-true b f)
		    :false (append-elt #'bilattice-false b f)
		    :unknown (append-elt #'bilattice-unknown b f)
		    :bottom (append-elt #'bilattice-bottom b f)
		    :cutoff-val (append-elt #'bilattice-cutoff-val b f)
		    :stash-val (take-1-more-arg #'a-fn-f #'stash-value b f)
		    :unstash-val (take-1-more-arg #'a-fn-f #'unstash-value b f)
		    :plus (take-2-more-args #'a-fn-vv #'mvl-plus b f)
		    :dot (take-2-more-args #'a-fn-vv #'mvl-dot b f)
		    :and (take-2-more-args #'a-fn-vv #'mvl-and b f)
		    :or (take-2-more-args #'a-fn-vv #'mvl-or b f)
		    :not (take-1-more-arg #'a-fn-v #'mvl-not b f)
		    :eq (take-2-more-args #'a-fn-and-vv #'mvl-eq b)
		    :kle (take-2-more-args #'a-fn-and-vv #'k-le b)
		    :tle (take-2-more-args #'a-fn-and-vv #'t-le b)
		    :dws (take-2-more-args #'a-fn-vv #'dot-with-star b f)
		    :simplicity (append-simp b)
		    :vars (append-vars b)
		    :plug (append-plug b f)
		    :absorb (append-absorb b f)
		    :modal-ops (a-modal-ops b f)
		    :print-fn #'a-print
		    :long-desc
		    (format nil "Bilattice ~a appended with function ~a."
			    (dot-trim (bilattice-long-desc b)) f)
		    :short-desc
		    (format nil "[~a:~a]" (bilattice-short-desc b) f)
		    :char (bilattice-find-char #\a)
		    :type 'append :components (list b f))))

(defun append-elt (fn b f)
  (move-to-append (funcall fn b) f))

(defun move-to-append (x f)
  (cons x (funcall f x)))

(defun append-simp (b)
  (when (bilattice-simplicity b)
    (take-1-more-arg #'a-fn-simp b)))

(defun append-vars (b)
  (when (bilattice-vars b)
    (take-1-more-arg #'a-fn-vars b)))

(defun append-plug (b f)
  (when (bilattice-plug b)
    (take-2-more-args #'a-fn-vf #'mvl-plug b f)))

(defun append-absorb (b f)
  (when (bilattice-absorb b)
    (take-3-more-args #'a-fn-vfv #'mvl-absorb b f)))

;; The following are much like the versions in product.lisp

(defun a-fn-f (x fn b f)
  (move-to-append (funcall fn x b) f))

(defun a-fn-v (x fn b f)
  (move-to-append (funcall fn (car x) b) f))

;; Here is a typical one -- x is a bilattice element, so we take its car
;; before acting on it, and y is some fixed value that we just use as
;; is.

(defun a-fn-vf (x y fn b f)
  (move-to-append (funcall fn (car x) y b) f))

(defun a-fn-vv (x y fn b f)
  (move-to-append (funcall fn (car x) (car y) b) f))

(defun a-fn-and-vv (x y fn b)
  (funcall fn (car x) (car y) b))

(defun a-fn-vfv (x y z fn b f)
  (move-to-append (funcall fn (car x) y (car z) b) f))

;; The simplicity function on the compound bilattice is just given by
;; the simplicity function on the original bilattice.

(defun a-fn-simp (x b) (mvl-simplicity (car x) b))

;; The vars in a compound truth value are just those in the nonfunctional
;; part.

(defun a-fn-vars (x b) (mvl-vars (car x) b))

;; The modal operators are the same as the modal operators on the
;; original bilattice.

(defun a-modal-ops (b f)
  (mapcar #'(lambda (x)
	      (make-modal-operator
		:name (modal-operator-name x)
		:function (take-n-more-args #'a-modal-fn x f)
		:parameters (modal-operator-parameters x)))
	  (nonstandard-modal-ops b)))

(defun a-modal-fn (args op f)
  (move-to-append (operate-modally args op #'car) f))

(defun a-print (x b stream)
  (format stream #-ANSI "[~a : ~a]" #+ANSI "~@<[~;~a : ~_~a~;]~:>"
	  (mvl-print (car x) (first (bilattice-components b)))
	  (cdr x)))
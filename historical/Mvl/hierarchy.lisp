;;; -*- Mode: LISP; Syntax: Common-lisp; Package: MVL; Base: 10 -*-

(in-package "MVL")

;; functions to produce bilattice by hierarchical surgery
;;  New truth values are (n . val) where 0 is the top level of the
;;  hierarchy, or NIL for unknown.

;; 1.  Fixed bilattice elements are generally the values on the upper
;; bilattice (0 . old-value), or unknown.

;; 2.  Functional slots are constructed as for the product bilattices,
;; with functions h-fn-??, etc.

;; 3.  The modal operators are computed by h-modal-ops.

;; 4.  The long and short descriptions describe the bilattice as a
;; hierarchy; the one-character identifier used is "h" or the first one
;; available.

;; 5.  The type is "hierarchy" and the single component is the bilattice
;; supplied.

;; hierarchy-bilattice also accepts a keyword argument default-level,
;; which is the level at which new sentences should be stashed.  If
;; default-level is not supplied, it defaults to 0 (the top level).
;; This is implemented by passing default-level as an additional
;; argument to h-fn-f, and to functions that compute the default cutoff
;; and termination criteria for the prover as well.

(defun hierarchy-bilattice (b &key (default-level 0))
  (make-standard-modal-ops
    (make-bilattice :true (cons 0 (bilattice-true b))
		    :false (cons 0 (bilattice-false b))
		    :unknown nil
		    :bottom (cons 0 (bilattice-bottom b))
		    :cutoff-val (hierarchy-val
				 #'bilattice-cutoff-val b default-level)
		    :stash-val (take-1-more-arg
				#'h-fn-f #'stash-value b default-level)
		    :unstash-val (take-1-more-arg
				  #'h-fn-f #'unstash-value b nil)
		    :plus (take-2-more-args
			   #'h-fn-vv #'mvl-plus #'bilattice-unknown b)
		    :dot (take-2-more-args
			  #'h-fn-vv #'mvl-dot #'bilattice-bottom b)
		    :and (take-2-more-args
			  #'h-fn-vv #'mvl-and #'bilattice-true b)
		    :or (take-2-more-args
			 #'h-fn-vv #'mvl-or #'bilattice-false b)
		    :not (take-1-more-arg #'h-fn-v #'mvl-not b)
		    :eq (take-2-more-args #'h-fn-eq-vv b)
		    :kle (take-2-more-args #'h-fn-kle-vv b)
		    :tle (take-2-more-args #'h-fn-tle-vv b)
		    :dws (take-2-more-args
			  #'h-fn-vv #'dot-with-star #'bilattice-bottom b)
		    :simplicity (take-1-more-arg #'h-fn-simp b)
		    :vars (hierarchy-vars b)
		    :plug (hierarchy-plug b)
		    :absorb (hierarchy-absorb b)
		    :modal-ops (h-modal-ops b)
		    :print-fn #'h-print
		    :long-desc (format nil "Hierarchy of ~a."
				       (dot-trim (bilattice-long-desc b)))
		    :short-desc (format nil "~a hierarchy"
					(bilattice-short-desc b))
		    :char (bilattice-find-char #\h)
		    :type 'hierarchy :components (list b))))

(defun hierarchy-vars (b)
  (when (bilattice-vars b)
    (take-1-more-arg #'h-fn-vars b)))

(defun hierarchy-plug (b)
  (when (bilattice-plug b)
    (take-2-more-args #'h-fn-vf #'mvl-plug b)))

(defun hierarchy-absorb (b)
  (when (bilattice-absorb b)
    (take-3-more-args #'h-fn-vfv #'mvl-absorb b)))

;; compute a hierarchical version of a bilattice element obtained by
;; applying the function fn to the bilattice b.  If the result is
;; unknown, just return NIL; otherwise return (level . result).

(defun hierarchy-val (fn b level)
  (hierarchy-check-unknown (funcall fn b) b level))

(defun hierarchy-check-unknown (v b level)
  (unless (mvl-unk v b) (cons level v)))

;; apply a function to a fixed value x.  Apply it to x and then call
;; hierarchy-check-unknown to return NIL if necessary.

(defun h-fn-f (x fn b level)
  (hierarchy-check-unknown (funcall fn x b) b level))

;; Apply a function to a bilattice element x.  As in s-fn-v, since this
;; function is *only* used to compute negation, it is assumed that the
;; given function never returns unknown given a non-unknown argument.

(defun h-fn-v (x fn b)
  (when x (cons (car x) (funcall fn (cdr x) b))))

;; apply a function to x and y.  There are three cases:
;;  1.  x and y are both unknown.  Return unknown (if the function
;;  doesn't return unknown, you don't know what hierarchy level to use
;;  anyway).
;;  2.  x and y are on the same level.  Apply the function; if the
;;  result is unknown, return the edge-function but at the next lower
;;  hierarchy level.
;;  3.  x and y are on different levels.  Use unknown for the lower one
;;  and proceed as in (2), except don't use the edge-function.  Just
;;  return the lower value if unknown is computed.

;; To understand this, suppose we are computing x.y if x and y are on
;; the same level and their . is unknown, then we want to return bottom
;; in the next lower level.  But if x and y are on different levels, and
;; x is above y, then since x . unknown is unknown, we should simply
;; return y.  (After all, x . y = y!)

(defun h-fn-vv (x y fn edge-fn b &aux (unk (bilattice-unknown b)) temp)
  (cond ((and (not x) (not y)) nil)
	((eql (car x) (car y))			;same level
	 (if (mvl-unk (setq temp (funcall fn (cdr x) (cdr y) b)) b)
	     (cons (1+ (car x)) (funcall edge-fn b))
	   (cons (car x) temp)))
	((or (not y) (and (numberp (car x)) (< (car x) (car y))))
						;x above y
	 (if (mvl-unk (setq temp (funcall fn (cdr x) unk b)) b)
	     y
	   (cons (car x) temp)))
	((mvl-unk (setq temp (funcall fn unk (cdr y) b)) b)
	 x)					;y above x and returns unknown
	(t (cons (car y) temp))))

;; Equality check.  The case where both are NIL is special.

(defun h-fn-eq-vv (x y b)
  (and (eql (car x) (car y))
       (or (not x) (mvl-eq (cdr x) (cdr y) b))))

;; k-le.  If the car's are the same, it's pretty easy.  Otherwise, just
;; compare the car's!

(defun h-fn-kle-vv (x y b)
  (cond ((not x))
	((eql (car x) (car y)) (k-le (cdr x) (cdr y) b))
	(y (> (car x) (car y)))))

;; t-le is a little harder.  If the car's are the same, it's easy.
;; Otherwise, basically just replace the lower one with unknown and see
;; what happens.

(defun h-fn-tle-vv (x y b)
  (cond ((eql (car x) (car y))
	 (or (not x) (t-le (cdr x) (cdr y) b)))
	((or (not x) (and (numberp (car y)) (> (car x) (car y))))
	 (t-le (bilattice-unknown b) (cdr y) b))
	(t (t-le (cdr x) (bilattice-unknown b) b))))

;; x from the hierarchical bilattice and y not.  Since this function is
;; used for plugging, if x is unknown, just return it.

(defun h-fn-vf (x y fn b)
  (when x
    (hierarchy-check-unknown (funcall fn (cdr x) y b) b (car x))))

;; vfv case is like surgery.

(defun h-fn-vfv (x y z fn b)
  (h-fn-vv x z #'(lambda (u v b) (funcall fn u y v b)) #'bilattice-unknown b))

;; Simplicity is just computed by consing the level onto the old result.
;; If the value is unknown, we return a list consisting of a big integer.

(defun h-fn-simp (x b)
  (if x
      (cons (car x) (mvl-simplicity (cdr x) b))
    (list most-positive-fixnum)))

;; The vars are just those appearing in the cdr of the truth value.

(defun h-fn-vars (x b)
  (mvl-vars (cdr x) b))

;; The modal operators on the hierarchical bilattice are the same as the
;; modal operators on the given bilattice.

(defun h-modal-ops (b)
  (mapcar #'(lambda (x)
	      (make-modal-operator
		:name (modal-operator-name x)
		:function (take-n-more-args #'h-modal-fn x b)
		:parameters (modal-operator-parameters x)))
	  (nonstandard-modal-ops b)))

;; Compute the result of a modal operator by taking the highest level of
;; any argument, and computing the result at that level, assuming that
;; any arg at a lower level is simply unknown.  Now there are three cases:
;;  1.  The result is unknown.  Return unknown.
;;  2.  The result is the same as it would have been if the args had all
;;  been unknown.  In this case, return the result at the *highest*
;;  level.  This is to make sure that L(df)=f, for example.  Even though
;;  df is at the default level, you are *certain* you don't know it.
;;  3.  Return the result, at the same level as the highest arg.

(defun h-modal-fn (args op b
		   &aux (level (or (h-max-level args op) -1)) val-on-unknown
			(temp (operate-modally
			       args op #'(lambda (x)
					   (if (eql (car x) level) (cdr x)
					     (bilattice-unknown b))))))
  (cond ((mvl-unk temp b) nil)
	((minusp level) (cons 0 temp))
	((mvl-eq temp
		 (setq val-on-unknown
		   (operate-modally args op #'(lambda (x) (declare (ignore x))
						      (bilattice-unknown b))))
		 b)
	 (cons 0 val-on-unknown))
	(t (cons level temp))))

;; here we compute the highest level of any non-parametric argument.  We
;; have to skip over the parametric ones, of course.

(defun h-max-level (args op
		    &aux ans (parameters (modal-operator-parameters op)))
  (dolist (item args ans)
    (unless (or (pop parameters) (null item))
      (setq ans (if ans (min ans (car item)) (car item))))))

;; printing.  Top level displayed normally.  For level 1 or higher, bottom
;; is displayed as * or D(n)* and other values are Dx or D(n)x.  Note that
;; bottom at level 0 is processed before you get here.

(defun h-print (x b stream)
  (setq b (car (bilattice-components b)))
  (if (mvl-eq (cdr x) (bilattice-bottom b) b)
      (format stream #-ANSI "~[~;*~:;D(~:*~a)*~]"
	             #+ANSI "~@<~[~;*~:;D(~:*~a)*~]~:>"
		     (car x))
    (format stream #-ANSI "~[~;D~:;D(~:*~a)~]~a"
	           #+ANSI "~@<~[~;D~:;D(~:*~a)~]~a~:>"
		   (car x) (mvl-print (cdr x) b))))
;; -*- Mode: LISP; Syntax: Common-lisp; Package: MVL; Base: 10 -*-

(in-package "MVL")

;; functions to produce bilattice by surgery
;;  New truth values are either (t . val) if from upper or (nil . val) if
;;  from lower.

;; 1.  Fixed bilattice elements are generally the values on the upper
;; bilattice, unless that value is unknown, in which case they are the
;; values on the lower bilattice.

;; 2.  Functional slots are constructed as for the product bilattices,
;; with functions s-fn-??, etc.

;; 3.  The modal operators are computed by s-modal-ops.

;; 4.  The long and short descriptions describe the bilattice as a
;; splice of the upper and lower bilattices; the one-character
;; identifier used is "s" or the first one available.

;; 5.  The type is "splice" and the components are the upper and lower
;; bilattices.

(defun splice-bilattice (upper lower)
  (make-standard-modal-ops
    (make-bilattice :true (cons t (bilattice-true upper))
		    :false (cons t (bilattice-false upper))
		    :unknown (cons nil (bilattice-unknown lower))
		    :bottom (cons t (bilattice-bottom upper))
		    :cutoff-val (splice-val #'bilattice-cutoff-val upper lower)
		    :stash-val (take-1-more-arg
				#'s-fn-f #'stash-value upper lower)
		    :unstash-val (take-1-more-arg
				  #'s-fn-f #'unstash-value upper lower)
		    :plus (take-2-more-args 
			   #'s-fn-vv #'mvl-plus #'bilattice-unknown
			   upper lower)
		    :dot (take-2-more-args
			  #'s-fn-vv #'mvl-dot #'bilattice-bottom upper lower)
		    :and (take-2-more-args
			  #'s-fn-vv #'mvl-and #'bilattice-true upper lower)
		    :or (take-2-more-args
			 #'s-fn-vv #'mvl-or #'bilattice-false upper lower)
		    :not (take-1-more-arg #'s-fn-v #'mvl-not upper lower)
		    :eq (take-2-more-args #'s-fn-eq-vv upper lower)
		    :kle (take-2-more-args #'s-fn-kle-vv upper lower)
		    :tle (take-2-more-args #'s-fn-tle-vv upper lower)
		    :dws (take-2-more-args
			  #'s-fn-vv #'dot-with-star #'bilattice-unknown
			  upper lower)
		    :simplicity (take-1-more-arg #'s-fn-simp upper lower)
		    :vars (splice-vars upper lower)
		    :plug (splice-plug upper lower)
		    :absorb (splice-absorb upper lower)
		    :modal-ops (s-modal-ops upper lower)
		    :print-fn #'s-print
		    :long-desc (format nil "~a spliced into ~a."
				       (dot-trim (bilattice-long-desc lower))
				       (dot-trim (bilattice-long-desc upper)))
		    :short-desc (format nil "~a/~a splice"
					(bilattice-short-desc upper)
					(bilattice-short-desc lower))
		    :char (bilattice-find-char #\s)
		    :type 'splice :components (list upper lower))))

(defun dot-trim (string) (string-right-trim '(#\.) string))

(defun splice-vars (upper lower)
  (when (some #'bilattice-vars (list upper lower))
    (take-1-more-arg #'s-fn-vars upper lower)))

(defun splice-plug (upper lower)
  (when (some #'bilattice-plug (list upper lower))
    (take-2-more-args #'s-fn-vf #'mvl-plug upper lower)))

(defun splice-absorb (upper lower)
  (when (some #'bilattice-absorb (list upper lower))
    (take-3-more-args #'s-fn-vfv #'mvl-absorb upper lower)))

;; compute a spliced version of a bilattice element.  If it's unknown in
;; the upper bilattice, use the value in the lower bilattice (with a NIL
;; consed on the front to indicate it's a lower value); otherwise use
;; the value in the upper bilattice (with a T consed on the front).

(defun splice-val (fn upper lower &aux (up (funcall fn upper)))
  (if (mvl-unk up upper) (cons nil (funcall fn lower)) (cons t up)))

;; take a truth value in the upper bilattice.  If it's unknown, return
;; unknown in the lower bilattice; otherwise, return it.

(defun move-to-splice (x upper lower)
  (if (mvl-unk x upper) (cons nil (bilattice-unknown lower)) (cons t x)))

;; Apply a function to a fixed value x.  Apply it to x in the upper
;; bilattice; if that's unknown, use the value in the lower bilattice.

(defun s-fn-f (x fn upper lower &aux (temp (funcall fn x upper)))
  (if (mvl-unk temp upper)
      (cons nil (funcall fn x lower))
    (cons t temp)))

;; Apply a function to a bilattice element x.  See if x is from upper or
;; lower and simply apply the suitable bilattice function.  It is
;; assumed that the result *cannot* be unknown in the upper bilattice.
;; (This function is used only for computing negation in the spliced
;; bilattice, so the assumption is justified.)

(defun s-fn-v (x fn upper lower)
  (cons (car x) (funcall fn (cdr x) (if (car x) upper lower))))

;; Apply a function to x and y.  There are three cases:
;;  1.  x and y are from upper.  Apply the function; if the result is
;;  unknown, return the result of applying the edge-function to the
;;  lower bilattice.  (You might want t in the lower bilattice, for
;;  example.)
;;  2.  One (say x) is from upper and the other (say y) is from lower.
;;  Now compute the function as if y were unknown in upper; if the value
;;  is unknown in upper, return y itself.  Otherwise, return the
;;  computed value in upper.
;;  3.  Both are in lower.  Just compute the result in lower and return
;;  it.

(defun s-fn-vv (x y fn edge-fn upper lower
		&aux (unk (bilattice-unknown upper)) temp)
  (cond ((and (car x) (car y))			;both in top
	 (if (mvl-unk (setq temp (funcall fn (cdr x) (cdr y) upper)) upper)
	     (cons nil (funcall edge-fn lower))
	   (cons t temp)))
	((car x)				;x in top, y in bottom
	 (if (mvl-unk (setq temp (funcall fn (cdr x) unk upper)) upper)
	     y
	   (cons t temp)))
	((car y)				;y in top, x in bottom
	 (if (mvl-unk (setq temp (funcall fn unk (cdr y) upper)) upper)
	     x
	   (cons t temp)))
	(t (cons nil (funcall fn (cdr x) (cdr y) lower)))))
						;both in bottom

;; The equality check is easier -- they have to be in the same part and
;; have to be equal in the corresponding bilattice.

(defun s-fn-eq-vv (x y upper lower)
  (and (eq (car x) (car y))
       (mvl-eq (cdr x) (cdr y) (if (car x) upper lower))))

;; For k-le, it suffices if x is in lower and y in upper, or if they are
;; in the same part and x is k-le y.

(defun s-fn-kle-vv (x y upper lower)
  (cond ((eq (car x) (car y))
	 (k-le (cdr x) (cdr y) (if (car x) upper lower)))
	((car y) t)))

;; For t-le, if they are in the same part, it's simple.  If either is in
;; upper, we treat the other as unknown in upper.

(defun s-fn-tle-vv (x y upper lower)
  (cond ((eq (car x) (car y))
	 (t-le (cdr x) (cdr y) (if (car x) upper lower)))
	((car y) (t-le (bilattice-unknown upper) (cdr y) upper))
	(t (t-le (cdr x) (bilattice-unknown upper) upper))))

;; If only one is from the spliced bilattice, it's also easy.  This
;; function is like s-fn-v, but now it *is* possible that unknown in the
;; upper be returned.  In this case, we return unknown in the lower.

(defun s-fn-vf (x y fn upper lower)
 (if (car x)
     (move-to-splice (funcall fn (cdr x) y upper) upper lower)
   (cons nil (funcall fn (cdr x) y lower))))

;; vfv is used for absorption only.  Just invoke s-fn-vv with suitable
;; lambda functions.  (If the levels are different, we're going to do
;; something strange, but that's probably a bug in the bilattice definition.)

(defun s-fn-vfv (x y z fn upper lower)
  (s-fn-vv x z #'(lambda (u v b) (funcall fn u y v b))
	   #'bilattice-unknown upper lower))

;; The simplicity is computed to give preference to upper values.  Thus
;; these values begin with a 0 and then return the upper-simplicity;
;; lower values begin with a 1 instead.

(defun s-fn-simp (x upper lower)
  (if (car x)
      (cons 0 (mvl-simplicity (cdr x) upper))
      (cons 1 (mvl-simplicity (cdr x) lower))))

;; The vars are those recognized by the upper or lower bilattice as
;; appropriate.

(defun s-fn-vars (x upper lower)
  (mvl-vars (cdr x) (if (car x) upper lower)))

;; The modal operators on the spliced bilattice are the same as those
;; on both argument bilattices.

(defun s-modal-ops (upper lower &aux ans temp)
  (dolist (op (nonstandard-modal-ops upper) ans)
    (when (setq temp (find-modal-operator op lower))
      (push (make-modal-operator
	      :name (modal-operator-name op)
	      :function (take-n-more-args #'s-modal-fn op temp upper lower)
	      :parameters (modal-operator-parameters op))
	    ans))))

;; Compute the result of a modal operator as follows:  If any operand is
;; at the top level, assume that all are (or are unknown); just compute
;; the result and return it (also at the top level).  If every operand is
;; at the lower level, compute the result there and:
;;  1.  If the result is the same as it would have been if the args had 
;;  all been unknown, return the result at the *highest* level.  This is
;;  to make sure that L(df)=f, for example.  Even though df is at the
;;  default level, you are *certain* you don't know it.
;;  2.  Otherwise, return the result at the lower level.

(defun s-modal-fn (args op-up op-low upper lower &aux ans)
  (cond ((s-arg-on-top-level args op-up)
	 (setq ans (operate-modally
		    args op-up #'(lambda (x) (if (car x) (cdr x)
					       (bilattice-unknown upper)))))
	 (move-to-splice ans upper lower))
	((mvl-eq (setq ans (operate-modally args op-low #'cdr))
		 (operate-modally args op-low
				  #'(lambda (x) (declare (ignore x))
					    (bilattice-unknown lower)))
		 lower)
	 (if (mvl-unk ans lower) (cons nil ans)
	   (cons t (operate-modally args op-up
				    #'(lambda (x) (declare (ignore x))
					      (bilattice-unknown upper))))))
	(t (cons nil ans))))

(defun s-arg-on-top-level (args op
			   &aux (parameters (modal-operator-parameters op)))
  (do ((args-left args (cdr args-left)))
      ((null parameters) (find-if #'car args-left))
    (unless (pop parameters)
      (if (caar args-left) (return t)))))

;; display function.  If upper, display normally.  If unknown, display U.
;; If bottom on lower, display *.  Otherwise, display "Dx" where x is value
;; on lower.

(defun s-print (x b stream &aux (lower (second (bilattice-components b))))
  (cond ((car x)
	 (format stream "~a"
		 (mvl-print (cdr x) (car (bilattice-components b)))))
	((mvl-eq (cdr x) (bilattice-bottom lower) lower) (format stream "*"))
	(t (format stream #-ANSI "D~a" #+ANSI "~@<D~a~:>"
		   (mvl-print (cdr x) lower)))))
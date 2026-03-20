;;; -*- Mode: LISP; Syntax: Common-lisp; Package: MVL; Base: 10 -*-

(in-package "MVL")

;; define a lattice, which is like the justification lattice and can be used
;; to construct either a bilattice or a dag.  The structure is quite
;; similar to the bilattice structure:

(defstruct (lattice (:print-function print-lattice))
  max min			;two distinguished elements
  stash-val			;default stash value (a function)
  and or			;glb and lub
  eq				;equality check
  (leq nil)			;fast comparison if available
  dws				;dot with star
  simplicity			;simplicity
  (vars nil)			;vars in lattice value
  (plug nil)			;plug a binding list into a lattice value
  long-desc short-desc		;long and short descriptions
  char				;one character identifier
  )

(defun print-lattice (l stream print-depth)
  (declare (ignore print-depth))
  (format stream "~a lattice" (lattice-short-desc l)))

(defun lattice-eql (l x y)
  (funcall (lattice-eq l) x y))

(defun lattice-le (l x y &aux (fn (lattice-leq l)))
  (if fn (funcall fn x y)
      (or (eq x y) (lattice-eql l x (funcall (lattice-and l) x y)))))

;; construct a dag from a lattice.
;;  1.  The root of the dag is the maximum element of the lattice
;;  2.  The equality operator is the one from the lattice
;;  3.  The dot operator takes the glb of the two elements, and if it's
;;  the minimal element of the lattice, returns NIL.  Otherwise, it
;;  returns a list consisting of the glb itself.
;;  4.  The descriptions are unchanged from the lattice itself

(defun lattice-to-dag (lattice)
  (make-dag :root (lattice-max lattice)
	    :eq (lattice-eq lattice)
	    :leq (lattice-leq lattice)
	    :dot (take-2-more-args
		   #'(lambda (x y &aux (temp (funcall (lattice-and lattice)
						      x y)))
		       (unless (lattice-eql lattice (lattice-min lattice) temp)
			 (list temp))))
	    :long (lattice-long-desc lattice)
	    :short (lattice-short-desc lattice)
	    :vars (lattice-vars lattice)
	    :plug (lattice-plug lattice)))

;; construct a bilattice from a lattice.  Elements are of the form (x . y),
;; where x is the justification for p and y the justification for (not p)

;; 1.  True is (max . min), and so on.

;; 2.  The functional bilattice slots are constructed as usual, with
;; things like lb-fn-f and so on.  Negation is special since it simply
;; flips the two components of the truth value.

;; 3.  There are no modal operators (other than the standard ones).  The
;; absorption function is trivial, because the simple lattice mechanism
;; really won't support it.

;; 4.  The long and short descriptions, as well as the 1-character
;; identifier, are the same as for the lattice.

;; 5.  The type is "lattice" and the single component is the lattice
;; supplied.

(defun lattice-to-bilattice (lattice)
  (make-standard-modal-ops
    (make-bilattice :true (lattice-elt #'lattice-max #'lattice-min lattice)
		    :false (lattice-elt #'lattice-min #'lattice-max lattice)
		    :unknown (lattice-elt #'lattice-min #'lattice-min lattice)
		    :bottom (lattice-elt #'lattice-max #'lattice-max lattice)
		    :cutoff-val (lattice-elt
				 #'lattice-min #'lattice-min lattice)
		    :stash-val (take-1-more-arg
				#'lb-fn-f #'lattice-stash-val lattice)
		    :unstash-val (lb-unstash-val lattice)
		    :plus (take-2-more-args
			   #'lb-fn-vv #'lattice-or #'lattice-or lattice)
		    :dot (take-2-more-args
			  #'lb-fn-vv #'lattice-and #'lattice-and lattice)
		    :and (take-2-more-args
			  #'lb-fn-vv #'lattice-and #'lattice-or lattice)
		    :or (take-2-more-args
			 #'lb-fn-vv #'lattice-or #'lattice-and lattice)
		    :not (take-1-more-arg #'lb-fn-x)
		    :eq (take-2-more-args #'lb-fn-eq-vv lattice)
		    :kle (take-2-more-args #'lb-fn-kle-vv lattice)
		    :tle (take-2-more-args #'lb-fn-tle-vv lattice)
		    :simplicity (take-1-more-arg #'lb-fn-simp lattice)
		    :vars (lattice-vrs lattice)
		    :dws (take-2-more-args
			  #'lb-fn-vv #'lattice-dws #'lattice-dws lattice)
		    :plug (lattice-plg lattice)
		    :long-desc (lattice-long-desc lattice)
		    :short-desc (lattice-short-desc lattice)
		    :char (lattice-char lattice)
		    :type 'lattice
		    :components lattice
		    )))

(defun lattice-elt (fn1 fn2 lattice)
  (cons (funcall fn1 lattice) (funcall fn2 lattice)))

(defun lattice-vrs (lattice)
  (when (lattice-vars lattice)
    (take-1-more-arg #'lb-fn-vars lattice)))

(defun lattice-plg (lattice)
  (when (lattice-plug lattice)
    (take-2-more-args #'lb-fn-plug-v lattice)))

(defun lb-unstash-val (lattice)
  #'(lambda (p) (declare (ignore p))
	    (lattice-elt #'lattice-min #'lattice-min lattice)))

;; To apply a function to a fixed value, just apply it and save that as
;; the "true" part of the justification; the "false" part is empty.

(defun lb-fn-f (x fn l)
  (cons (funcall (funcall fn l) x) (lattice-min l)))

;; to apply a function to two bilattice values, apply the lattice
;; function to the cars and cdrs respectively.  The *two* functions
;; supplied are what the functions should be on the cars and cdrs, since
;; these may be different (i.e., the bilattice OR should take the max of
;; the "true" parts and the min of the "false" parts)

(defun lb-fn-vv (x y fn1 fn2 l)
  (cons (funcall (funcall fn1 l) (car x) (car y))
	(funcall (funcall fn2 l) (cdr x) (cdr y))))

;; negate a bilattice element by swapping the car and cdr

(defun lb-fn-x (x)
  (cons (cdr x) (car x)))

;; equality check -- are the cars and cdrs lattice-eq?

(defun lb-fn-eq-vv (x y l)
  (and (lattice-eql l (car x) (car y))
       (lattice-eql l (cdr x) (cdr y))))

;; inequality checks are also easy -- just compare (appropriately!) the
;; two parts of the truth values

(defun lb-fn-kle-vv (x y l)
  (and (lattice-le l (car x) (car y)) (lattice-le l (cdr x) (cdr y))))

(defun lb-fn-tle-vv (x y l)
  (and (lattice-le l (car x) (car y)) (lattice-le l (cdr y) (cdr x))))

;; simplicity is just the simplicity of the "true" part, since the false
;; part is presumably irrelevant to the scheduler

(defun lb-fn-simp (x l)
  (funcall (lattice-simplicity l) (car x)))

;; The vars are just the union of those in the car and those in the cdr.

(defun lb-fn-vars (x l)
  (nunion (funcall (lattice-vars l) (car x)) 
	  (funcall (lattice-vars l) (cdr x))))

;; the plugging function simply plugs into the car and cdr respectively.

(defun lb-fn-plug-v (val bdg l)
  (cons (funcall (lattice-plug l) (car val) bdg)
	(funcall (lattice-plug l) (cdr val) bdg)))

;; Here's a more subtle function that takes a base bilattice B and a
;; lattice L and constructs B^L by first turning L into a dag and then
;; using the exponentiation construction in dag.lisp.  Unfortunately,
;; the simpleminded construction (make L into a dag D, and then
;; construct B^D) isn't quite right:
;;  1.  The default stash value shouldn't be the stash value in the
;;  bilattice B, taken at the root of the dag, but instead should
;;  be the stash value in B taken at the default stash point in the
;;  lattice.  This is what ldb-stash-value does.
;;  2.  The simplicity function should give priority to the simplicity
;;  computed by the bilattice B, but should also include simplicity
;;  information from the lattice.  This is what ldb-simp does; the
;;  lambda (x) function appearing there appends the bilattice
;;  simplicity, applied to the bilattice value, to the lattice
;;  simplicity (applied to the lattice value).

;; This function returns two values -- the bilattice constructed, and
;; the dag constructed for the lattice supplied.

(defun lattice-to-dag-to-bilattice
    (lattice base-bilattice &aux (d (lattice-to-dag lattice)) 
				 (b (dag-bilattice d base-bilattice)))
  (setf (bilattice-stash-val b)
    (take-1-more-arg #'ldb-stash-value lattice d base-bilattice)
    (bilattice-simplicity b)
    (take-1-more-arg #'ldb-simp lattice base-bilattice))
  (values b d))

(defun ldb-stash-value (prop lattice dag bilattice)
  (make-tv dag bilattice (funcall (lattice-stash-val lattice) prop)
	   (stash-value prop bilattice)))

(defun ldb-simp (x lattice bilattice)
  (reduce #'simplicity-min
	  (mapcar #'(lambda (x) 
		      (append (mvl-simplicity (dag-val x) bilattice)
			      (funcall (lattice-simplicity lattice)
				       (dag-pt x))))
		  (dag-fn-list x))))

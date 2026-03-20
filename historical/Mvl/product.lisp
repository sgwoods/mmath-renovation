;;; -*- Mode: LISP; Syntax: Common-lisp; Package: MVL; Base: 10 -*-

(in-package "MVL")

;; This file produces bilattices that are the product of two given ones.
;; Since a lot of the files that do things like this have similar
;; formats, we will discuss this in some detail.  Here is how the fields
;; in the product bilattice are constructed; bear in mind that an
;; element of the product bilattice is a dotted pair of elements of each
;; of the base bilattices.

;; 1.  The bilattice elements true, false, etc. (including cutoff-val
;; which is a simple bilattice element) are simply consed
;; up out of the corresponding elements on the component bilattices.

;; 2.  The bilattice slots that are basically functions require some
;; work, because we want to make sure that they are compiled and not
;; interpreted.  So we have things like p-fn-f, which is a function that
;; takes as arguments a bilattice descriptor function (like
;; bilattice-stash-val), two bilattices, and an object x.  What it does
;; is apply the bilattice descriptor function to each of the bilattices,
;; apply the result to the object x, and then cons the results together.
;; Since we have to actually produce a function does this with x as an
;; argument, there is a function "take-1-more-arg" that does this.
;; take-1-more-arg accepts as arguments a function f (the one that will
;; eventually get the argument), and then a bunch of other args.  It
;; creates, compiles and returns a function that accepts 1 argument and
;; then invokes the given function f on that argument and all of the
;; other arguments supplied to take-1-more-arg.
;;
;; In this example, we call take-1-more-arg with 'p-fn-f,
;; #'bilattice-stash-val and the two component bilattices.  The result
;; is a function that accepts an argument x and invokes
;;   (p-fn-f x #'bilattice-stash-val b1 b2).
;; Now we have to make sure that p-fn-f does the right thing, so that if
;; the call is
;;   (p-fn-f x fn bilattice1 bilattice2)
;; the result is the cons of applying fn to each bilattice and applying
;; the result of *that* to x.  But that's the easy part.
;;
;; In general, when we write something like p-fn-vf, the leading p
;; refers to the product construction, the fn refers to all this
;; functional manipulation, and the vf describes what the function is
;; doing.  The fact that there are two letters (v and f) means that two
;; more arguments are expected; the v indicates that the first is an
;; element of the product bilattice (which therefore has to be split
;; into components before being passed to the subsidiary function) and
;; the f indicates that the second argument is not an element of the
;; bilattice and can therefore be passed as is.  p-fn-and-vv is not
;; supposed to produce a bilattice element as a result, but is instead
;; supposed to determine (conjunctively, presumably) if the two
;; bilattice elements are the same.  p-fn-simp produces a simplicity
;; measure for an element of the product bilattice.
;;
;; The plugging functions are handled specially, since this functional
;; manipulation is slow.  Specifically, if the plugging functions on
;; each component bilattice are the default ones (i.e., just pass the
;; truth value back without doing any plugging at all), then we can
;; continue using that function on the product bilattice.  If not,
;; though, we invoke the functional mechanism described above.
;;
;; Finally, the variables in a compound truth value can be found by
;; taking the union of the variables in either component.

;; 3.  The modal operators on the product bilattice are computed by
;; p-modal-ops.

;; 4.  The long description of the product bilattice is "product of b1
;; and b2" and the short description is "b1 x b2".  The one-character
;; identifier is "p" if it is available.

;; 5.  A product bilattice is of type "product" and the components are
;; the bilattices supplied to the product function.

(defun product-bilattice (b1 b2)
  (make-standard-modal-ops
    (make-bilattice :true (product-elt #'bilattice-true b1 b2)
		    :false (product-elt #'bilattice-false b1 b2)
		    :unknown (product-elt #'bilattice-unknown b1 b2)
		    :bottom (product-elt #'bilattice-bottom b1 b2)
		    :cutoff-val (product-elt #'bilattice-cutoff-val b1 b2)
		    :stash-val (take-1-more-arg #'p-fn-f #'stash-value b1 b2)
		    :unstash-val (take-1-more-arg
				  #'p-fn-f #'unstash-value b1 b2)
		    :plus (take-2-more-args #'p-fn-vv #'mvl-plus b1 b2)
		    :dot (take-2-more-args #'p-fn-vv #'mvl-dot b1 b2)
		    :and (take-2-more-args #'p-fn-vv #'mvl-and b1 b2)
		    :or (take-2-more-args #'p-fn-vv #'mvl-or b1 b2)
		    :not (take-1-more-arg #'p-fn-v #'mvl-not b1 b2)
		    :eq (take-2-more-args #'p-fn-and-vv #'mvl-eq b1 b2)
		    :kle (take-2-more-args #'p-fn-and-vv #'k-le b1 b2)
		    :tle (take-2-more-args #'p-fn-and-vv #'t-le b1 b2)
		    :dws (take-2-more-args #'p-fn-vv #'dot-with-star b1 b2)
		    :simplicity (product-simp b1 b2)
		    :vars (product-vars b1 b2)
		    :plug (product-plug b1 b2)
		    :absorb (product-absorb b1 b2)
		    :modal-ops (p-modal-ops b1 b2)
		    :print-fn #'p-print
		    :long-desc (format nil "Product of ~a and ~a."
				       (dot-trim (bilattice-long-desc b1))
				       (dot-trim (bilattice-long-desc b2)))
		    :short-desc (format nil "~a x ~a" (bilattice-short-desc b1)
					(bilattice-short-desc b2))
		    :char (bilattice-find-char #\p)
		    :type 'product :components (list b1 b2))))

(defun product-elt (fn b1 b2) (cons (funcall fn b1) (funcall fn b2)))

;; vars in a product:  If both bilattice-vars functions are NIL, we can
;; return NIL.  Otherwise, call p-fn-vars.

(defun product-simp (b1 b2)
  (when (some #'bilattice-simplicity (list b1 b2))
    (take-1-more-arg #'p-fn-simp b1 b2)))

(defun product-vars (b1 b2)
  (when (some #'bilattice-vars (list b1 b2))
    (take-1-more-arg #'p-fn-vars b1 b2)))

(defun product-plug (b1 b2)
  (when (some #'bilattice-plug (list b1 b2))
    (take-2-more-args #'p-fn-vf #'mvl-plug b1 b2)))

(defun product-absorb (b1 b2)
  (when (some #'bilattice-absorb (list b1 b2))
    (take-3-more-args #'p-fn-vfv #'mvl-absorb b1 b2)))

;; Here are the functions that produce compiled versions of functions
;; that use additional arguments ...

(defun take-1-more-arg (fn &rest args)
  (compile nil `(lambda (x) (apply ',fn x ',args))))

(defun take-2-more-args (fn &rest args)
  (compile nil `(lambda (x y) (apply ',fn x y ',args))))

(defun take-3-more-args (fn &rest args)
  (compile nil `(lambda (x y z) (apply ',fn x y z ',args))))

(defun take-n-more-args (fn &rest args)
  (compile nil `(lambda (&rest other-args) (apply ',fn other-args ',args))))

;; As described above, a product function where the argument is "fixed"
;; (i.e., not a bilattice element that must be destructured).  Apply the
;; given functions to x and cons together the two results to get a bilattice
;; element.

(defun p-fn-f (x fn b1 b2)
  (cons (funcall fn x b1) (funcall fn x b2)))

;; If the argument *is* a bilattice element, then we apply the functions
;; to its car and cdr respectively, since those are the components of
;; the truth value that should be examined by each bilattice.

(defun p-fn-v (x fn b1 b2)
  (cons (funcall fn (car x) b1) (funcall fn (cdr x) b2)))

;; Here's one that accepts two more arguments.  The first is a
;; "variable" bilattice element and the second is a "fixed" value.

(defun p-fn-vf (x y fn b1 b2)
  (cons (funcall fn (car x) y b1) (funcall fn (cdr x) y b2)))

;; Two "variable" arguments

(defun p-fn-vv (x y fn b1 b2)
  (cons (funcall fn (car x) (car y) b1) (funcall fn (cdr x) (cdr y) b2)))

;; also two variable arguments, but instead of using cons to construct a
;; new truth value, use and to check for equality or k-le or t-le.

(defun p-fn-and-vv (x y fn b1 b2)
  (or (eq x y)
      (and (funcall fn (car x) (car y) b1) (funcall fn (cdr x) (cdr y) b2))))

(defun p-fn-vfv (x y z fn b1 b2)
  (cons (funcall fn (car x) y (car z) b1) (funcall fn (cdr x) y (cdr z) b2)))

;; The simplicity of a compound element is the smaller of the
;; simplicities of each element taken in its own bilattice.

(defun p-fn-simp (x b1 b2)
  (simplicity-min (mvl-simplicity (car x) b1) (mvl-simplicity (cdr x) b2)))

;; one agenda pointer is less than another provided that the second
;; pointer is nonempty and:
;;  1. The first pointer *is* empty, or
;;  2. The car of the first pointer is less than the car of the second, or
;;  3. The cars are the same and the cdr of the first is simplicity-<
;;  the cdr of the second.

(defun simplicity-< (s1 s2)
  (and s2
       (or (null s1) (< (car s1) (car s2))
	   (and (= (car s1) (car s2)) (simplicity-< (cdr s1) (cdr s2))))))

(defun simplicity-min (s1 s2)
  (if (simplicity-< s1 s2) s1 s2))

;; The variables in a compound element are the union of the variables in
;; each component.

(defun p-fn-vars (x b1 b2)
  (nunion (mvl-vars (car x) b1) (mvl-vars (cdr x) b2)))

;; Here we construct modal operators on the product bilattice.  Begin by
;; noting that there will *be* a modal operator on the product whenever
;; there are modal operators on the components that share a name.  In
;; that case, the new modal operator will have the same name as the
;; component ones.  Its functional value applied to a sequence a ... b
;; of values will be the result of applying the first modal operator to
;; the car's and the second to the cdr's and consing together the
;; results.  The parameters arguments have to match.

(defun p-modal-ops (b1 b2 &aux ans temp)
  (dolist (op (nonstandard-modal-ops b1) ans)
    (when (setq temp (find-modal-operator op b2))
      (push (make-modal-operator
	      :name (modal-operator-name op)
	      :function (take-n-more-args #'p-modal-fn op temp)
	      :parameters (modal-operator-parameters op))
	    ans))))

(defun find-modal-operator (op bilattice
			    &aux (temp (find (modal-operator-name op)
					     (bilattice-modal-ops bilattice)
					     :key #'modal-operator-name)))
  (when (and temp (equal (modal-operator-parameters op)
			 (modal-operator-parameters temp)))
    temp))

(defun p-modal-fn (args op1 op2)
  (cons (operate-modally args op1 #'car)
	(operate-modally args op2 #'cdr)))

;; apply a modal operator by sorting out the parameters and then invoking
;; the function

(defun operate-modally (args op fn)
  (apply (modal-operator-function op) (pass-modal-parameters args op fn)))

;; some of the "arguments" are in fact parameters, and you shouldn't
;; mess around with them.  This generic function takes a list of
;; arguments, a modal operator, and a modification function.  It passes
;; the parameters and operates on the real arguments with the given
;; function.

(defun pass-modal-parameters 
    (args op fn &aux (parameters (modal-operator-parameters op)))
  (mapcar (if parameters
	      #'(lambda (x) (if (pop parameters) x (funcall fn x)))
	    fn)
	  args))

;; printing -- invoke the print functions on the other bilattices (using
;; mvl-print) and then just use format to do the work.

(defun p-print (x b stream)
  (format stream #-ANSI "(~a x ~a)" #+ANSI "~@:<~a ~_x ~a~:>"
	  (mvl-print (car x) (car (bilattice-components b)))
	  (mvl-print (cdr x) (second (bilattice-components b)))))
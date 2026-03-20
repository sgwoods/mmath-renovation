;;; -*- Mode: LISP; Syntax: Common-lisp; Package: MVL; Base: 10 -*-

(in-package "MVL")

;; procedural attachments for:
;; 
;; lisp functions car cdr cadr cons list list* revappend append reverse length
;; 	       	  assoc delete + * - // floor ceiling truncate round float
;;		  mod rem max min sin cos atan sqrt eval
;; 
;; bagof
;; done
;; value
;; property
;; 
;; lisp predicates numberp < > equal null atom listp varp varp? varp*
;; groundp =
;; 
;; known
;; unknown
;; member
;; 
;; also defines functions:
;; 
;; invoke (fn p &rest args)	invoke function with prop and args but add
;;				:allow-other-keys
;; 
;; lookup-call (fn p &rest args)	invoke modified for lookup
;; lookups-call (fn p &reset args)	invoke modified for lookups
;; 
;; singularize (x)			list of answers to single answer
;; pluralize (x)			single answer to list of answers

(defparameter *warn-on-bad-lisp-invocations* nil)

;; lookups attachment for a relation symbol that is in fact a lisp
;; function.  If "true" passes the cutoff test, then we have to check
;; out the argument list.  The args are everything but the last arg in
;; the relation, and the value is the last argument itself.  There are
;; now the following cases:
;;  1.  If either the function doesn't care or all of the args are
;;  ground, then we simply invoke the function and unify the result with
;;  the value.
;;  2.  If the value is nonground and at least one arg is as well, then
;;  presumably he's made a mistake.  We warn him if he wants it, and
;;  fail.
;;  3.  If the value is nonground and there is an inverter function, then
;;  we invoke the inverter function on the value and all the args.
;;  4.  If the value is nonground and there is no inverter function, we
;;  groan at him and fail.
;; Note that we attach to lookups, not lookup, since the unifier may
;; return multiple answers.

(defun lookups-lisp-fn (p &key (cutoffs std-cutoffs) &allow-other-keys)
  (when (test true cutoffs)
    (let* ((args (butlast (cdr p))) (value (car (last p))))
      (cond ((or (eq (get-mvl (car p) 'inverter) t)
		 (every #'groundp args))
	     (unifyp (apply (or (get (car p) 'lisp) (car p)) args) value))
	    ((not (groundp value))
	     (if *warn-on-bad-lisp-invocations*
		 (warn "Variables in arguments and result for ~a." p))
	     nil)
	    ((get-mvl (car p) 'inverter)
	     (apply (get-mvl (car p) 'inverter) value args))
	    (*warn-on-bad-lisp-invocations*
	     (warn 
	      "No inversion function defined for ~a with variable arguments."
	      (car p)))))))		;warn returns NIL

;; attaching a lisp function:  You can't stash or unstash it, and looking
;; it up uses lookups-lisp-fn.  If it has an inverter function, say so.

(defmacro lisp-defined (fn &optional (inv-fn nil has-inv))
  `(progn
     (setf (get ',fn 'stash) 'stash-failure)
     (setf (get ',fn 'unstash) 'unstash-failure)
     (setf (get ',fn 'lookups) 'lookups-lisp-fn)
     (if ,has-inv (setf (get ',fn 'inverter) ',inv-fn)
       (remprop ',fn 'inverter))
     nil))

(defun stash-failure (p &key &allow-other-keys)
  (cerror "Continue without stashing ~a."
	  "~a is predefined.~%Cannot stash." p))

(defun unstash-failure (p &key &allow-other-keys)
  (cerror "Continue without unstashing ~a." 
	  "~a is predefined.~%Cannot unstash." p))

;; here are the lisp functions MVL knows about:  (No inverters are
;; currently defined, because the author was too lazy to do it.)

(lisp-defined car)
(lisp-defined cdr)
(lisp-defined cadr)
(lisp-defined cons)
(lisp-defined list)
(lisp-defined list*)
(lisp-defined revappend)
(lisp-defined append)
(lisp-defined reverse)
(lisp-defined length)
(lisp-defined assoc)
(lisp-defined delete)
(lisp-defined +)
(lisp-defined *)
(lisp-defined -)
(lisp-defined //)
(lisp-defined floor)
(lisp-defined ceiling)
(lisp-defined truncate)
(lisp-defined round)
(lisp-defined float)
(lisp-defined mod)
(lisp-defined rem)
(lisp-defined max)
(lisp-defined min)
(lisp-defined sin)
(lisp-defined cos)
(lisp-defined atan)
(lisp-defined sqrt)
(lisp-defined eval)

;; bagof is a function that doesn't care if its args are ground or not.
;; The idea is that (bagof ?x ?exp ?y) unifies ?y with the bag of all ?x
;; that satisfy ?exp.  So bagof, as a function, should return a list of
;; all the bindings for ?x that come up if you invoke the prover on
;; ?exp.

(lisp-defined bagof t)

(defun bagof (x prop &key (cutoffs std-cutoffs) (succeeds *never-succeeds*)
	      &aux nl)
  (dolist (item (bcs prop :cutoffs cutoffs :succeeds succeeds) (nreverse nl))
    (push (plug x (answer-binding item)) nl)))

;; done is a function that is used for stashing only -- the idea is to
;; execute the arguments as lisp forms.  Looking it up succeeds after
;; signalling a warning.  sample use -- stashing (done (setq a 5)) will
;; set a to 5.

(setf (get 'done 'stash) 'stashdone)
(setf (get 'done 'unstash) 'unstash-failure)
(setf (get 'done 'lookup) 'done)

(defun stashdone (p &key &allow-other-keys)
  (mapc #'eval (cdr p)))

(defun done (&rest prop)
  (declare (ignore prop))
  (warn "Attempt to prove DONE statement -- returning success.")
  (make-answer))

;; value is a function that says that the value of an argument is as
;; given.  Thus stashing (value a 5) sets a to 5; unstashing it makes a
;; unbound if its value was 5 initially.  Looking it up succeeds if and
;; only if the value of (second p) unifies with (third p).

(setf (get 'value 'stash) 'stashvalue)
(setf (get 'value 'unstash) 'unstashvalue)
(setf (get 'value 'lookups) 'lookupsvalue)

(defun stashvalue (p &key &allow-other-keys)
  (if (atom (second p)) (set (second p) (third p))
      (warn "Can't stash a value for ~a; it's not an atom" (second p))))

(defun unstashvalue (p &key &allow-other-keys)
  (if (and (atom (second p)) (boundp (second p))
	   (unifyp (third p) (symbol-value (second p))))
      (makunbound (second p))))

(defun lookupsvalue (p &key (cutoffs std-cutoffs) &allow-other-keys)
  (when (and (test true cutoffs) (atom (second p)) (boundp (second p)))
    (napcar #'make-answer-from-binding
	    (unifyp (third p) (symbol-value (second p))))))

;; property is like value, but deals with property lists.  Stashing
;; (property a value slot) sets a's slot property to value.  Unstashing
;; it removes the slot property if its value was as given initially.
;; Looking it up tries to unify the third value with the result of
;; getting the slot property of the second.

(setf (get 'property 'stash) 'stashproperty)
(setf (get 'property 'unstash) 'unstashproperty)
(setf (get 'property 'lookups) 'lookupsproperty)

(defun stashproperty (p &key &allow-other-keys)
  (if (and (groundp p) (atom (second p)))
      (setf (get-mvl (second p) (fourth p)) (third p))
      (warn "Arguments of wrong type to stash: ~a" p)))

(defun unstashproperty (p &key &allow-other-keys)
  (if (and (groundp (second p)) (groundp (fourth p)) (atom (second p))
	   (unifyp (third p) (get-mvl (second p) (fourth p))))
      (rem-mvl (second p) (fourth p))))

(defun lookupsproperty (p &key (cutoffs std-cutoffs) &allow-other-keys)
  (when (and (test true cutoffs) (atom (second p)) (groundp (second p))
	     (groundp (fourth p)) (get-mvl (second p) (fourth p)))
    (napcar #'make-answer-from-binding
	    (unifyp (third p) (get-mvl (second p) (fourth p))))))

;; lookups attachment for a relation symbol that is in fact a lisp
;; predicate.  If "true" passes the cutoff test, then we have to check
;; out the argument list.  If everything is ground or we don't care, we
;; just invoke the lisp function.  Otherwise, we warn the user and
;; fail.  In this case, we attach to lookup since only one answer will
;; be returned.

(defun lookup-lisp-pred (p &key (cutoffs std-cutoffs) &allow-other-keys)
  (cond ((or (get-mvl (car p) 'accepts-vars)
	     (every #'groundp (cdr p)))
	 (if (apply (or (get (car p) 'lisp) (car p)) (cdr p))
	     (if (test true cutoffs) (make-answer))
	   (if (test false cutoffs) (make-answer :value false))))
	(*warn-on-bad-lisp-invocations*
	 (warn "The relation predicate ~a cannot accept variable arguments."
	       (car p)))))			;warn returns NIL anyway

(defmacro lisp-predicate (fn &optional (accepts-var t))
  `(progn
     (setf (get ',fn 'stash) 'stash-failure)
     (setf (get ',fn 'unstash) 'unstash-failure)
     (setf (get ',fn 'lookup) 'lookup-lisp-pred)
     (if ,accepts-var (setf (get ',fn 'accepts-vars) t)
       (remprop ',fn 'accepts-vars))
     nil))

;; here are the lisp predicates the system knows about:

(lisp-predicate numberp)
(lisp-predicate |<| nil)
(lisp-predicate |>| nil)
(lisp-predicate equal)
(lisp-predicate null)
(lisp-predicate atom)
(lisp-predicate listp)
(lisp-predicate varp)
(lisp-predicate varp?)
(lisp-predicate varp*)
(lisp-predicate groundp)

;; = is a lisp predicate, but should call unify on its args and have an
;; attachment to lookups since many answers may be returned.

(lisp-predicate =)
(remprop '= 'lookup)
(setf (get '= 'lookups) 'lookups=)

(defun lookups= (p &key &allow-other-keys)
  (napcar #'make-answer-from-binding (unifyp (second p) (third p))))

;; (known p) is just like p -- stashing it stashes p, lookup and lookups
;; just try the same operation on p.  [Unstashing??]

(setf (get 'known 'stash) 'stashknown)
(setf (get 'known 'unstash) 'unstash-failure)
(setf (get 'known 'lookup) 'lookupknown)
(setf (get 'known 'lookups) 'lookupsknown)

(defun stashknown (p &rest args) (apply #'stash (second p) args))
(defun lookupknown (p &rest args) (apply #'lookup (second p) args))
(defun lookupsknown (p &rest args) (apply #'lookups (second p) args))

;; (unknown p) -- stashing unstashes p; looking it up tries to lookup p
;; and "unknownifies" the result.

(setf (get 'unknown 'stash) 'stashunknown)
(setf (get 'unknown 'unstash) 'unstash-failure)
(setf (get 'unknown 'lookup) 'lookupunknown)

(defun stashunknown (p &key &allow-other-keys) (unstash (second p)))

(defun lookupunknown (p &rest args)
  (unknownify (apply #'lookup (second p) args) p))

;; "unknownification" -- if the prop was found, fail.  If it wasn't
;; found, succeed.

(defun unknownify (ans prop)
  (declare (ignore prop))
  (if (not ans) (make-answer) (make-answer :value false)))

;; member is rather simpler.  It, too, is a lisp predicate, but we try
;; to unify the third arg with any element of the second.

(lisp-predicate member)
(remprop 'member 'lookup)
(setf (get 'member 'lookups) 'lookupsmember)

(defun lookupsmember (p &key &allow-other-keys)
  (mapcan #'(lambda (x) (unifyp (second p) x)) (third p)))

;; here is the stuff that actually does the work.   For things like
;; stash and unstash, "invoke" applies the given function to the
;; proposition and any other arguments that were supplied.

(defun invoke (fn p &rest args) (apply fn p :allow-other-keys t args))

;; lookup is slightly trickier because we want to handle any lookup
;; routine returning an <answer> or simply a binding.  So we apply the
;; function and see what comes back -- presumably an answer.  If the
;; value is indeed an answer, then if it passes the cutoff test, we
;; return it and "attach" as the source of the match.

;; If the first value isn't an answer, we assume that the truth value is
;; true and produce an answer from that.  Then we proceed as above.

(defun lookup-call (fn p &rest args &key (cutoffs std-cutoffs)
		    &aux (x (apply fn p :allow-other-keys t args)))
  (when x
    (unless (answer-p x) (setq x (make-answer :binding x)))
    (when (test (answer-value x) cutoffs)
      (values x 'attach))))

;; lookups-call is just like lookup-call but it accumulates two
;; *lists* of values to return.

(defun lookups-call (fn p &rest args &key (cutoffs std-cutoffs))
  (do ((xs (apply fn p :allow-other-keys t args) (cdr xs)) ax az)
      ((null xs) (values (nreverse ax) az))
    (unless (answer-p (car xs))
      (setf (car xs) (make-answer :binding (car xs))))
    (when (test (answer-value (car xs)) cutoffs)
      (push (car xs) ax)
      (push 'attach az))))

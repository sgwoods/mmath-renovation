;;; -*- Mode: LISP; Syntax: Common-lisp; Package: MVL; Base: 10 -*-

(in-package "MVL")

;; following code is for the dag of theories.  Functions are: activate
;; includes unincludes.  Root is always called *global*.

;; global variables defined:
;; 
;; *global*		root of theory dag
;; theory-dag		dag of theories
;; *active-theory*	theory that is active for reading and writing
;; 
;; functions defined:
;; 
;; includes (big little)	little is a subtheory of big
;; unincludes (big little)	little is not a subtheory of big
;; removes-theory-tree (optional (root *global*)) remove every theory under
;;						  the root
;; 
;; activate (theory)   activate theory
;; 
;; activate-theory-mechanism	replace current bilattice with fns from
;; 				theory-dag into that bilattice
;; theory-active-p		returns T or NIL depending on whether or
;; 				not the theory mechanism is active
;; 
;; theory-contents (theory)	returns contents of theory
;; 
;; erase-from-theory (prop &key fc (th *active-theory*))
;; 				erase the given proposition from the theory th.
;; 				fc is passed to erase function in fc.
;; state-in-theory (p &key (th *active-theory*) value increment-p function)
;;				state the proposition in the given theory
;; unstate-from-theory (p &key (th *active-theory*) value decrement-p
;;			       function)
;;				remove the proposition from the theory
;; empty-theory (&key (th *active-theory*))	
;;				remove everything from the theory

(defconstant *global* 'global)
(defvar theory-dag)
(defvar *active-theory*)
(defvar true-in-theory)

;; Defining the theory dag.  A theory t1 is more specific than another
;; t2 if they are equal or if some parent of t1 is more specific than t2.

(defun theory-dag-le (t1 t2)
  (or (eq t1 t2)
      (some #'(lambda (x) (theory-dag-le x t2))
	    (get-mvl t1 'parent-theories))))

;; Dot is a little harder.  If t2 is below t1, just return a list of t2.
;; Otherwise, if t1 is less than t2, return a list of *that*.  In the last
;; case, if t1 has only one child, we can just use that.  If there are
;; multiple children, we have to combine the results from all of them.

(defun theory-dag-dot (t1 t2)
  (if (theory-dag-le t2 t1)
      (list t2)
    (tdd-1 t1 t2)))

(defun tdd-1 (t1 t2)
  (if (theory-dag-le t1 t2)
      (list t1)
    (let ((kids (get-mvl t1 'child-theories)))
      (cond ((cdr kids)
	     (delete-duplicates (mapcan #'(lambda (x) (tdd-1 x t2)) kids)))
	    (kids (tdd-1 (car kids) t2))))))

(defun make-theory-dag ()
  (setq theory-dag
	(make-dag :root *global* :eq #'eql :leq #'theory-dag-le
		  :dot #'theory-dag-dot :long "Tree of theories."
		  :short "Theory")))

;; a theory includes another.  Push the parent onto the child's list of
;; parents, and the child onto the parent's list of children.

(defun includes (big little)
  (pushnew big (get-mvl little 'parent-theories))
  (pushnew little (get-mvl big 'child-theories)))

;; unincludes is like includes, but pops the theories off the list
;; instead of adding them.  popf is like delete but guarantees that the
;; argument is modified.

(defun unincludes (big little)
  (popf (get-mvl little 'parent-theories) big :count 1)
  (popf (get-mvl big 'child-theories) little :count 1))

;; remove-theory-tree takes a root and removes every theory below it.
;; This is done recursively, so that the entire subtree is removed.

(defun remove-theory-tree (&optional (root *global*))
  (mapc #'(lambda (little)
	    (remove-theory-tree little)
	    (unincludes root little))
	(copy-list (get-mvl root 'child-theories))))

;; activate a theory.  If you can't find your way back to
;; *global*, then presumably he hasn't located the given theory in the
;; tree and you should warn him and, if he continues, include it in
;; *global*.  We also destructively modify std-cutoffs so that it invokes
;; bilattice-cutoff-val on the base bilattice at the given theory and
;; ignores everything else.  Ditto for *success-test* and *knowledge-test*

(defun activate (th &aux (base (theory-base)))
  (unless (dag-le theory-dag th *global*)
    (cerror "Include ~a in *global*"
	    "~a has no path back to the global theory" th)
    (includes *global* th))
  (setq *active-theory* th
	true-in-theory (make-tv theory-dag base th (bilattice-true base)))
  (setf (test-value (caar std-cutoffs))
    (make-tv theory-dag base th (bilattice-unknown base)
	     :root-fn #'bilattice-true)
    (test-value (caar *success-test*))
    (make-tv theory-dag base th (bilattice-true base))
    (test-value (caar *knowledge-test*))
    (make-tv theory-dag base th (bilattice-unknown base) 
	     :root-fn #'bilattice-bottom))
  th)

;; activate the theory mechanism.  This function accepts an optional
;; bilattice as an argument; if supplied, we find the bilattice the user
;; has requested and load that before proceeding.

;; Now, we set bb to the currently active bilattice, and db to the
;; bilattice of functions from a fresh copy of the theory dag into this
;; base bilattice.  Then we have to fix it up in two ways:
;;  1.  The stashing and unstashing functions have to use
;;  *active-theory*.
;;  2.  The print function should print the value in the active theory
;;  only.
;; Having done all this, we load the bilattice, and clear the theory
;; tree (which might have just left around from some previous use of the
;; theory mechanism).  We set the *active-theory* to *global*.

(defun activate-theory-mechanism (&optional b &aux db bb)
  (when (characterp b) (setq b (or (bilattice-with-char b) 
				   (choose-bilattice))))
  (if b (load-logic b))
  (setf bb *active-bilattice*
	db (dag-bilattice (make-theory-dag) *active-bilattice*)
	(bilattice-stash-val db) 
	(take-1-more-arg #'t-fn-f #'stash-value #'bilattice-unknown)
	(bilattice-unstash-val db)
	(take-1-more-arg #'t-fn-f #'unstash-value #'bilattice-bottom)
	(bilattice-print-fn db) #'t-print)
  (load-logic db)
  (remove-theory-tree)
  (activate *global*)
  (values))

;; The base bilattice is the second component of the currently active
;; bilattice.

(defun theory-base () (second (bilattice-components *active-bilattice*)))

;; Stashing and unstashing stuff.  The acess function is the bilattice
;; function accessor (stash or unstash) and the root-fn is the value to be
;; taken at the root.  For unstashing, it's bottom since we don't want to
;; affect values in theories other than the current one and we'll be doing
;; a bilattice-dot.  For stashing, we'll be doing a + so we use unknown
;; instead of bottom.

(defun t-fn-f (x access-fn root-fn &aux (b (theory-base)))
  (make-tv theory-dag b *active-theory* (funcall access-fn x b)
	   :root-fn root-fn))

;; printing -- just print the value at the active theory, as if you
;; were in the base bilattice

(defun t-print (x b stream &aux (base (second (bilattice-components b))))
  (format stream "~a" 
	  (mvl-print (get-val *active-theory* x) base)))

;; is the theory mechanism active?  Yes, if the current bilattice is of
;; type dag and its first component is called "theory dag"

(defun theory-active-p ()
  (and (eq (bilattice-type *active-bilattice*) 'dag)
       (equal (dag-short (car (bilattice-components *active-bilattice*)))
	      "Theory")))

;; what is in a given theory?  This can be done with contents; we have
;; to choose the propositions that actually have a value in the given
;; theory, and then when we display this truth value, we only display
;; the value in the given theory.

;; The keyword this-theory-only controls whether we want to display only
;; those props that take on *new* values at the given theory, or
;; everything that takes on *any* value at the given theory.

(defun theory-contents (&key (theory *active-theory*) (this-theory-only t)
			     (cutoffs *knowledge-test*) (props (props))
			     &aux (old *active-theory*))
  (unless (eq theory old) (activate theory))
  (contents :cutoffs *always-succeeds*
	    :props (props-to-display theory this-theory-only cutoffs props))
  (unless (eq theory old) (activate old))
  (values))

;; which props do we want to display?  First go through all the props,
;; saving only those that pass the cutoffs for the stated theory.  Then
;; if this-theory-only is t, remove all those that don't take new values
;; at the stated theory.

;; checking to see if a proposition passes a cutoff is rather tricky.
;; What we actually do is to take the cutoff supplied, and walk through
;; it, replacing all the bilattice values with values on the given
;; theory, essentially turning the cutoffs into a cutoff on the
;; base-bilattice.  Then when we look at a particular proposition, we
;; test its value in the relevant theory against the cutoffs, using the
;; base bilattice to do the comparison.

(defun props-to-display (theory this-theory-only cutoffs props
			 &aux (base (theory-base)))
  (setq cutoffs (mapcar #'(lambda (disj)
			    (mapcar #'(lambda (term) (theory-term theory term))
				    disj))
			cutoffs)
	props (remove-if-not
		#'(lambda (prop)
		    (test (get-val theory (truth-value prop))
			  cutoffs base))
		props))
  (when this-theory-only
    (setq props (remove-if-not
		  #'(lambda (prop)
		      (member theory (truth-value prop) :key #'car))
		  props))))

(defun theory-term (dag-elt term)
  (make-test :value (get-val dag-elt (test-value term)) :tag (test-tag term)))

;; erase a proposition from a theory.  It's pretty easy, except we have
;; to be careful of two things:
;;  1.  The "value" supplied is a value in the base bilattice, not the
;;  currently active bilattice.
;;  2.  The truth value of the proposition cannot be modified
;;  destructively, since it might be one of the special values true,
;;  false, etc.
;; The way we deal with this is to get the truth value, copy it, modify
;; the copied version destructively to include the given value in the
;; given theory, and then call erase.

(defun erase-from-theory (prop &key (theory *active-theory*)
				    (base (theory-base))
				    (value (unstash-value prop base))
				    decrement-p (cutoffs std-cutoffs))
  (erase prop :value (theory-value prop theory value) :decrement-p decrement-p
	 :cutoffs cutoffs))

(defun theory-value (prop theory value)
  (multiple-value-bind (pnum current-value) (indbp prop)
    (declare (ignore pnum))
    (setq current-value (copy-tree (or current-value unknown)))
    (add-dag theory value current-value)
    current-value))

;; state a proposition in a theory.  As in state (see rep.lisp), we get
;; the truth value by using the supplied value, if there is one, or by
;; applying the given function to the proposition.  If the function
;; isn't supplied either, we just use the default one on the base
;; bilattice.  Unless increment-p is T, we begin by removing the
;; proposition from the given theory (otherwise state would remove it
;; from *every* theory).

(defun state-in-theory (p &key (theory *active-theory*) (value nil hasv)
			       (increment-p t) function
			&aux (base (theory-base)))
  (unless increment-p (unstate-from-theory p :theory theory))
  (state p :value (make-tv theory-dag base theory
			   (if hasv value
			       (funcall (or function 
					    (bilattice-stash-val base)) p)))))

;; For unstate, there are two cases:
;;  1.  If decrement-p is NIL, then we just want to set the value in the
;;  given theory to the given value (or the result of applying the
;;  unstash function in the base bilattice).  We do this with add-dag,
;;  and call unstate to do the work.
;;  2.  If decrement-p is T, then we can get by calling unstate with a
;;  new dag-list that is bottom except at the given theory.

(defun unstate-from-theory (p &key (theory *active-theory*) (value nil hasv)
				   (decrement-p t) 
				   (function (bilattice-unstash-val
					      (theory-base)))
			    &aux (base (theory-base)))
  (setq value (if hasv value (funcall function p)))
  (if decrement-p
      (unstate p :value (make-tv theory-dag base theory value
				 :root-fn #'bilattice-bottom))
    (unstate p :value (theory-value p theory value) :decrement-p nil)))

;; empty a theory completely.  First we get a list of all propositions
;; that change truth value in the given theory; if the value they change
;; to isn't unknown, we remove them from the current theory by calling
;; unstate-from-theory.  This list of propositions is computed by
;; props-to-display, where we make this-theory-only t and pass the
;; cutoffs of k-not-le unknown (i.e., the knowledge test).

(defun empty-theory (&key (theory *active-theory*) (value nil hasv))
  (dolist (p (props-to-display theory t *knowledge-test* (props)))
    (if hasv (unstate-from-theory p :theory theory :value value)
      (unstate-from-theory p :theory theory))))

;;; -*- Mode: LISP; Syntax: Common-lisp; Package: MVL; Base: 10 -*-

(in-package "MVL")

#-ANSI (proclaim '(declaration dynamic-extent))

;; functions to produce bilattice of functions from a dag to a
;; bilattice; this is the hardest of all the constructions.  We begin by
;; setting up all of the machinery needed to define dags and functions
;; on them.

;; a dag is defined as a structure with the following fields:
;;  root	The root of the dag
;;  eq 		Tests for equality of two dag elements
;;  le		Checks to see if arg1 is below arg2 in the dag.  This
;;  		function is optional and will be computed if not
;;  		supplied.
;;  dot		Given two dag elements, returns a list of all their
;;  		glb's
;;  long short	Long and short descriptors
;;  inherit	This is a function that takes four arguments -- a bilattice,
;;		two elements of the dag, say d and e, and an element of the
;;		bilattice, say b.  If we have a function f with f(d)=b, then
;;		the result computed by the inherit function should be
;;		f(e).  inherit defaults to a function that ignores d and
;;		e and just returns b.
;;  vars	Returns the vars in a particular dag element.
;;  plug 	Plugging function for dag elements.
;;  select	Selection function for getting a value at a point below
;;  		multiple dag elements.

(defstruct (dag (:print-function print-dag))
  root						
  eq (leq nil) dot					
  long short					
  (inherit #'def-inherit-fn)
  (vars nil)
  (plug nil)
  (select #'default-select))

(defun print-dag (dag stream print-depth)
  (declare (ignore print-depth))
  (format stream "~a dag" (dag-short dag)))

(defun def-inherit-fn (bilat d e b)
  (declare (ignore bilat d e))
  b)

(defun default-select (child parents)
  (declare (ignore child))
  parents)

(defun dag-eql (dag d1 d2) (funcall (dag-eq dag) d1 d2))

;; an element d1 of a dag is le an element d2 if the car of d1.d2 is dag-eq
;; to d1.  (If there is a leq check associated to the dag, use that.)

(defun dag-le (dag d1 d2 &aux (temp (dag-leq dag)))
  (cond (temp (funcall temp d1 d2))
	((setq temp (funcall (dag-dot dag) d1 d2))
	 (dag-eql dag (car temp) d1))))

;; functions from dags to a bilattice are basically lists; each element on
;; the list is of the form (d . b) where d is a point of the dag and b is
;; the value taken there.  This list is maintained semisorted in the sense
;; that if (d1 . b1) precedes (d2 . b2), then it will never be the case that
;; d1<d2, so that d2 will never be closer to the root than d1 is.

;; Functions also have dag and bilattice slots, since these are always getting
;; passed around in any case.

;; Steve - Sept 11/91 for Matt Ginsberg err search
;;(defstruct (dag-fn (:print-function print-dag-fn))
;;  dag bilattice list)

(defstruct (dag-fn )
  dag bilattice list)

(defun print-dag-fn (f stream print-depth)
  (declare (ignore print-depth))
  (fn-print f (dag-fn-dag f) (dag-fn-bilattice f) stream))  


;; To make the following code more readable, we define some functions
;; to break apart these pairs:

(defmacro dag-pt (x) `(car ,x))
(defmacro dag-val (x) `(cdr ,x))
(defmacro dag-root-pt (x) `(caar ,x))
(defmacro dag-root-val (x) `(cdar ,x))

;; in the following code, we uniformly use d, d1, d2 etc for elements of the
;; dag.  We use b for an element of the initial bilattice, and f for a
;; function from the dag to the bilattice (i.e., an element of the constructed
;; bilattice).

;; functions defined:
;; 
;; get-val (d f)		returns value of f at dag point d
;; 
;; make-tv (dag bilattice d b &optional root-fn)
;; 				makes fn that has value (root-fn bilattice) at
;;				root and b at d
;; 
;; make-root (dag bilattice b)	makes fn that has value b at root
;; 
;; dag-change-tv (f fn &key simplify)
;; 				changes function f by applying bilattice
;;				function fn to each point.  If simplify is
;;				non-nil, simplifies the result.
;;
;; dag-change-dag (f fn &key (simplify t))
;;				like dag-change-tv, but fn is a function
;;				from the dag to itself
;;
;; dag-list-of-answers (f)	Returns a list of instances of the
;; 				answer structure, where the dag is
;; 				assumed to be that of binding lists
;;
;; dag-accumulate-fn (dag bilattice list)
;;				accepts a list of (dag-pt . value) pairs and
;;				constructs a dag function from them (this
;;				function does the partial sort and little more)
;; 
;; dag-prune (f pred &optional modify-fn)
;; 				prunes from f those entries not satisfying
;; 				predicate pred after application of modify-fn
;; 
;; combine-fns (f1 f2 fn comp)	combines functions f1 and f2 with
;; 				the function fn; the comparison function is
;;				used to see if you can simply return f1 or f2
;;				itself
;; 
;; add-dag (d b f)		given function f, add value b at dag element d
;; 
;; simplify (f)			removes multiple entries from dag-fn

;; given a truth value and a dag element, get the bilattice value.  We
;; find all of the "contributing points" with gv-1, reduce them using the
;; dag selection function, and then add them all up with mvl-plus.

(defun get-val (d f &aux (bilattice (dag-fn-bilattice f)) (dag (dag-fn-dag f)))
  (reduce (bilattice-plus bilattice)
	  (napcar #'(lambda (x)
		      (funcall (dag-inherit dag)
			       bilattice (dag-pt x) d (dag-val x)))
		  (gv-1 dag d (dag-fn-list f)))))

;; here we get the contributing points; actually we return a list of
;; (<contributing-point> . <number>) where <contributing-point> is
;; itself (<dag-pt> . <dag-val>) and <number> is the length of applying
;; plan-dag-dot to this dag-pt and the given one.  If this number goes
;; down, not *every* way in which d is an instance of some dag-pt extends
;; to a point lower down in the dag, and we don't want to use the new value.

;; This function also caters to the possibility that we only want to consider
;; points where the dag takes a value *above* the given one; this is needed
;; by the simplification stuff.

;; So here's the algorithm:  We work our way through the list of points
;; where f takes a value (this is what is actually passed to the gv-1 call).
;;  1.  If return-early? is t and the given point is eq to the terminating
;;      point, we just stop and return the computed answer, calling #'car
;;      everywhere to knock out the <number>s above and just return a
;;      list.
;;  2.  When the current dag-pt is above the given point d:
;;     a.  The first thing to do is to set temp to either the length of what
;;         dag-le returned (assumed to be correct) or to 1 if dag-le didn't
;;         return a list.
;;     b.  Now we set the list of points that are superseded by this one
;;         to NIL, and set a flag indicating that there's nothing wrong
;;         with this point to T.
;;     c.  We work through the list of points already collected.  For those
;;         that are above the one we're working on:
;;        c1.  If the length of the current le is >= the length of the dot
;;             at the old point, the old point is superseded.
;;        c2.  If the length is less than the old length, then this point is
;;             not going to be superseded and you are now suspicious about
;;             the usefulness of this point (ok-flag = NIL).
;;        c3.  At the end, we have to pull the superseded points out of ans
;;             and then push the new one on -- provided that either something
;;             was supereseded or the ok-flag is still T.

(defun gv-1 (dag d f &optional return-early? &aux ans temp superseded ok-flag)
  (declare (dynamic-extent superseded))
  (dolist (item f (napcar #'car ans))
    (cond ((and return-early? (eq (dag-pt item) d)) 
	   (return (napcar #'car ans)))
	  ((setq temp (dag-le dag d (dag-pt item)))
	   (setq temp (if (listp temp) (length temp) 1))
	   (setq superseded nil ok-flag t)
	   (dolist (x ans)
	     (when (dag-le dag (dag-pt item) (dag-pt (car x)))
	       (if (>= temp (cdr x))
		   (push x superseded)
		 (setq ok-flag nil))))
	   (when superseded (setq ans (nset-difference ans superseded)))
	   (when (or ok-flag superseded) (push (cons item temp) ans))))))

;; given a dag point and a bilattice point, make a function that is unknown
;; except below the dag point, where it takes the stated value.  There are
;; two cases:
;;  1.  If the stated value is the same as the value at the root would
;;  be anyway, it's easy.  This can happen either because the value is
;;  the root value, or because the dag element d is the root of the dag.
;;  2.  Otherwise, we have to construct a rest argument to give the
;;  value at the given point.

(defun make-tv (dag bilattice d b &key (root-fn #'bilattice-unknown)
		&aux (root-val (funcall root-fn bilattice)))
  (if (or (mvl-eq b root-val bilattice) (dag-eql dag d (dag-root dag)))
      (make-root dag bilattice b)
    (make-dag-fn :dag dag :bilattice bilattice
		 :list (list (cons (dag-root dag) root-val) (cons d b)))))

;; same as above, but we assume that the dag element is the root of the dag

(defun make-root (dag bilattice b)
  (make-dag-fn :dag dag :bilattice bilattice 
	       :list (list (cons (dag-root dag) b))))

;; given an f and a function from the underlying bilattice to itself,
;; apply the function to every entry in f.  This is really pretty easy;
;; we just apply dag-change-tv to each level of the given function,
;; simplifying as we go.  Note that this function is not destructive.

(defun dag-change-tv (f fn &key simplify)
  (setq f (copy-dag-fn f))
  (setf (dag-fn-list f)
    (mapcar #'(lambda (x) (cons (dag-pt x) (funcall fn (dag-val x)))) 
	    (dag-fn-list f)))
  (if simplify (simplify f) f))

;; same as dag-change-tv, but fn is from dag to dag.  This is done by
;; working through the dag-fn, applying fn to each dag point in it and
;; adding the information that the function takes the same value at the
;; new dag point.  The function is assumed to respect the partial order
;; on the dag in question.  It's complicated because it is possible that
;; a conflict arise because both a dag element and one of its children
;; are mapped to the same dag point by the function fn.  In this case,
;; the function modify decides what to do; the default is to use the
;; bilattice plus operation to add all of the contributions.  Finally,
;; the keyword inherit can be used to specify a modified inheritance
;; function if the new dag-fn should not be constructed using the
;; default one.

;; The basic work is done by dcd, which computes the answer in ans but
;; might not set up the root of the dag-list correctly.  Now:
;;  1.  If the root is correct after all, just return ans.
;;  2.  If the root is incorrect but the value is correct (i.e., unknown
;;  in the given bilattice), change the root.
;;  3.  If the root and value are both wrong, set up a new dag-list that
;;  gets them right.

(defun dag-change-dag (f fn &key (simplify t) modify bilattice-modify
		       &aux (dag (dag-fn-dag f))
			    (bilattice (dag-fn-bilattice f))
			    (ans (dcd f fn simplify
				      (or modify
					  (funcall (or bilattice-modify
						       #'bilattice-plus)
						   bilattice)))))
  (cond ((dag-eql dag (dag-root dag) (dag-root-pt (dag-fn-list ans))) ans)
	((mvl-unk (dag-root-val (dag-fn-list ans)) bilattice)
	 (setf (dag-root-pt (dag-fn-list ans)) (dag-root dag)) ans)
	(t (push (cons (dag-root dag) (bilattice-unknown bilattice))
		 (dag-fn-list ans))
	   ans)))

;; this is where we actually do the work.  Since the fn is assumed to
;; respect the dag partial order, we can just do it all a point at a
;; time, and then have to check that none of the children of the current
;; root node is the same as the root node itself.  If so, we use the
;; modification function to replace the old value as necessary.  We also
;; simplify the result if simplify is not NIL.

(defun dcd (f fn simplify modify 
	    &aux (dag (dag-fn-dag f)) (bilattice (dag-fn-bilattice f))
		 ans temp value found)
  (dolist (item (dag-fn-list f))
    (setq temp (funcall fn (dag-pt item))
	  value (funcall (dag-inherit dag) bilattice
			 (dag-pt item) temp (dag-val item))
	  found (assoc temp ans :test (dag-eq dag)))
    (if found (setf (dag-val found) (funcall modify value (dag-val found)))
      (push (cons temp value) ans)))
  (setq ans (make-dag-fn :dag dag :bilattice bilattice :list (nreverse ans)))
  (if simplify (simplify ans) ans))

;; Accumulate answers in a dag-list in a returned list, where the dag is
;; assumed to be the dag of binding lists.

(defun dag-list-of-answers (f)
  (mapcar #'(lambda (x) (make-answer :binding (dag-pt x) :value (dag-val x)))
	  (dag-fn-list f)))

;; Dag accumulation function.  Accepts dag, bilattice, list of dotted
;; (dag . bilattice) pairs.  There is also a modifier keyword that tells
;; you what to do if you are trying to overwrite a value that is already
;; specified.  (The default is just to use the new value.)  Just work
;; through the pairs one at a time, calling add-dag at each point.

(defun dag-accumulate-fn (dag bilattice list
			  &key (modifier #'return-first-arg)
			       (ans (make-root dag bilattice
					       (bilattice-unknown bilattice))))
  (dolist (item list (simplify ans))
    (add-dag (dag-pt item) (dag-val item) ans :modifier modifier
	     :simplify nil)))

(defun return-first-arg (new-val old-val)
  (declare (ignore old-val))
  new-val)

;; same as dag-change-tv, but prune answers based on some predicate.
;; Just call dag-change-tv, where the funtion either does nothing
;; (although it can be changed with the modify-fn keyword) or, if the
;; result of applying the modify-fn satisfies the predicate, is unknown.
;; Anything that fails to satisfy the predicate is pruned.

(defun dag-prune (f pred &key (modify-fn #'identity)
		  &aux (bilattice (dag-fn-bilattice f))
		       (u (bilattice-unknown bilattice)))
  (dag-change-tv f #'(lambda (x &aux (temp (funcall modify-fn x)))
		       (if (funcall pred temp) temp u))
		 :simplify t))

;; remove from a dag-list any point satisfying a certain predicate; the
;; predicate defaults to the unknown on the given bilattice.

(defun dag-remove-unknown (f &aux flag (ans (copy-dag-fn f))
				  (bilattice (dag-fn-bilattice f)))
  (setf (dag-fn-list ans)
    (or (remove-if #'(lambda (x) (if (mvl-unk x bilattice) (setq flag t)))
		   (dag-fn-list f) :key #'cdr)
	(list (cons (dag-root (dag-fn-dag f)) (bilattice-unknown bilattice)))))
  (if flag (simplify ans) ans))

;; given two truth values and a function to apply to the truth values,
;; combine the functions.  If a comparison test is passed, then we can
;; simply return one value or the other (if (comp f1 f2), then return
;; f1).  Otherwise, call combine-1 to do the actual work.

(defun combine-fns (f1 f2 fn comp)
  (cond ((fn-comp f1 f2 comp t) f1)
	((fn-comp f2 f1 comp t) f2)
	(t (combine-1 fn nil f1 f2))))

;; Here's where we actually do the work.  We might be able to do it cheaply;
;; that's what combine-quick is about.  If not, we produce a list of points
;; where we have to compute a value -- basically the result of dotting every
;; point where any di takes a value.  Then we do a bunch of get-vals to do
;; all the computation.

;; There is also a need to handle parametric arguments.  The argument
;; parameter-info to combine-1 should have T in the position of any
;; parametric argument (like the parameters slot of a modal operator).
;; The first thing we do is split the given args (the fx) into
;; parameters and real functional arguments.  Then we only call
;; combine-2 with the real functions.  Before actually applying the
;; function, we splice the parametric arguments back into the list.

(defun combine-1 (fn parameter-info &rest fx
		  &aux dot eq dag parameters functions (p-info parameter-info))
  (dolist (fn fx) (if (pop p-info) (push fn parameters) (push fn functions)))
  (setq parameters (nreverse parameters))
  (cond ((combine-quick fn parameters parameter-info functions))
	(t (setq dag (dag-fn-dag (car functions))
		 dot (dag-dot dag) eq (dag-eq dag)
		 functions (nreverse functions))
	   (dag-accumulate-fn 
	    (dag-fn-dag (car functions)) (dag-fn-bilattice (car functions))
	    (napcar #'(lambda (d)
			(cons d (apply fn (splice-parameters
					   parameters 
					   (mapcar #'(lambda (f) (get-val d f))
						   functions)
					   parameter-info))))
		    (reduce #'(lambda (list f) (combine-2 dot eq list f))
			    (cdr functions)
			    :initial-value
			    (mapcar #'car (dag-fn-list (car functions)))))))))

;; Here we put the parametric arguments back into the list.  params is a
;; non-reversed list of parameters and args is a non-reversed list of
;; arguments.  Info is the usual list of T if parameter or NIL if not.

;; If params is NIL, it's easy.  Otherwise, we just walk down info,
;; pushing the args onto the eventual answer unless it's a parameter, in
;; which case we grab a parameter and use that.  Then when we run out of
;; information, we reverse the accumulated list and stick it onto
;; whatever args are still left.  (nreconc does just this)

(defun splice-parameters (params args info)
  (if params
      (let (ans)
	(dolist (item info (nreconc ans args))
	  (push (if item (pop params) (pop args)) ans)))
    args))

;; combine-quick handles the case where at most one of the f's has a
;; non-NIL rest arg.  In this particular case, we can actually use
;; dag-change-value to do all of the work!  Note that fx is reversed
;; when we get it, and would normally be reversed again by combine-2.

;; fx is the list of functions to be combined.  flag is used to find
;; the f that has a non-NIL rest arg (if any); before is a list of the
;; functions preceding flag and after is a list of those following it.
;; If flag is NIL at the end (no rest args at all), then everything
;; is in before.

;; At the end, we splice the parameters back in and invoke either
;; dag-change-tv or simply do it.

(defun combine-quick (fn parameters param-info fx &aux flag before after)
  (dolist (f fx)
    (cond ((cdr (dag-fn-list f))
	   (if flag (return-from combine-quick nil) (setq flag f)))
	  (flag (push (cdar (dag-fn-list f)) after))
	  (t (push (cdar (dag-fn-list f)) before))))
  (cond (flag
	 (push nil after)		;placeholder for argument
	 (setq before (nconc before after))
	 (dag-change-tv flag #'(lambda (x)
				 (setf (car after) x)
				 (apply fn (splice-parameters 
					    parameters before param-info)))
			:simplify t))
	 (t (make-root (dag-fn-dag (car fx))
		       (dag-fn-bilattice (car fx))
		       (apply fn (splice-parameters parameters before
						    param-info))))))

;; combine-2 takes as arguments a dag dot function, a partial list, and
;; a new dag function.  We build up a list of any dag point in d1.d2 for
;; any d1 on the partial list and d2 where the new dag function takes a
;; value.  If the new "dag function" is actually just a parameter, we just
;; return the original list.

(defun combine-2 (dot eq list f &aux result)
  (dolist (new-pt (mapcar #'car (dag-fn-list f))
	    (delete-duplicates result :test eq))
    (dolist (old-pt list)
      (pushconc (funcall dot new-pt old-pt) result))))

;; given a function, add a value at a point.  This function works by
;; side effect *only* -- nothing useful is returned.  The keyword
;; modifier is used to decide what to do if a value is already present
;; at the given point; simplify is used to simplify the result if
;; needed.  We walk down the list looking for any of the following
;; conditions:
;;  0.  If this is the same as the current value, we do nothing if
;;  simplify is t.  (If nil, we might be recording this explicitly for later.)
;;  1.  If d is equal to the root point of the given entry, we modify the cdr
;;  as appropriate and simplify at that point.
;;  2.  If d is > the car of the given entry, we splice the given point
;;  in right before this one.
;;  3.  If there are no more entries, we put the given point on the end of
;;  the list.
;; To make it possible to do this destructively, we actually maintain
;; a pointer that trails the "actual" pointer by one cons.  That means
;; we have to treat the car of the whole dag-list specially, but it's ok
;; because case (2) is impossible at that point.

(defun add-dag (d b f &key (modifier #'return-first-arg) (simplify t)
		&aux (dag (dag-fn-dag f)) (bilattice (dag-fn-bilattice f))
		     (list (dag-fn-list f)))
  (cond ((and simplify (mvl-eq b (get-val d f) bilattice)))
	((dag-eql dag d (dag-root-pt list))
	 (setf (dag-root-val list) (funcall modifier b (dag-root-val list)))
	 (when simplify (simplify-at-point dag bilattice list list)))
	(t (do ((items list (cdr items)))
	       ((null (cdr items))
		(push (cons d b) (cdr items)))
	     (cond ((dag-eql dag d (dag-root-pt (cdr items)))
		    (setf (dag-root-val (cdr items))
		      (funcall modifier b (dag-root-val (cdr items))))
		    (when simplify
		      (simplify-at-point dag bilattice (cdr items) list))
		    (return))
		   ((dag-le dag (dag-root-pt (cdr items)) d)
		    (push (cons d b) (cdr items))
		    (when simplify
		      (simplify-at-point dag bilattice (cdr items) list))
		    (return)))))))

;; to simplify all points of a dag-list, invoke simplify-at-point at each
;; one of them

(defun simplify (f &aux (dag (dag-fn-dag f)) (bilattice (dag-fn-bilattice f))
			(list (dag-fn-list f)))
  (do ((items list (cdr items)))
      ((null (cdr items)) (setf (dag-fn-list f) list) f)
    (simplify-at-point dag bilattice items list)))

;; simplifying at a point is a little harder.  It's basically like get-val --
;; if the value sent down to this point is the same as it currently has, we
;; can drop it.  But if we just do a get-val, we'll *obviously* get the same
;; value!  So we define get-early-val, which does a get-val using stuff before
;; the given point is encountered only.

(defun simplify-at-point (dag bilattice piece orig
			  &aux (inh (dag-inherit dag)))
  (setf (cdr piece)
    (delete-if #'(lambda (x)
		   (and (dag-le dag (dag-pt x) (dag-root-pt piece))
			(mvl-eq (funcall inh bilattice (dag-root-pt piece)
					 (dag-pt x) (dag-root-val piece))
				(dag-val x)
				bilattice)
			(mvl-eq (dag-val x) 
				(get-early-val bilattice dag (dag-pt x) orig)
				bilattice)))
	       (cdr piece))))

(defun get-early-val (bilattice dag d f)
  (reduce (bilattice-plus bilattice)
	  (napcar #'(lambda (x) 
		      (funcall (dag-inherit dag)
			       bilattice (dag-pt x) d (dag-val x)))
		  (gv-1 dag d f t))))

;; Here are the functions that correspond to distinguished elements of
;; a given bilattice.

(defun fn-true (dag bilattice)
  (make-root dag bilattice (bilattice-true bilattice)))

(defun fn-false (dag bilattice)
  (make-root dag bilattice (bilattice-false bilattice)))

(defun fn-bottom (dag bilattice) 
  (make-root dag bilattice (bilattice-bottom bilattice)))

(defun fn-unknown (dag bilattice)
  (make-root dag bilattice (bilattice-unknown bilattice)))

;; And here are the operators corresponding to and, or, etc.  Each of
;; these is constructed using combine-fns, where we supply the
;; comparison functions to make things go quickly if possible.

(defun fn-and (f1 f2)
  (combine-fns f1 f2 (bilattice-and (dag-fn-bilattice f1)) #'t-le))

(defun fn-or (f1 f2)
  (combine-fns f1 f2 (bilattice-or (dag-fn-bilattice f1)) #'t-ge))

(defun fn-plus (f1 f2)
  (combine-fns f1 f2 (bilattice-plus (dag-fn-bilattice f1)) #'k-ge))

(defun fn-dot (f1 f2)
  (combine-fns f1 f2 (bilattice-dot (dag-fn-bilattice f1)) #'k-le))

(defun fn-dws (f1 f2 dag bilat)
  (combine-1 dag bilat (bilattice-dws bilat) nil f1 f2))

;; negation is simpler -- we just change the truth values by negating
;; all of them!

(defun fn-not (f1)
  (dag-change-tv f1 (bilattice-not (dag-fn-bilattice f1))))

;; checking for functional equality is rather harder.  fn-eq1 is what
;; does the work; it just has the equality function on the bilattice
;; already identified.

(defun fn-eq (f1 f2 &aux (dag (dag-fn-dag f1)) (bilat (dag-fn-bilattice f1)))
  (or (eq f1 f2) 
      (and (= (length (setq f1 (dag-fn-list f1)))
	      (length (setq f2 (dag-fn-list f2))))
	   (subsetp f1 f2
		    :test #'(lambda (x y)
			      (and (dag-eql dag (dag-pt x) (dag-pt y))
				   (mvl-eq (dag-val x) (dag-val y) bilat)))))))

;; It turns out the most of the time is actually spent in the comparison
;; function (which returns t more often than not).  So this really has
;; to hum.  The special cases where either or both rest args are NIL is
;; pretty easy, since we can just compare all the values taken by the
;; other function.  That's handled by fnc-n1 (f1 has NIL rest arg) or
;; fnc-n2 (f2 has NIL rest arg) or, if both rest args are NIL, just
;; compare the values!  fnc-1 handles the case where neither rest arg
;; is NIL, and is only called if quick is non-NIL.

(defun fn-comp (f1 f2 fn &optional quick
		&aux (r1 (cdr (dag-fn-list f1))) (r2 (cdr (dag-fn-list f2))))
  (cond ((eq f1 f2))
	((and r1 r2) (unless quick (fnc-1 fn f1 f2)))
	(r2 (fnc-n1 (dag-root-val (dag-fn-list f1)) f2 fn))
	(r1 (fnc-n2 f1 (dag-root-val (dag-fn-list f2)) fn))
	(t (funcall fn (dag-root-val (dag-fn-list f1))
		    (dag-root-val (dag-fn-list f2))
		    (dag-fn-bilattice f1)))))

;; If f1 has NIL rest arg, just make sure that the root passes the test
;; (don't forget to apply the inheritance function!), and then that all
;; the kids do.  fnc-n2 is similar.

(defun fnc-n1 (val f2 fn &aux (dag (dag-fn-dag f2))
			      (bilat (dag-fn-bilattice f2))
			      (inh (dag-inherit dag)) (root (dag-root dag)))
  (every #'(lambda (x) (funcall fn (funcall inh bilat root (dag-pt x) val)
				(dag-val x) bilat))
	 (dag-fn-list f2)))

(defun fnc-n2 (f1 val fn)
  (fnc-n1 val f1 #'(lambda (x y b) (funcall fn y x b))))

;; Here's the general case, which is much like combine-1.

(defun fnc-1 (fn f1 f2 &aux (dag (dag-fn-dag f1))
			    (bilattice (dag-fn-bilattice f1))
			    (dot (dag-dot dag)) (eq (dag-eq dag)) checked)
  (dolist (item1 (dag-fn-list f1) t)
    (dolist (item2 (dag-fn-list f2))
      (dolist (dag-elt (funcall dot (dag-pt item1) (dag-pt item2)))
	(unless (member dag-elt checked :test eq)
	  (if (funcall fn (get-val dag-elt f1) (get-val dag-elt f2) bilattice)
	      (push dag-elt checked)
	    (return-from fnc-1 nil)))))))

;; default stash and unstash just take the usual value, at the root of
;; the dag

(defun fn-stash-value (p dag bilattice)
  (make-root dag bilattice (stash-value p bilattice)))

(defun fn-unstash-value (p dag bilattice)
  (make-root dag bilattice (unstash-value p bilattice)))

;; Here's where we actually construct the new bilattice.

;; 1.  True, false, etc are as already defined above.  cutoff-val is
;; also pretty easy.

;; 2.  The bilattice functions have already been defined above, by and
;; large.  fn-simp is defined below, and fn-comp is used for the comparison
;; functions.

;; 3.  The modal operators are computed by f-modal-ops.

;; 4.  The long and short descriptions describe the bilattice as the set
;; of functions from the dag to the original bilattice.  The
;; one-character identifier is "e" (for "exponentiation") if available.

;; 5.  The type is "dag" and the components are the dag and the
;; bilattice.

;; In this case, we need to have the complete bilattice available (or at
;; least a pointer to it) before constructing the plugging functions, so we
;; delay them to the end.

(defun dag-bilattice (dag bilattice &aux b)
  (setq b
    (make-bilattice :true (fn-true dag bilattice)
		    :false (fn-false dag bilattice)
		    :unknown (fn-unknown dag bilattice)
		    :bottom (fn-bottom dag bilattice)
		    :cutoff-val (make-root dag bilattice
					   (bilattice-cutoff-val bilattice))
		    :stash-val (take-1-more-arg #'fn-stash-value dag bilattice)
		    :unstash-val (take-1-more-arg
				  #'fn-unstash-value dag bilattice)
		    :plus #'fn-plus :dot #'fn-dot :and #'fn-and :or #'fn-or
		    :not #'fn-not :eq #'fn-eq
		    :kle (take-2-more-args #'fn-comp #'k-le)
		    :tle (take-2-more-args #'fn-comp #'t-le)
		    :dws (take-2-more-args #'fn-dws dag bilattice)
		    :simplicity #'fn-simp
		    :vars (dag-vrs dag bilattice)
		    :plug (dag-plg dag bilattice)
		    :absorb (dag-absorb dag bilattice)
		    :modal-ops (f-modal-ops bilattice)
		    :long-desc (format nil "Functions from ~a dag into ~a."
				       (dot-trim (dag-long dag))
				       (dot-trim
					(bilattice-long-desc bilattice)))
		    :short-desc (format nil "~a dag -> ~a" (dag-short dag)
					(bilattice-short-desc bilattice))
		    :char (bilattice-find-char #\e)
		    :type 'dag :components (list dag bilattice)))
  (make-standard-modal-ops b)
  b)

;; the simplicity of a dag-list is the smallest simplicity attained by any
;; element it contains.

(defun fn-simp (f)
  (reduce #'simplicity-min
	  (napcar (bilattice-simplicity (dag-fn-bilattice f))
		  (mapcar #'cdr (dag-fn-list f)))))

;; The vars in a dag-list are those appearing in any bilattice or dag element

(defun dag-vrs (dag bilattice &aux (d-fn (dag-vars dag)) 
				   (b-fn (bilattice-vars bilattice)))
  (cond ((and b-fn d-fn) #'fn-vars)
	(b-fn #'fn-bvars)
	(d-fn #'fn-dvars)))

(defun fn-vars (f &aux (dag (dag-fn-dag f)) (bilattice (dag-fn-bilattice f)))
  (delete-duplicates
   (mapcan #'(lambda (x) (nconc (funcall (dag-vars dag) (dag-pt x))
				(mvl-vars (dag-val x) bilattice)))
	   (dag-fn-list f))))

(defun fn-bvars (f &aux (bilattice (dag-fn-bilattice f)))
  (delete-duplicates
   (mapcan #'(lambda (x) (mvl-vars (dag-val x) bilattice)) (dag-fn-list f))))

(defun fn-dvars (f &aux (dag (dag-fn-dag f)))
  (delete-duplicates
   (mapcan #'(lambda (x) (funcall (dag-vars dag) (dag-pt x))) 
	   (dag-fn-list f))))

;; plugging function.  There are four cases, depending upon which of
;; d-fn and b-fn are NIL.

(defun dag-plg (dag bilattice 
		&aux (d-fn (dag-plug dag)) (b-fn (bilattice-plug bilattice)))
  (cond ((and b-fn d-fn) #'db-fn-vf-p)
	(b-fn #'db-fn-vf-pb)
	(d-fn #'db-fn-vf-pd)))

;; case where bilattice is default and dag isn't

(defun db-fn-vf-pd (val bdg &aux (d-fn (dag-plug (dag-fn-dag val))))
  (dag-change-dag val #'(lambda (a) (funcall d-fn a bdg))))

;; case where dag is default and bilattice isn't

(defun db-fn-vf-pb (val bdg 
		    &aux (b-fn (bilattice-plug (dag-fn-bilattice val))))
  (dag-change-tv val #'(lambda (a) (funcall b-fn a bdg))))

;; neither is

(defun db-fn-vf-p (val bdg)
  (db-fn-vf-pd (db-fn-vf-pb val bdg) bdg))

;; absorption.  This code doesn't handle the case when the bilattice
;; itself has a nontrivial absorption function, just when plugging does
;; something interesting.  This is a bug, but the code would be awful and
;; there are no relevant instances yet.

(defun dag-absorb (dag bilattice)
  (declare (ignore bilattice))
  (when (dag-plug dag) #'db-absorb))

;; Here's where we actually do the work.  As we work through the points
;; where the new value takes a value, we set them to unknown in the old
;; value and also set inc up to take the value bottom there.  Then we dot
;; inc with the new value and add it into the old value.  *** Something
;; to try later: can we replace inc with a bilattice-plug and a plus? ***

(defun db-absorb (old-val bdg new-val
		  &aux (dag (dag-fn-dag old-val)) 
		       (bilattice (dag-fn-bilattice old-val))
		       plugged-dag-elt
		       (bottom (bilattice-bottom bilattice))
		       (unknown (bilattice-unknown bilattice))
		       (inc (make-root dag bilattice unknown)))
  (setf (dag-fn-list old-val) (copy-tree (dag-fn-list old-val)))
  (dolist (dag-elt (mapcar #'car (dag-fn-list old-val)))
    (unless (dag-eql dag (setq plugged-dag-elt (plug dag-elt bdg)) dag-elt)
      (add-dag plugged-dag-elt unknown old-val)
      (setq inc (fn-plus inc (make-tv dag bilattice plugged-dag-elt bottom)))))
 (fn-plus old-val (fn-dot inc new-val)))

;; modal operators on functional bilattice.  Just copy over the modal
;; operators on the base bilattice, applying the modal operator function
;; to each point of a dag-list.

(defun f-modal-ops (bilattice)
  (mapcar #'(lambda (x)
	      (make-modal-operator
		:name (modal-operator-name x)
		:function (take-n-more-args #'f-modal-fn x)
		:parameters (modal-operator-parameters x)))
	  (nonstandard-modal-ops bilattice)))

;; modal operators are simple because combine-1 takes any number of
;; arguments.

(defun f-modal-fn (args op)
  (apply #'combine-1 (modal-operator-function op)
	 (modal-operator-parameters op) args))

;; printing is actually interesting in this case.  The cases that are
;; handled specially are the following:
;;  1.  value at root only
;;  2.  unknown at root and one other value
;; In other cases, we just print a formatted list of the answers.

(defun fn-print (x dag bilattice stream &aux (*print-pretty* t))
  (cond ((not (cdr (setq x (dag-fn-list x))))
	 (format stream "~a" (mvl-print (dag-root-val x) bilattice)))
	((and (mvl-unk (dag-root-val x) bilattice)
	      (null (cddr x)))
	 (format stream #-ANSI "Dag-fn with value ~a at instances of ~a"
		 #+ANSI
		 "~@<~1IDag-fn with value~:_ ~a~:_ at instances of~:_ ~a~:>"
		 (mvl-print (dag-val (second x)) bilattice)
		 (dag-pt (second x))))
	(t #-ANSI (progn dag (fn-print-1-old x bilattice stream))
	   #+ANSI (fn-print-1 x bilattice dag stream))))
					;progn dag to avoid compiler warning

(defun fn-print-1-old (x b s)
  (format s "Dag-fn with values ~a"
	  (mapc #'(lambda (x) (rplacd x (mvl-print (cdr x) b)))
		(copy-tree x))))

;; pretty printing.  Similar but with indentation to indicate what's under
;; what.

(defun fn-print-1 (x b d s)
  (format s "~@<Dag-fn with values:~{~VI~:@_~<~a ->~4I ~:_~a~:>~^~}~:>"
	  (fpl-1 x b d 2)))

(defun fpl-1 (x b d ind)
  (list* ind (list (dag-root-pt x) (mvl-print (dag-root-val x) b))
	 (mapcan #'(lambda (z) (fpl-1 (member z x) b d (+ 2 ind)))
		 (dag-succ x d))))

(defun dag-succ (x d &aux ans)
  (dolist (item (cdr x) ans)
    (when (and (dag-le d (dag-pt item) (dag-root-pt x))
	       (not (some #'(lambda (y) (dag-le d (dag-pt item) (dag-pt y)))
			  ans)))
      (push item ans))))

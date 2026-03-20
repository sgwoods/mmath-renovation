;; -*- Mode: LISP; Syntax: Common-lisp; Package: MVL; Base: 10 -*-

(in-package "MVL")

;; functions defined:
;;
;; props		a list of all propositions in the database
;; 
;; empty		unstash every proposition in the database
;; 
;; contents (&key cutoffs)	returns propositions and truth values
;; 			for every proposition whose truth value
;; 			satisfies cutoffs
;; 
;; show-list (l)	display (denotes p) for each proposition in l
;; 
;; prfacts (atom &key cutoffs)	print all facts involving given atom
;; 
;; stash (p &key value increment-p allow-procedural-attachment)
;; 			add p to the database with given truth value.
;; 			If increment-p is non-nil (the default), add given
;;			value to existing truth value for p.  If increment-p
;;			is nil, replace existing value.  Remaining keyword
;;			determines whether or not procedural attachment
;; 			to the stash is honored.
;; 
;; unstash (p &key value decrement-p allow-procedural-attachment)
;; 			just like stash
;;
;; unstash-facts-with-atom (atom &key value decrement-p
;;				       allow-procedural-attachment)
;;			like unstash, but for all facts involving a
;;			given atom
;; 
;; new-val (dat v)	truth value assigned to datum d should be v
;; 
;; indbp (p &key cutoffs)	is p in the database?  Looks for exact match
;; 
;; state (p &key value increment-p)
;; 			add p to database after converting to normal form
;; 
;; unstate (p &key value decrement-p)
;; 
;; mvl-load (f)		states facts in file f
;; mvl-unload (f)	unstates facts in file f
;; mvl-save (f)		writes facts in MVL database out to file f

(defvar *knowledge-test*)

;; get a list of all facts in the database.  Just do a lookup on (?*)
;; (which matches anything), and remove any sentences that have truth
;; value NIL.  (These sentences may appear as remnants of invoking
;; index-with-negation.)

(defun props ()
  (delete nil (napcar #'car (lookp '(?*))) :key #'truth-value))

;; clear the MVL database.  Basically, call unstash on every symbol in
;; the database.  If the value is unknown, however, we can do better --
;; we wipe out the property list of every database atom, and reset the
;; entire discrimination net.

(defun empty (&key (value unknown))
  (cond ((mvl-unk value)
	 (dolist (p (props))
	   (setf (symbol-plist p) nil))
	 (dinit))
	(t (dolist (p (props))
	     (unstash (denotes p) :value value))))
  'done)

;; display the contents of the MVL database.  Accepts two keywords:
;;  cutoffs 	a test that the truth value must satisfy if the
;;  		proposition is to be displayed
;;  props	a list of the propositions that *might* be displayed

(defun contents (&key (cutoffs *knowledge-test*) (props (props)))
  (show-list props cutoffs))

;; this actually does the work.  For each proposition, if the truth
;; value passes the cutoff test, then write out the proposition number,
;; the pattern and the (possibly modified) truth value.  The use of ~a
;; in the format statement ensures that the #: does not appear in any
;; database variables.

(defun show-list (l cutoffs)
  (dolist (prop l (values))
    (if (test (truth-value prop) cutoffs)
	(format t "~%~a : ~a has truth value~<~%~:; ~a~>"
		prop (denotes prop) (mvl-print (truth-value prop))))))

;; display the facts including a given atom.  Just like contents, but
;; has an optional stream argument and finds the propositions using
;; facts-with-atom.

(defun prfacts (atom &key (cutoffs *knowledge-test*))
  (show-list (facts-with-atom atom) cutoffs))

;; what facts involve a given atom?  just prune (props) if the
;; denotation doesn't involve the atom.

(defun facts-with-atom (atom)
  (remove-if-not #'(lambda (x) (tree-member atom (denotes x))) (props)))

;; does a sentence include an atom?  If it is a list, then it does if
;; the atom is a member of the list, or a member of an element of the
;; list.

(defun tree-member (atom tree)
  (when (and tree (listp tree))
    (or (member atom tree)
	(some #'(lambda (branch) (tree-member atom branch)) tree))))

;; insert a fact into the database.  Three keywords:
;;  value	truth value to be used
;;  increment-p	if t, add new value to existing one.  if NIL, overwrite
;;  		any existing value
;;  allow-procedural-attachment		if there is a procedural
;;  		attachment for the stashing operation for this atom
;;  		(i.e., there is a function on its stash property),
;;  		are we allowed to use it?
;; stash works as follows:
;;  1.  If procedural attachment is allowed and there is a procedural
;;  attachment present, just invoke that function on p with the given
;;  keyword values.
;;  2.  If the sentence is of the form (not p), stash p after negating
;;  the truth value.  The other keywords are unchanged.
;;  3.  If increment-p is T, increment the truth value.
;;  4.  If increment-p is NIL, call index to get the datum number for
;;  this proposition and then store the new value.

(defun stash (p &key (value (stash-value p)) (increment-p t)
	      (allow-procedural-attachment t) &aux dat)
  (cond ((and allow-procedural-attachment (get-mvl (car p) 'stash))
	 (invoke (get-mvl (car p) 'stash) p :value value
		 :increment-p increment-p))
	((eq (car p) 'not)
	 (stash (second p) :value (mvl-not value) :increment-p increment-p
		:allow-procedural-attachment allow-procedural-attachment))
	(increment-p (increment p value))
	(t (setq dat (index p))
	   (new-val dat value))))

;; unstash is just like stash, except that in the last case (decrement-p
;; is NIL), we only write out the new value if the sentence already
;; appears in the database.

(defun unstash (p &key (value (unstash-value p)) (decrement-p t)
		(allow-procedural-attachment t) &aux dat)
  (cond ((and allow-procedural-attachment (get-mvl (car p) 'unstash))
	 (invoke (get-mvl (car p) 'unstash) p :value value
		 :decrement-p decrement-p))
	((eq (car p) 'not)
	 (unstash (second p) :value (mvl-not value) :decrement-p decrement-p
		  :allow-procedural-attachment allow-procedural-attachment))
	(decrement-p (decrement p value))
	((setq dat (indexp p))
	 (new-val dat value))))

;; unstash-facts-with-atom just invokes unstash on each fact that
;; involves the given atom

(defun unstash-facts-with-atom (atom &key (value unknown) (decrement-p t)
				(allow-procedural-attachment t))
  (mapc #'(lambda (x) (unstash (denotes x) :value value
			       :decrement-p decrement-p
			       :allow-procedural-attachment
			       allow-procedural-attachment))
	(facts-with-atom atom)))

;; increment the truth value of p by value.  If p is in the database
;; with value old-val, set the new value to be (old-val + value).
;; Otherwise, just set the new value to value.

(defun increment (p value &aux (dat (index p)))
  (new-val dat (mvl-plus (truth-value dat) value)))

;; decrement the truth value of p by value.  If p is in the database
;; with value old-val, set the new value to be (old-val . -value).
;; Otherwise, just set the new value to unknown.

(defun decrement (p value &aux (dat (index p)))
  (new-val dat (mvl-dot value (mvl-not value))))

;; set the truth value of a particular sentence (described as the atom
;; that denotes it) to a given value v.  If v is unknown, then remove
;; the datum's truth-value property and remove it from the
;; discrimination net.  Otherwise, just set its truth-value property to
;; the given value.  Note that we don't have to use get-mvl and rem-mvl
;; here; different invocations of mvl should use different atomic
;; proposition names, since they are generated by incrementing
;; *maksym-alist* and this variable is shared by multiple invocations of
;; mvl.

(defun new-val (dat v)
  (cond ((mvl-unk v)
	 (remprop dat 'truth-value)
	 (unindex dat))
	(t (setf (get dat 'truth-value) (stash-adjust-value v dat)) dat)))

;; Because the variables in the database proposition are standardized
;; away from the ones supplied by the user, we may have to adjust the 
;; truth value because the variables in the propostion have been renamed.
;; stash-adjust-value does that; the args are the truth value, the datum
;; and the original proposition.  Here's what we need to do:
;;
;; 1.  Any vars already in the proposition should be replaced
;; in the truth value.

;; 2.  Any other vars in the truth value need to be standardized, and
;; a list of all such needs to be maintained.  Before doing the
;; standardization, we remove any vars that have already been
;; standardized.

(defun stash-adjust-value (value dat)
  (declare (special *active-bilattice*))
  (cond ((bilattice-plug *active-bilattice*)
	 (setq value (mvl-plug value (get dat 'bdgs)))
	 (let (bdglist)
	   (declare (special bdglist))
	   (cond ((standardize-variables1 
		   (delete-if #'database-variable (mvl-vars value)))
		  (mapc #'(lambda (x) 
			    (if (varp* (car x)) (rplacd x (list (cdr x)))))
			bdglist)
		  (setf (get dat 'bdgs)
		    (append-binding-lists bdglist (get dat 'bdgs))
		    (get dat 'vars-in)
		    (mapcar #'(lambda (x)
				(if (listp (cdr x)) (cadr x) (cdr x)))
			    (get dat 'bdgs)))
		  (mvl-plug value bdglist))
		 (t value))))
	(t value)))

;; Is p in the database?  If it is of the form (not q), then look for q.
;; Otherwise, just look for it with indexp and return the datum used and
;; the truth value found.

(defun indbp (p)
  (cond ((eq (car p) 'not)
	 (multiple-value-bind (d v) (indbp (second p))
	   (if d (values d (mvl-not v)))))
	((setq p (indexp p))
	 (values p (truth-value p)))))

;; put a new sentence into the database after converting it to normal
;; form.  If value is supplied, use that.  If function is supplied,
;; apply the function to the normal form of the proposition.  If neither
;; is supplied, apply stash-value to the normal form of the proposition.

;; When it comes to actually inserting the proposition into the
;; database, the value v satisfies v = (v /\ u) + (v \/ u), where the
;; first term is t-le u and corresponds to the value to be assigned to
;; -p and the second is the value to be assigned to p.  The reason we
;; have to draw the distinction is that if p is a rule of inference or
;; some such, the normal form of -p may be very different than the
;; normal form of p and we will need to stash the normal form of -p with
;; the corresponding truth value.  In any event, we return a list of the
;; propositions that have had their truth values affected.

(defun state (p &key (value nil hasv) (increment-p t) function
	      &aux (np (normal-form p)))
  (setq value (if hasv value (funcall (or function #'stash-value)
				      (conj-to-logic np))))
  (cond ((t-gt value unknown) (state-1 np value increment-p))
	((t-lt value unknown)
	 (state-1 (normal-form (negate p)) (mvl-not value) increment-p))
	((not (and increment-p (mvl-unk value)))
	 (nunion (state-1 np value increment-p)
		 (state-1 (normal-form (negate p)) (mvl-not value)
			  increment-p)))))

;; this is the primitive used by state.  It inserts a normal-form
;; sentence into the database with the given value and increment-p flag.
;; Recall that normal-form actually returns a *list* of sentences, so we
;; have to stash each one.

(defun state-1 (normal-form value increment-p)
  (mapcar #'(lambda (x) (stash x :value value :increment-p increment-p))
	  normal-form))

;; unstate is like state but a bit simpler -- we don't have to worry
;; about the form of the value and so on.  We simply unstate the
;; sentence.

(defun unstate (p &key (value nil hasv) (decrement-p t) function
		&aux (np (normal-form p)))
  (setq value (if hasv value (funcall (or function #'unstash-value)
				      (conj-to-logic np))))
  (mapcar #'(lambda (x) (unstash x :value value :decrement-p decrement-p))
	  np))

;; load the facts in a .MVL file.  The optional empty keyword indicates
;; that the theory should be emptied first.  The truth value used can
;; depend on a "value" or "function" that is established by keywords in
;; the file and then passed to state; hence the presence of the value
;; and function auxiliary variables in mvl-load.  The recognized
;; keywords are:
;;  :value	set value to the given value and function to NIL
;;  :function	set function to the given value and value to NIL
;;  :empty	empty the MVL database

(defun mvl-load (f &key empty &aux value function)
  (if empty (empty))
  (with-open-file (s (mvl-file f "mvl"))
    (do ((a (read s nil) (read s nil)))
	((null a))
      (cond ((eq a ':empty) (empty))
	    ((eq a ':value) (setq value (eval (read s nil)) function nil))
	    ((eq a ':function) (setq function (eval (read s nil)) value nil))
	    (value (state a :value value))
	    (t (state a :function function)))))
  'done)

;; unload the facts in a .MVL file.  Ignoring all keywords, just unstate
;; each proposition in the file.

(defun mvl-unload (f)
  (with-open-file (s (mvl-file f "mvl"))
    (do ((a (read s nil) (read s nil)))
	((null a))
      (cond ((eq a ':empty))
	    ((member a '(:value :function)) (read s nil))
	    (t (unstate a)))))
  'done)

(defparameter *mvl-file-header* nil)

#(or +Genera +Allegro)
(setq *mvl-file-header*
      ";;; -*- Mode: MVL; Syntax: Common-lisp; Package: MVL; Base: 10 -*-~2%")

;; write the MVL database out to a file.  Keywords are cutoffs, empty,
;; props, and what to do if the .MVL file already exists (the default is
;; to make a new version).  First we find all the propositions that pass
;; the cutoff test, and write out any header line to the file.  If the
;; empty cutoff is supplied, we write out ":empty".

;; Now we work through each proposition, setting current to its truth
;; value unless its truth value is the default value for this
;; proposition or its negation, in which case we set current to
;; *default*.  Now, if both this sentence and the previous one had
;; default truth values, we just write out the sentence.  If the truth
;; values are the same, we can also just write out the sentence.  If
;; we have to write out the truth value, we either write out NIL if it's
;; a default, or the actual value, and then write out the sentence.  So
;; what we actually do is figure out if we have to write out the truth
;; value, and then do so if necessary.  Then we write out either the
;; version of the sentence that has a default truth value (which might
;; be the negation of the sentence), or the given sentence.

#-ANSI (defvar *print-readably*)
#+(and ANSI Allegro) (defvar *print-readably*)

(defun mvl-save (f &key (cutoffs *knowledge-test*)
		 (props (props)) empty (if-exists :new-version)
		 &aux (init (list 0)) temp (last init) (default (list 1))
		      current)
  (declare (special default))
  (setq props (delete-if-not #'(lambda (x) (test (truth-value x) cutoffs))
			     (reverse props)))
  (with-open-file (s (mvl-file f "mvl" :no-error t) :direction :output
		   :if-exists if-exists)
    (let ((*print-readably* t))
      (if *mvl-file-header* (format s *mvl-file-header*))
      (if empty (format s ":empty~%"))
      (dolist (item props)
	(setq current (if (setq temp (truth-value-is-default item)) 
			  default
			(truth-value item)))
	(unless (if (eq last init)
		    (eq current default)
		  (or (eq last current) (and (not (eq current default))
					     (not (eq last default))
					     (mvl-eq current last))))
	  (show-value s current))
	(setq last current)
	(format s "~%~a" (or temp (denotes item))))))
  'done)

;; does this sentence have a default truth value?  Yes, if either its
;; value is the same as applying stash-value to its denotation, or its
;; value is the negation of the result of applying stash-value to the
;; negation of its denotation.  In either case, we return the
;; proposition that could be stashed with a default value to give the
;; desired result.

(defun truth-value-is-default (item)
  (or (tvid (truth-value item) (denotes item))
      (tvid (mvl-not (truth-value item)) (negate (denotes item)))))

(defun tvid (value p)
  (if (mvl-eq value (stash-value p)) p))

;; write a truth value to a stream.  If it's default, then write out
;; nil.  If it's a distinguished element, just write out the name of the
;; distinguished element.  Otherwise, put it after a ' and write that
;; out.  (This may not produce the desired effect if the proposition
;; name itself appears as part of the truth value.)

(defun show-value (s value)
  (declare (special default))
  (format s "~2%:value ~?"
	  (cond ((eq value default) "nil")
		((mvl-eq value true) "true")
		((mvl-eq value false) "false")
		((mvl-eq value unknown) "unknown")
		((mvl-eq value bottom) "bottom")
		(t "'~a"))
	  (list value)))
;;; -*- Mode: LISP; Syntax: Common-lisp; Package: MVL; Base: 10 -*-

(in-package "MVL")

;; functions reaching into mvl database.  Indexp takes a prop and
;; returns a datum, or nil, such that the datum is samep as the prop.
;; Lookp takes a prop and returns a list of items of the form
;;   (<datum> . <list of binding lists>)

;; Redefine low level access functions to use without-interrupts to avoid
;; conflicts between different processes accessing the data base.

(defmacro without-process-preemption (&body body)
  `(,(read-time-case
       #+Genera 'scl:without-interrupts
       #+Coral  'ccl:without-interrupts
                'progn)
    .,body))

;; These routines build a discrimination net for the MVL database, as
;; described in Charniak, Riesbeck and McDermott.  The basic story is
;; that you have a root node and then pointers that track the
;; development of any particular expression.  Thus (p a b) would have a
;; pointer for p, then one for a and then one for b.  The node
;; corresponding to b would have a pointer indicating that the
;; expression was complete because the ")" was encountered.

;; At any given point, then, you can encounter a symbol (perhaps a
;; variable), a "(" indicating that you are going "up" a level, or a ")"
;; indicating that you are going "down" a level; for each of these,
;; there is a pointer to subsequent nodes in the discrimination net.

;; Now consider an attempt to find some query in the discrimination net.
;; Since we have to assume that a variable in the database matches any
;; atom in the query, we will *always* have to look along those arcs
;; that are labelled with variables; these arcs are therefore stored
;; separately to avoid an extra call to assoc.  (Most of the arcs are
;; just dumped into the node's "links" property, an association list or
;; hash table being constructed.)  In addition, if there is a variable
;; in the query, that will match *any* symbol, so it would be nice if we
;; had an accumulation of all such nodes already built up.  This is
;; done; the q? ("query-?") slot of a node includes pointers to all
;; those nodes that can be reached by instantiating a variable at the
;; current position.  This may involve instantiating the variable to a
;; symbol, to another variable, or to an entire expression.

;; One further wrinkle is that the links slot is stored either as an
;; alist or as a hash table, depending on its size.  If an alist, the
;; car of the slot counts the entries, so that you can determine easily
;; when to make the hash table transition.  For Symbolics machines, the
;; association lists are faster until the number of entries in a node
;; grows to around 50.  On Suns, the value appears to be less than 10.

(defparameter hash-threshold 15)		; Threshold for crossover
						; from alist to hashtable

;; Constants and basic node structures

(defstruct dnode
  (links nil)			; alist of links or hash table
  (? nil)			; ? dnode pointer
  (?* nil)			; * dnode pointer
  (q? nil)			; q? dnode list
  (up nil)			; ( dnode pointer
  (dn nil))			; ) dnode pointer or answers

(defvar rootnode)		; root node in the discrimination net

;; dinit resets the entire discrimination net.

(defun dinit ()
  (setq rootnode (make-dnode)))

;; Basic accessor function for discrimination net.  This function takes
;; a node (the current position in the net), an atom (the symbol to be
;; processed next), and returns the next node to look at.  If the atom
;; is a variable or a parenthesis, it's easy.  If it's an atom, then
;; look for that atom on the links property of the given node.  (Said
;; links property will be either an association list or a hash table.)

(defvar newflg)			; indicates new node formed

(defun getnode (node p)
  (case p
    (? (dnode-? node))
    (?* (dnode-?* node))
    (\( (dnode-up node))
    (\) (dnode-dn node))
    (t (getnode1 node p))))

(defun getnode1 (node p)
  (when (setq node (dnode-links node))
    (if (consp node)
	(cdr (assoc p (cdr node)))
	(gethash p node))))

;; This function says that a node should have a child pointed to by p.
;; Of course, if there already is such a child (as indicated by
;; getnode), then you don't have to create one.  If you *do* create a
;; child, set newflg to indicate that a new node has been created.
       
(defun putnode (node p)
  (or (getnode node p)
      (putnode1 node p (setq newflg (make-dnode)))))

;; The given node should have an arc corresponding to p pointing to
;; newnode.  If p is a variable or parenthesis, it's easy.  If p is a
;; symbol and the first one, set up the association list (the links
;; property always starts with a counter indicating how many elements it
;; contains, so that you can decide quickly when to switch to a hash
;; table).

(defun putnode1 (node p newnode)
  (case p
    (? (setf (dnode-? node) newnode))
    (?* (setf (dnode-?* node) newnode))
    (\( (setf (dnode-up node) newnode))
    (\) (setf (dnode-dn node) newnode))
    (t (let ((links (dnode-links node)))
	 (cond ((null links) 
		(setf (dnode-links node) (list 1 (cons p newnode))))
	       ((hash-table-p links)			; hash array?
		(setf (gethash p links) newnode))	; add entry
	       ((>= (car links) hash-threshold)		; reached threshold?
		(setf links (convert-to-hash (cdr links))
		      (dnode-links node) links
		      (gethash p links) newnode))	; add entry
	       (t (incf (car links))			; add to alist
		  (push (cons p newnode) (cdr links))))
	 newnode))))

;; convert an alist to a hash table.  Just work through it, an element
;; at a time.

(defun convert-to-hash
    (alist &aux (table (make-hash-table :size hash-threshold)))
  (dolist (x alist table)
    (setf (gethash (car x) table) (cdr x))))

;; Storage function for discrimination net.  All expressions are assumed
;; to be lists (i.e., no dotted pairs); we catch any expression that
;; doesn't satisfy this condition.  The way it works is that we use
;; index-1 to walk down the discrimination net till we get to the end of
;; the expression; the dnode-dn slot of the final node corresponds to
;; the final ")" and is used to store a list of those database elements
;; that match the given expression (with no consideration to variable
;; conflicts).  So use samep to see if the supplied proposition already
;; exists in the database; if so, return it.  If not, make a new
;; meta-symbol to denote this proposition and add it to the list of
;; things denoted by this node in the discrimination net.

(defun index (prop &key (uniquify t))
  (declare (special prop))
  (without-process-preemption
    (catch 'dots
      (let* (newflg				; no new nodes created (yet!)
	     (node (index-1 rootnode prop)))
	(or (find prop (dnode-dn node) :key #'denotes :test #'samep)
	    (let ((d (new-meta-symbol prop :uniquify uniquify)))
	      (push d (dnode-dn node))
	      d))))))

;; Walk down the discrimination net, looking for the proposition p.  At
;; any point, newnode is used to record the node found after processing
;; the next element in the list.  Of course, this "element" may itself
;; be a list.  If so, then insert a "(" pointer, process the list, and
;; then insert a ")" pointer; the endpoint of the ")" pointer is the new
;; node.  If the element isn't a list, then just process it normally.

;; Having processed the element, we make sure to put the result on the
;; q? property of the preceding node, using pushnode-?.  Then we
;; continue with the main loop.  A check is also included to make sure
;; that p doesn't include dotted pairs.

(defun index-1 (node p &aux newnode)
  (declare (special prop))
  (do nil ((null p) node)
    (when (atom p)
      (warn "~
Dotted expression encountered while attempting to insert ~a into database."
	    prop)
      (throw 'dots nil))
    (setq newnode (if (listp (car p)) 
		      (putnode (index-1 (putnode node '\( ) (car p)) '\))
		      (putnode node (or (vartype (car p)) (car p)))))
    (pushnode-? node newnode)
    (setq node newnode
	  p (cdr p))))

;; add a node to the ? link for an old node.  If it's not new, of
;; course, you don't have to do anything.

(defun pushnode-? (node newnode)
  (when newflg (push newnode (dnode-q? node))))

;; Sometimes we want to put both a negated sentence and its unnegated
;; version into the database, making sure that they share any uninterned
;; variables.  To do this, we use the function index-with-negation,
;; which first creates the unnegated version and inserts it into the
;; database.  Then if the original version was negated, we do the second
;; insertion while being careful to make the :uniquify keyword nil so
;; that no new variables are created.

(defun index-with-negation (p)
  (multiple-value-bind (stripped inv?) (strip-nots p)
    (let ((dat (index stripped)))
      (if inv? (index (list 'not stripped) :uniquify nil) dat))))

;; remove a node from the discrimination net.  First, we use indexp-1 to
;; actually find the node (assuming that there is one!).  Then we simply
;; delete the node from the dnode-dn slot.  This isn't as efficient as
;; it might be; there will still be all sorts of pointers to the deleted
;; fact.

(defun unindex (d &aux (prop (denotes d)) (node (indexp-1 rootnode prop)))
  (declare (special prop))
  (when node
    (without-process-preemption
      (popf (dnode-dn node) d :count 1))))

;; samep lookup function for discrimination net.  This is pretty easy --
;; just use indexp-1 to find the node, then try to find a matching
;; expression among the ones that the final node points to.

(defun indexp (prop &aux (node (indexp-1 rootnode prop)))
  (declare (special prop))
  (and node (find prop (dnode-dn node) :key #'denotes :test #'samep)))

;; indexp-1 actually does the work.  It's pretty much the same as
;; index-1.

(defun indexp-1 (node p)
  (declare (special prop))
  (do nil ((null p) node)
    (cond ((atom p)
	   (warn "~
Dotted expression encountered when searching database for ~a."
		 prop)
	   (return nil))
	  ((listp (car p))			;embedded subexpression
	   (unless (and (setq node (dnode-up node))
			(setq node (indexp-1 node (car p)))
			(setq node (dnode-dn node)))
	     (return nil)))
	  ((setq node (getnode node (or (vartype (car p)) (car p)))))
	  (t (return nil)))
    (setq p (cdr p))))

;; Finally, a function to look for a specific proposition in the
;; discrimination net.  Of course, the proposition may be found many
;; times ...

(defun lookp (prop &aux answers)
  (declare (special answers prop))
  (lookp-1 rootnode prop (backptr prop))
  answers)

;; The work is done here.  You supply a current node position and a
;; proposition, and we look for a match.  This function also accepts a
;; list of what's left to be done after the match is found, to handle
;; subexpressions.

;; As an example, suppose that we are looking for (foo a (bar b) c d) in
;; the database.  We process the foo, then the a, then notice the
;; subexpression.  At this point, we process the "(" and then attempt to
;; process the bar b with "c d" as the rest argument.  Deeper levels of
;; nesting simply result in multiple entries on the rest arg.

;; In fact, things aren't done quite this way because it involves a lot
;; of consing as the path is traversed (possibly many times).  Instead,
;; we compute at the *beginning* what the rest args will be each time a
;; ")" is encountered, and simply pop the top item off of the list each
;; time we see a ")".  When the list is empty, we're done.

;; As an example, in (foo a (bar b) c d), we know that we will see one
;; nonterminal ")" and that the rest arg then will be (c d).  In the
;; more complicated example (foo a (bar b (x) (y)) (c) d (e)), there are
;; five nonterminal ")"s.  The rest args in the five cases are:
;;  ((y))
;;  NIL
;;  ((c) d (e))
;;  (d (e))
;;  NIL
;; A list of these guys is computed by backptr.

;; We first handle database propositions that match so far with *
;; variables in the current position by calling lookp-*.

;; What we do next depends on p:
;;  1.  If p is null, we're done, at least at this level.  If the
;;  backptr arg is nil, then we really are done, and we just adjoin all
;;  the elements of the dnode-dn slot onto the existing answers, after
;;  checking to make sure that they actually match the expression in
;;  question.  If the backptr is not nil, then we move to the dnode-dn
;;  and pop the backptr to keep going.
;;  2.  If (car p) is a list, then there are two possible sources of a match:
;;   2a.  A variable in the discrimination net that covers the entire
;;   subexpression.
;;   2b.  We can match the subexpression by invoking lookp-1
;;   recursively.
;;  3.  If (car p) is an atom, then:
;;   3a.  If it is a variable, then we check out everything that matches
;;   that variable.
;;   3b.  If it's a * variable, then we handle it separately.
;;   3c.  In other cases, we just move to the next node in the
;;   discrimination net, or as in (2a) match to a variable.

;; This function uses strip-backptr, which takes a subexpression and a
;; current back pointer and returns the portion of the back pointer that
;; will remain if the subexpression is skipped over.

(defun lookp-1 (node p backptr)
  (declare (special answers prop))
  (when node
    (lookp-* node p backptr)
    (cond ((null p)
	   (if backptr (lookp-1 (dnode-dn node) (car backptr) (cdr backptr))
	       (dolist (d (dnode-dn node))
		 (unless (assoc d answers)
		   (let ((match (matchp prop d)))
		     (when match (push (cons d match) answers)))))))
	  ((listp (car p))
	   (lookp-1 (dnode-? node) (cdr p) (strip-backptr (car p) backptr))
	   (lookp-1 (dnode-up node) (car p) backptr))
	  (t (case (vartype (car p))
	       (? (dolist (newnode (dnode-q? node))
		    (lookp-1 newnode (cdr p) backptr)))
	       (?* (lookp-star node (cdr p) backptr))
	       (t (lookp-1 (dnode-? node) (cdr p) backptr)
		  (lookp-1 (getnode1 node (car p)) (cdr p) backptr)))))))

;; This routine handles * variables in the database. Presumably, these *
;; variables can unify with any head of the given proposition, so we
;; call lookp recursively for each such tail and each * variable.  We
;; have to be sure to include the case where the tail is nil, too.

(defun lookp-* (node p backptr &aux (star (dnode-?* node)))
  (when star
    (do ((tail p (cdr tail)) (newbackptr backptr))
	((null tail) (lookp-1 star nil newbackptr))
      (lookp-1 star tail newbackptr)
      (if (listp (car tail))		;chop backptr to skip (car tail)
	  (setq newbackptr (strip-backptr (car tail) newbackptr))))))

;; handle a * variable in the given expression.  It might match with
;; NIL, in which case you just proceed.  Or, it might "absorb" anything
;; that could match to a normal variable, which is handled via a
;; recursive call to lookp-star.

(defun lookp-star (node p backptr)
  (lookp-1 node p backptr)
  (dolist (node (dnode-q? node)) (lookp-star node p backptr)))

;; This function assembles a backpointer for a list expression as
;; described above.  It's pretty simple, really; you just walk down p:
;;  1.  If p is null, you're done.  Return the accumulated list.
;;  2.  If (car p) is null, then it's really () and (cdr p) should be
;;  pushed onto the backpointer list.
;;  3.  If (car p) is an atom, then just pop it off and keep going.
;;  4.  If (car p) is a list, then first see what the tails will be once
;;  you get past (car p), then push (cdr p) as the tail when you get to
;;  the *end* of (car p), then invoke backptr recursively to see what
;;  actually happens *inside* (car p).

(defun backptr (p) (backptr-1 p nil))

(defun backptr-1 (p b)
  (declare (special prop))
  (cond ((null p) b)
	((atom p)
	 (error "~
Dotted expression encountered while searching database for ~a."
		 prop))
	((null (car p)) (cons (cdr p) (backptr-1 (cdr p) b)))
	((atom (car p)) (backptr-1 (cdr p) b))
	(t (backptr-1 (car p) (cons (cdr p) (backptr-1 (cdr p) b))))))

;; This function strips off the elements of backptr corresponding to
;; the list x.  It, too, is simple:
;;  1.  If x is NIL, then you can return (cdr b) -- recall that nil is ()
;;  2.  If (car x) is a list, strip b based on (car x) and keep going
;;  3.  Otherwise, just pop x and continue.

(defun strip-backptr (x b)
  (dolist (item x (cdr b))
    (if (listp item) (setq b (strip-backptr item b)))))

  

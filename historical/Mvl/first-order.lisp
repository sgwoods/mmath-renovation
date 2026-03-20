;; -*- Mode: LISP; Syntax: Common-lisp; Package: MVL; Base: 10 -*-

(in-package "MVL")

#-ANSI (proclaim '(declaration dynamic-extent))

;; There are seven files that contain the code used by the theorem
;; prover.  The basic reason for this is that the theorem prover works
;; by invoking a first-order theorem prover and then accumulating the
;; results as described in various theoretical papers.  Because of this,
;; there are two "levels" to the prover:

;; 1.  The top level controls the invocations of the theorem prover
;; itself.  This level includes the files bc.lisp, bc-user.lisp and
;; bc-interface.lisp.

;; 2.  The lower level is the prover itself.  This is a fairly standard
;; first-order theorem prover but has been modified to do goal-goal
;; resolutions and to delete any proof paths that are subsumed by other
;; portions of the search space.  This level contains the files
;; first-order.lisp, first-order-user-interface.lisp and
;; first-order-mvl-interface.lisp.

;; Finally, it is important that we not use answers returned by the
;; first-order prover that have no bearing on the original query.
;; Note that we don't mind *computing* these answers -- all proof paths
;; that don't hit a modal operator or a default sentence are assumed to
;; be short.  But if we *use* them, we're going to generate all sorts of
;; useless tasks, and the truth values being moved around are going to be
;; much more complex than usual.  So the top level has to be selective about
;; what it uses from the bottom level.  Code to deal with this is in the
;; file relevance.lisp.

;; The file relevance.lisp also includes functions that handle
;; free variables appearing in subgoals.  This is *not* handled
;; using the algorithm in "Negative Subgoals with Free Variables"
;; because other ideas in relevance.lisp subsume this algorithm.
;; Documentation on this is in relevance.lisp itself.

;; Because some of what follows is dependent on the interaction between
;; the top level prover and the individual proof tasks, let us
;; begin by describing it.  We will refer to the nodes in the proof
;; space being explored by the first-order prover as NODES and to the
;; invocations of this prover itself as TASKS.

;; The basic question that we need to answer is the following: Would
;; a particular answer for this task have any impact on the
;; final answer?  This is in general fairly expensive to compute, so we
;; try to do so only infrequently.  The basic idea is that each proof
;; task has a list of answers that are known to affect the final answer
;; and a list of answers that are known not to.  We only initialize a proof
;; attempt when true, if returned by that proof attempt, would impact
;; the final answer.

;; The relevance computations involve maintaining the following data
;; structures:

;; 1.  Every task has an associated list of PATHs.  Roughly speaking, a
;; path indicates what might happen if the task had a particular truth value.
;; As such, a path includes a value that the given task might take and a
;; list of values that the parent might then take (a list because the value
;; taken by the parent might still depend on what other tasks do).  We also
;; include, for reasons that are explained in relevance.lisp, information
;; about the truth values of siblings of the given task.
;;
;; 2.  Tasks also have lists of KNOWN-RELEVANT and KNOWN-IRRELEVANT.  If we
;; can find an answer on one of these lists, we don't have to do any
;; computation at all to see if it's relevant or not.
;;
;; 3.  Tasks also have lists of pending answers that have not been processed
;; because they aren't relevant.

;; Additional documentation on these features is in relevance.lisp, but
;; since the structures corresponding to proof attempts and to tasks
;; need to be defined previously, we have explained this here to make it
;; clear what the slots in these structures are.

;; With regard to the files containing the code itself, it is broken
;; down as follows:

;; 1.  First-order theorem prover.
;;   1a.  The code for the theorem prover itself is in first-order.lisp.
;;   1b.  The code that describes the interface between the first-order
;;   	  theorem prover and the MVL functions that call the theorem
;;   	  prover is in first-order-mvl-interface.lisp.
;;   1c.  The code that describes the user interface to the first-order
;;   	  theorem prover (debugging and trace facilities) is in
;;   	  first-order-user-interface.lisp.
;; 2.  Basic MVL theorem prover.
;;   2a.  The code that does the work is in bc.lisp.
;;   2b.  The code the defines the top-level user functions is in bc-user.lisp.
;;   2c.  The code that describes the user interface (debugging and
;;   	  trace facilities) is in bc-interface.lisp.
;; 3.  The code that handles the relevance computations described above
;;     is in relevance.lisp.

;; This file is first-order.lisp and contains the guts of the
;; first-order throem prover only.

;; Each proof effort is described by an object of type proof.  This object has
;; the following fields:
;;   active-nodes	nodes that are still currently active and need to be
;;			expanded; maintained in the form of an agenda
;;   answers		the answers found
;;   indexp		a crude index of the positive subgoals appearing in
;;			this proof tree
;;   indexn		a crude index of the negative subgoals appearing in
;;			this proof tree
;;   initial-limit	This and the next two fields control the nature of the
;;			search
;;   final-limit
;;   limit-delta
;;   evaluation-fn	Takes a node and returns its "depth"
;;   task		A pointer back to the proof task that invoked the
;;			first-order prover
;;   vars		variables in the query

;; In order to avoid expanding duplicate portions of the search space,
;; nodes that cannot contribute new values to the proof effort are
;; pruned.  In order to implement this idea, the prover retains in
;; memory a list of all of the nodes that have been examined in the
;; proof effort thus far, and indexp and indexn are used to access
;; particular nodes quickly.

;; The nature of the subsumption check is described at the point that
;; the associated function (bc-subsumes) is defined; it is fairly
;; straightforward.

(defvar *initial-limit*)
(defvar *limit-delta*)
(defvar *final-limit*)

(defparameter *node-evaluation-fn* 'best-first-fn)

(defstruct proof
  (active-nodes nil)
  (answers nil) (indexp nil) (indexn nil)
  (initial-limit *initial-limit*) (final-limit *final-limit*)
  (limit-delta *limit-delta*)
  (evaluation-fn *node-evaluation-fn*)
  task vars)

;; To make things a bit simpler, the "literal" in any node has had
;; any leading negations stripped off of it, so that it is a pure
;; literal.  The "inverted" slot is T if the actual term being
;; considered is the negation of the given literal, and is NIL if not.

;; each active node looks like a <goal>
;;   literal		the literal being worked on
;;   inverted		do we really care about the negation of literal?
;;   vars		variables in the literal
;;   clause 		the list of literals or conjunction we are trying to
;;			prove (or NIL in some special cases; see bc-activate)
;;   binding		the binding list for this clause
;;   value		truth value
;;   just		partial justification
;;   opaque		is this literal referentially opaque?	
;;   parent             parent of this node
;;   children           a list of the children of this node
;;   depth		the depth of this node in the tree

;; Most of the fields have to do with this "level" of the proof tree
;; only, so that:

;; clause is a list of nodes that must succeed to get back to the next 
;; higher level of the proof tree, not a list of everything you have 
;; to do to solve the original problem.

;; binding is just the variables that have been instantiated at this 
;; level of the proof tree.  When moving back a level, we remove any 
;; irrelevant bindings (this makes the subsumption check more 
;; efficient, among other things).

;; value is the truth value that has been accumulated at this level 
;; only.

(defstruct (bcanswer (:include answer)) just)

(defstruct (goal (:print-function print-goal) (:include bcanswer))
  literal inverted vars clause (opaque nil) (parent nil) (children nil)
  depth)

;; here is a function that computes the term being considered by the
;; goal node, inverting it if necessary.

(defun goal-term (goal)
  (if (goal-inverted goal)
      (list 'not (goal-literal goal))
    (goal-literal goal)))

(defvar proof)

;; add an unexpanded node to the current proof effort; the parent of the
;; node should already have been established.  First push it onto the
;; list of children of its parent and set up the associated literal,
;; inversion flag and list of variables.  Then call bc-activate to get
;; it going.

(defvar *save-nodes*)

(defun prover-addnode (node &aux (parent (goal-parent node)))
  (multiple-value-bind (literal inverted)
      (strip-nots (plug (car (goal-clause node)) (goal-binding node)))
    (setf (goal-literal node) literal
	  (goal-inverted node) inverted
	  (goal-vars node) (vars-in literal)))
  (when parent
    (push node (goal-children parent))
    (bc-display-info node "creating" *save-nodes*)
    (bc-activate node)))

;; activate a node by pushing it onto the agenda of the current proof effort.

(defun bc-activate (node &aux val)
  (when (setq val (strategic-value node))
    (push-agenda node val (proof-active-nodes proof))))

;; Main entry point for the backward chainer.
;;   1.  Call bc-recursion to see if the node can be eliminated
;;   2.  Put the node into the goal index
;;   3.  Call bc-lookup and bc-rules on the node
;;   4.  Check for goal-goal resolutions

(defparameter *allow-goal-goal-resolution* t)

(defun bc-call (node)
  (bc-display-info node "working on")
  (unless (bc-recursion node)
    (bc-index node)
    (bc-lookup node)
    (bc-rules node)
    (when *allow-goal-goal-resolution* (bc-goalgoal node))))

;; Here we check to see if the given node can be eliminated.  We do this
;; by working through all nodes in the current proof effort that have
;; the same predicate and parity as this one does.
;;  a.  If this node can be subsumed, we should do that.  There is no
;;      point in checking to see if it subsumes another node, since any 
;;      such subsumed node would have been subsumed already.  We return
;;      t in this case.
;;  b.  Any other node that can be subsumed should be.

;; The check is done by bc-subsumes.

(defun bc-recursion (node &aux (friends (possible-matches
					 node (goal-inverted node))))
  (dolist (friend friends)
    (when (bc-subsumes friend node)
      (bc-display-info friend "... subsumed by")
      (return-from bc-recursion t)))
  (dolist (friend friends)
    (when (bc-subsumes node friend)
      (bc-display-info friend "... subsumes")
      (bc-delnode friend))))

(defun possible-matches (node inverted)
  (cdr (assoc (car (goal-literal node))
	      (if inverted (proof-indexn proof) (proof-indexp proof)))))

;; Here we determine whether g1 subsumes g2.  This can only happen if g2
;; is an instance of g1, for a start.  In addition, we should do a samep
;; instead of an instp if the expression is referentially opaque.  (This
;; is true if the goal involves a modal operator, for example.)

;; If it is an instance, we need to see if it cannot return any new
;; answers to the given problem.  The "given problem" can be found by
;; finding the common ancestor of g1 and g2, and g2 will provide no new
;; answers provided that (a) the pending conjuncts for g1 are a subset
;; of those for g2 (i.e., no additional things need to be proven by g1),
;; (b) the relative bindings for g1 are a subset of those for g2, and
;; (c) the justification for g1 is a subset of the justification for g2
;; (i.e., no additional assumptions are needed by g1).  If all of this
;; happens, bc-subsumes returns t.

;; In the code that follows, b1/c1/j1 and b2/c2/j2 are constructed by
;; working from the node g1 or g2 back to the common ancestor,
;; accumulating the bindings/conjuncts left/justification along the
;; path.  These values are then compared to see if g1 subsumes g2.

(defun bc-subsumes (g1 g2 &aux (binding (check-generalizes g1 g2)))
  (when binding
    (let ((ancestor (bc-ancestor g1 g2))
	  (b1 (car binding)) c1 j1 b2 c2 j2)
      (declare (dynamic-extent c1 c2 j1 j2))
      (do ((node g1 (goal-parent node)))
	  ((eq node ancestor))
	(setq b1 (append-binding-lists b1 (goal-binding node))
	      c1 (append c1 (cdr (goal-clause node)))
	      j1 (append j1 (goal-just node))))
      (do ((node g2 (goal-parent node)))
	  ((eq node ancestor))
	(setq b2 (append-binding-lists b2 (goal-binding node)) 
	      c2 (append c2 (cdr (goal-clause node)))
	      j2 (append j2 (goal-just node))))
      (and (binding-le (meaningful-bdgs b2 (goal-vars ancestor))
		       (meaningful-bdgs b1 (goal-vars ancestor)))
	   (conj-subsumes (plug c1 b1) (plug c2 b2))
	   (subsetp (plug j1 b1) (plug j2 b2) :test #'eq-just)))))

(defun check-generalizes (g1 g2)
  (if (goal-opaque g1)
      (samep (goal-literal g1) (goal-literal g2) t)
      (instp (goal-literal g1) (goal-literal g2))))

;; Checking if one justification is equal to another -- if the car's are
;; "truth value", that means that the justification is from a procedural
;; attachment or some such, and we need to check that the cdr's (the
;; truth values produced) are mvl-eq.  In other cases, we have to make
;; sure that the propositions themselves are the same.

(defun eq-just (x y)
  (or (eq x y)
      (and (eq (car x) (car y))
	   (if (eq (car x) 'truth-value)
	       (mvl-eq (cadr x) (cadr y))
	       (equal (cdr x) (cdr y))))))

;; Find the common ancestor of two nodes.  The way it works is that we
;; first figure out which node is deeper than the other, then back that
;; up until they are the same depth.  Once that happens, we can back
;; them up in parallel.  This way, we don't have to keep comparing
;; whole lists of nodes.

(defun bc-ancestor (x y &aux (diff (- (goal-depth x) (goal-depth y))))
  (cond ((plusp diff)
	 (dotimes (i diff) (setq x (goal-parent x))))
	((minusp diff)
	 (dotimes (i (- diff)) (setq y (goal-parent y)))))
  (do nil
      ((eq x y) x)
    (setq x (goal-parent x) y (goal-parent y))))

;; Routine to determine if one conjunction is subsumed by another.  We
;; make sure that every clause in the first conjunction is a
;; generalization of some clause in the second conjunction.  As we go
;; along the first conjunction, we keep accumulating the bindings
;; obtained by unifying with some clause in the second one.

;; This routine is actually buggy in a conservative way, since we might
;; unify with the wrong clause -- conj-subsumes is in reality a search
;; problem.  But the error will only cause bc-subsumes to occasionally
;; not realize that a node is subsumed, so that isn't a problem from a
;; soundness point of view.

(defun conj-subsumes (c1 c2 &aux bdgs b)
  (every #'(lambda (x)
	     (some #'(lambda (y)
		       (when (and (setq b (instp x y))
				  (setq b (dot-binding (car b) bdgs)))
			 (setq bdgs (car b))
			 t))
		   c2))
	 c1))

;; Remove a node and all of its descendents from the active list.  We do
;; this by running through the list of decendants and removing them from
;; the goal index and active list.

(defun bc-delnode (node)
  (bc-del1 node)
  (mapc #'bc-delnode (goal-children node)))

(defun bc-del1 (node)
  (bc-unindex node)
  (del-agenda node (proof-active-nodes proof)))

;; Check to see if an answer for this goal is in the database, and call
;; bc-propagate on each answer found.  If the answer was found in a
;; referentially opaque way, mark the node as opaque.

(defun bc-lookup (node &aux (prop (goal-term node)))
  (multiple-value-bind (ansl xl) (lookups prop :succeed-on-modal-ops t)
    (bc-display-lookup node ansl)
    (mapc #'(lambda (ans x)
	      (bc-propagate (make-bcanswer
			     :binding (answer-binding ans)
			     :value (answer-value ans)
			     :just (bc-just prop x ans))
			    node))
	  ansl xl)
    (when (member (car xl) '(modal attach)) (setf (goal-opaque node) t))))

;; Find rules that apply to a given literal.  For each answer, make a
;; new node, one deeper than the current one.  We have to be careful to
;; pull "clause" out of the binding list before deleting it from ans!

(defun bc-rules (node &aux (starvar '#:?*) 
			   (prop `(<= ,(goal-term node) ,starvar)))
  (multiple-value-bind (ansl xl) (lookups prop)
    (mapc #'(lambda (ans x)
	      (prover-addnode (make-goal
				:parent node
				:clause (get-bdg starvar (answer-binding ans))
				:binding (delete-bdg starvar
						     (answer-binding ans))
				:value (answer-value ans)
				:just (bc-just prop x ans)
				:depth (1+ (goal-depth node)))))
	  ansl xl)))

;; bc-propagate takes an answer and trickles it back up the proof tree.
;; The way it works is that we can stop when either there are still
;; unanalyzed conjuncts for this node, or when the node has no parent.
;; In other cases, we dump any meaningless bindings from the answer
;; before proceeding.

;; If there are more conjuncts for this node, we call bc-plug to absorb
;; the answer and pop the conjunct list.  Otherwise, we adjoin this
;; answer to the binding list for the current node, conjoin the value
;; and update the justification list, then go look at the parent node.
;; If the parent node is nil, we can actually return an answer to the
;; whole problem!

(defun bc-propagate (ans node)
  (do nil ((null node) (push ans (proof-answers proof)))
    (setf (answer-binding ans)
      (meaningful-bdgs (answer-binding ans) (goal-vars node)))
    (when (cdr (goal-clause node))
      (bc-plug node ans)
      (return))
    (setq ans (make-bcanswer
		:binding (append-binding-lists (answer-binding ans)
					       (goal-binding node))
		:value (mvl-and (answer-value ans)
				(mvl-plug (goal-value node)
					  (answer-binding ans)))
		:just (append (bcanswer-just ans)
			      (just-plug (goal-just node)
					 (answer-binding ans))))
	  node (goal-parent node))))

;; construct the partial justification for an answer given by lookup.  If
;; proposition is modal use ('modal p).  And if for some reason you
;; don't need to consider the negation but only want to retain the truth
;; value, push (truth-value . <truth value>) instead of the proposition.
;; Don't push it onto the list if it's true, either (since there's no
;; point in trying to prove its negation).

(defun bc-just (prop source answer &aux (value (answer-value answer)))
  (when (and prop (or (not (mvl-eq value true)) (eq source 'modal)))
    (list (case source
	    (modal (list 'modal (plug prop (answer-binding answer))))
	    (attach (list 'truth-value value))
	    (t (if (monotonic-value value) `(truth-value ,value) 
		 (plug prop (answer-binding answer))))))))

;; Take an answer for a goal literal and generate the new subgoal for
;; the remaining conjuncts

(defun bc-plug (node ans)
  (prover-addnode
    (make-goal :clause (cdr (goal-clause node))
	       :binding (append-binding-lists (answer-binding ans)
					      (goal-binding node))
	       :value (mvl-and (answer-value ans)
			       (mvl-plug (goal-value node)
					 (answer-binding ans)))
	       :just (append (bcanswer-just ans)
			     (just-plug (goal-just node) (answer-binding ans)))
	       :parent (goal-parent node)
	       :depth (goal-depth node))))

;; plug a binding list into a justification.  The only trick is that if
;; an element on the justification is of the form (truth-value x), then
;; use mvl-plug on x instead of just plug.

(defun just-plug (just bdg)
  (if bdg (mapcar #'(lambda (x) (jp x bdg)) just) just))

(defun jp (clause bdg)
  (if (eq (car clause) 'truth-value)
      `(truth-value ,(mvl-plug (cadr clause) bdg))
      (plug clause bdg)))

;; This routine does the equivalent of goal-goal resolutions for a
;; natural deduction theorem prover.  It takes a goal node and examines
;; all other goal nodes in the proof tree that might match the negation
;; of this goal.  When it finds one, it finds the common ancestor of the
;; two nodes and checks to see that the variable bindings along the
;; paths to the ancestor are consistent.  If so, it collects all the
;; conjuncts, justifications, and truth values along the two paths, and
;; builds a new subgoal of the ancestor node corresponding to the
;; ancestry filtered deduction.

(defun bc-goalgoal (node &aux (stripped (goal-literal node)))
  (dolist (enemy (possible-matches node (not (goal-inverted node))))
    (when (pre-unify stripped (goal-literal enemy))
      (let ((ancestor (bc-ancestor node enemy))
	    (binding (unifyp stripped (goal-literal enemy))))
	(when (and binding
		   (setq binding
		     (dot-binding (car binding) 
				  (bc-ancestorbdgs enemy ancestor)))
		   (setq binding
		     (dot-binding (car binding) 
				  (bc-ancestorbdgs node ancestor))))
	  (do-goal-goal node enemy binding ancestor))))))

;; the goal-goal "resolution" is done here.  We begin by assembling the
;; conjuncts left to solve, justification and truth value of the
;; resultant node.  Then if there is nothing left to do, it's easy -- we
;; just propagate a new answer for the ancestor.

(defun do-goal-goal (g1 g2 binding ancestor &aux conjuncts just (value true))
  (declare (dynamic-extent conjuncts just))
  (do ((node g1 (goal-parent node)))
      ((eq node ancestor))
    (setq conjuncts (append conjuncts (cdr (goal-clause node)))
	  just (append just (goal-just node))
	  value (mvl-and (goal-value node) value)))
  (do ((node g2 (goal-parent node)))
      ((eq node ancestor))
    (setq conjuncts (append conjuncts (cdr (goal-clause node)))
	  just (append just (goal-just node))
	  value (mvl-and (goal-value node) value)))
  (setq binding (car binding)
	value (mvl-plug value binding)
	conjuncts (delete-duplicates (plug conjuncts binding) :test #'equal)
	just (just-plug (delete-duplicates just :test #'eq-just) binding))
  (if conjuncts
      (prover-addnode (make-goal :parent ancestor
				 :clause conjuncts
				 :binding binding
				 :value value
				 :just just
				 :depth (1+ (goal-depth ancestor))))
      (bc-propagate (make-bcanswer :binding binding :value value :just just)
		    ancestor)))

;; Finds out the bindings that apply to the ancestor node.  Called only
;; by BC-goalgoal.

(defun bc-ancestorbdgs (node ancestor)
  (do (binding)
      ((eq node ancestor) binding)
    (setq binding (append-binding-lists (goal-binding node) binding)
	  node (goal-parent node))))

;; These routines have to do with maintenance of the goal index in the
;; proof structure. 

;; Put a new goal into the subgoal index for this proof tree.

(defun bc-index (goal &aux (entry (bc-index-fn goal)))
  (cond (entry (push goal (cdr entry)))
	(t (setq entry (list (car (goal-literal goal)) goal))
	   (if (goal-inverted goal)
	       (push entry (proof-indexn proof))
	     (push entry (proof-indexp proof))))))

(defun bc-index-fn (goal)
  (assoc (car (goal-literal goal))
	 (if (goal-inverted goal) (proof-indexn proof) (proof-indexp proof))))

;; Remove a subgoal from the goal index for this proof tree.

(defun bc-unindex (goal)
  (delete goal (bc-index-fn goal) :count 1))


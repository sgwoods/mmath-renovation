;;; -*- Mode: LISP; Syntax: Common-lisp; Package: MVL; Base: 10 -*-

(in-package "MVL")

;; First-order theorem prover; interface and diagnostic stuff.
;; Functions defined:
;; 
;; init-prover (p effort)
;;   Start a new task to prove p, spawned by the given proof effort.
;; 
;; cont-prover (proof)
;;   Reinvoke the proof task associated with a given bit of auxiliary
;;   information.

(defvar *initial-limit*)
(defvar *limit-delta*)
(defvar *final-limit*)
(defvar *node-evaluation-fn*)

;; Stuff for search control.  The basic way it works is that each node
;; in the proof is evaluated to obtain its "merit" as a list of numbers;
;; this is controlled by the node evaluation slot in the proof
;; structure.  This slot is set to the value of *node-evaluation-fn*,
;; which defaults to best-first-fn, which attempts to expand the
;; "simplest" node next in order to find a simple proof.  An alternative
;; to best-first-fn is depth-fn, which simply records the current depth
;; in the search tree.
;;
;; The search control is done using three parameters:
;;   *final-limit*	Any node that is worse than this value is pruned.
;;   *initial-limit*	If null (the default) depth-first search is used.
;;   and *limit-delta*	Otherwise, the nodes are ordered in terms 
;;			of (x-*initial-limit*)/*limit-delta*.  A typical
;;			value for *initial-limit* is 0, and for *limit-delta*
;;			is 1.

(defun set-search-parameters
       (&key (initial-limit *initial-limit*) (limit-delta *limit-delta*)
	(final-limit *final-limit*))
  (setq *initial-limit* initial-limit *limit-delta* limit-delta
	*final-limit* final-limit))

(defun activate-breadth-first (&key (initial-limit 0) (limit-delta 1)
				    (final-limit nil))
  (set-search-parameters :initial-limit initial-limit :limit-delta limit-delta
			 :final-limit final-limit)
  (setq *node-evaluation-fn* 'depth-fn))

(defun activate-depth-first (&key (final-limit nil))
  (set-search-parameters :initial-limit nil :limit-delta nil
			 :final-limit final-limit))

(defun activate-best-first (&key (initial-limit 0) (limit-delta 1)
				 (final-limit nil))
  (set-search-parameters :initial-limit initial-limit :limit-delta limit-delta
			 :final-limit final-limit)
  (setq *node-evaluation-fn* 'best-first-fn))

(activate-depth-first)

(defun best-first-fn (node)
  (append (mvl-simplicity (goal-value node)) (depth-fn node)))

(defun depth-fn (node)
  (list (- (goal-depth node))))

(defvar proof)
(defvar true)

;; Initialize the prover.  Creates and returns the instance of proof
;; that will be used to maintain all of the information about this proof
;; effort.  Calls reset-prover to set the iterative deepening parameters
;; and to initialize the list of unpruned nodes, and sets
;; *watched-nodes* to NIL.

(defvar *watched-nodes*)

;; The only tricky thing here is if you are asked to prove a disjunction.
;; In order to make sure that the proof tree is singly-rooted, we create
;; a dummy node called "user-supplied-query" and put all the disjuncts
;; under that (the proposition also includes copies of the original
;; sentence, so that the variables are included).  Prover-addnode is
;; defined in first-order.lisp and adds a given node to the current proof
;; tree.

(defun init-prover (p task &aux (clauses (dnf p))
		    (proof (make-proof :task task :vars (vars-in p)))
		    (dummy-root (make-goal :clause `((user-supplied-query ,p))
					   :value true :depth -1)))
  (setq *watched-nodes* nil)
  (prover-addnode dummy-root)
  (dolist (clause clauses)
    (prover-addnode (make-goal :parent dummy-root :clause clause :value true
			       :depth 0)))
  proof)

;; Invoke the prover.  proof is globally bound by the call, so all we
;; need to do is process the unpruned nodes until an answer is returned.

(defun cont-prover (proof)
  (declare (special *prop*))
  (when (or (proof-answers proof) (proof-active-nodes proof))
    (task-diagnostic (proof-task proof) "Prover for" *prop* "invoked")
    (do ()
	((proof-answers proof) (pop (proof-answers proof)))
      (cond ((proof-active-nodes proof)
	     (bc-call (pop-agenda (proof-active-nodes proof))))
	    (t (task-diagnostic (proof-task proof)
				"Prover for" *prop* "terminated")
	       (return))))))

;; strategic-value evaluates a particular node to get its agenda
;; position.  A node that is supposed to have been pruned because it's
;; too deep in the tree gets value NIL (which is then recognized by
;; bc-activate).  We only normalize the car of the actual value using
;; the proof limit parameters.

(defun strategic-value (node &aux (val (funcall (proof-evaluation-fn proof)
						node))
			(n (normalize-principal-value (car val))))
  (if n (cons n (cdr val))))

;; normalize the leading entry on a proof value.  If it's past the
;; maximum allowed value, return nil.  Otherwise, either return 0 all
;; the time if initial-limit is nil, or return the computed value.
;; Anything below the initial limit is automatically given a value of 0.

(defun normalize-principal-value (num)
  (unless (and (proof-final-limit proof) (> num (proof-final-limit proof)))
    (if (and (proof-initial-limit proof) (> num (proof-initial-limit proof)))
	(truncate (- num (proof-initial-limit proof))
		  (proof-limit-delta proof))
      0)))


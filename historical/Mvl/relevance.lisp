;;; -*- Mode: LISP; Syntax: Common-lisp; Package: MVL; Base: 10 -*-

(in-package "MVL")

;; global variable defined:

;; *completed-database*	t or nil depending on whether approach to unground 
;;			negative subgoals is as suggested by Chan or Ginsberg
;;			respectively

;; Here is all the stuff to make sure you don't work on proofs or
;; portions thereof that can't affect the final answer anyway.  The
;; following functions are defined here:

;; recheck-everything () marks all tasks as needing their relevance
;; computations reexamined.

;; recheck-decendants (task) marks all the proper decendants of task
;; (i.e., not task itself) as needing their relevance computations
;; reexamined.

;; return-answer (main-task)	what can you return now?

;; relevant-ans (ans) returns T or NIL depending on whether the
;; given answer can affect the response to the original query.

;; relevant-task (old new task) returns T if it would matter if the truth
;; value of task changed from old to new.

(defvar proof)
(defvar analysis)

;; mark various tasks as needing their relevance rechecked.
;; recheck-everything marks everything, recheck-decendants marks all
;; proper subtasks of its argument.  The easiest way to do it is to
;; write recheck-subtasks, which marks all of the subtasks for sure and
;; the argument depending on the value of its third argument.

;; These functions are also responsible for reactivating any task that
;; is inactive and has pending answers.

;; In other words, we need to:
;;  1.  Mark the task as needing its relevance rechecked and activate
;;      it if it's inactive.
;;  2.  For all the children of this task, invoke recheck-subtasks
;;      recursively.

(defun recheck-everything ()
  (recheck-subtasks (analysis-main-task analysis) t))

(defun recheck-decendants (task)
  (recheck-subtasks task nil))

(defun recheck-subtasks (task this-task-too? &aux proof)
  (when this-task-too?
    (when (and (inference-p task) 
	       (or (not (proof-p (setq proof (inference-proof task))))
		   (inference-pending task)))
      (setf (inference-recheck task) t)
      (when (eq (inference-status task) 'inactive)
	(setf (inference-status task) 'active)
	(push task (analysis-active-tasks analysis)))))
  (mapc #'(lambda (x) (recheck-subtasks x t))
	(consider-children task)))

;; Here is the work -- in the relevance computation.  To describe this, we
;; need to describe PATHs.

;; 1.  If the task is the main task, we need simply to check.

;; 2.  If the task is a normal task, the hypothetical truth value can cause
;; the parent of this task to take a variety of values, depending on the
;; values taken by siblings of the given task.  The siblings' values could
;; be either their actual values, or their hypothetical values based on
;; various assumptions.  In either case, we want to make the assumptions
;; about the siblings' values, and then see if there is any impact on the
;; final answer via the parent task.  We need to save the truth values of
;; the siblings (so that we know whether or not to repeat the computation)
;; and also a *list* of truth values for the parent that are different than
;; they would be under common assumptions about the siblings.  If this list
;; is empty, then there is no way for this task to affect the final answer.
;; If the list is nonempty, then we can figure out whether or not we can
;; affect the final answer by invoking the relevance computation recursively.

;; So a PATH is a structure with the following fields:
;;   old		the "old" value for the task (this is the value
;;   			subject to all sorts of assumptions about siblings etc)
;;   new		the new value being taken by the task
;;   parent-values	a list of (old . new) values that the parent might take

;; If the task has no parent, then the parent-values field is used to
;; hold either T (the answer is relevant) or NIL (it isn't).

(defstruct path
  old new (parent-values nil))

;; Returning answers.  Just prune out everything that doesn't satisfy
;; the termination test.

(defun return-answer (main-task &aux (terminate (analysis-terminate analysis)))
  (dag-prune (consider-truth-value main-task)
	     #'(lambda (x) (test x terminate))))

;; In some cases, it's easy.  The answer being returned may be known relevant
;; or not, and we can just return as appropriate.  Otherwise, we call
;; computed-irrelevant to figure it out, cache the result and act
;; appropriately.

(defparameter *foo* nil)

(defun relevant-ans (ans task)
  (cond ((and (not *foo*)
	      (find ans (consider-relevant task) :test #'equal-answer)))
	((and (not *foo*)
	      (find ans (consider-irrelevant task) :test #'equal-answer))
	 nil)
	((relevant-task (consider-truth-value task)
			(mvl-plus (consider-truth-value task)
				  (make-tv binding-dag *active-bilattice* 
					   (answer-binding ans)
					   (answer-value ans))
				  bdg-to-truth-val)
			task)
	 (push ans (consider-relevant task)))
	(t (push ans (consider-irrelevant task)) nil)))

;; The first thing we do is to do it at the task level.  The arguments passed
;; to relevant-task are the current value, the hypothetical value and the
;; task.
;;  1.  If old = new, the answer is no.
;;  2.  If we can find a path for which old and new match, we can use that.
;;      Otherwise, we create a path and pretend it was there all along.
;;  3.  Either way, we either use the answer given by the path (if there
;;      is no parent), or go through the list of parent values hoping for
;;      one to be relevant (if there is a parent).

(defun relevant-task (old new task &aux path (parent (consider-parent task)))
  (when *foo* (format t "
Task: ~a
Old:  ~a
New:  ~a
" task old new))
  (unless (mvl-eq old new bdg-to-truth-val)
    (setq path (or (find-useful-path old new task) (create-path old new task)))
    (if parent (some #'(lambda (x) (relevant-task (car x) (cdr x) parent))
		     (path-parent-values path))
      (path-parent-values path))))

;; An existing path is useful if the old and new values match.

(defun find-useful-path (old new task)
  (find-if #'(lambda (path) (applicable path old new))
	   (consider-paths task)))

(defun applicable (path old new)
  (and (mvl-eq (path-old path) old bdg-to-truth-val)
       (mvl-eq (path-new path) new bdg-to-truth-val)))

;; here is where we create a new path.  Actually, create-path just pushes
;; the new path onto the list of paths for this task; it's cp-1 that creates
;; the path.

(defun create-path (old new task &aux (path (cp-1 old new task)))
  (push path (consider-paths task))
  path)

;; make a new path.  If there is no parent, just record whether the new answer
;; matters.  If there is a parent, look at all the hypothetical new truth
;; values for the parent and for any cases where the new and old values are
;; different, that will be a continuation of the given path.

(defun cp-1 (old new task &aux (parent (consider-parent task)))
  (make-path :old old :new new
	     :parent-values
	     (if parent 
		 (delete-if #'(lambda (x)
				(mvl-eq (car x) (cdr x) bdg-to-truth-val))
			    (pairlis (compute-hypothetical-truth-value
				      parent task old new)
				     (compute-hypothetical-truth-value
				      parent task new old)))
	       (answer-is-really-different new old))))

;; Here is the main task, and a new answer.  Is it really different?
;;  1.  If the old answer has something that passes the success test,
;;  	then the new answer must *fail* the success test at some such point.
;;  2.  Otherwise, the results must be different after you prune everything
;;  	that doesn't pass the cutoff test.

(defparameter *completed-database* nil)

(defun answer-is-really-different (new old
				   &aux (cuts (analysis-cutoffs analysis))
					(succ (analysis-succeeds analysis))
					old-list)
  (unless *completed-database*
    (setq new (ignore-exceptions new)
	  old (ignore-exceptions old)))
  (if (setq old-list (remove-if-not #'(lambda (x) (test (dag-val x) succ))
				    (dag-fn-list old)))
      (some #'(lambda (item)
		(not (test (get-val (dag-pt item) new)
			   succ)))
	    old-list)
    (not (mvl-eq (answer-to-return old cuts)
		 (answer-to-return new cuts)
		 bdg-to-truth-val))))

(defun answer-to-return (val cutoffs)
  (dag-prune val #'(lambda (x) (test x cutoffs))))

;; If *completed-database* is NIL, we don't care about "exceptions"
;; to current answers.  The easiest way to deal with this is just to
;; disjoin all the values from any particular binding to the root.
;; ie-1 does this recursively, and then we simplify the whole thing.

(defun ignore-exceptions (fn &aux (dag (dag-fn-dag fn))
				  (bilattice (dag-fn-bilattice fn))
				  (temp (copy-tree (dag-fn-list fn))))
  (mapc #'(lambda (x) (setf (dag-val x) (ie-1 x temp dag bilattice))) temp)
  (simplify (make-dag-fn :dag dag :bilattice bilattice :list temp)))

;; here we do the disjunction.  We just work our way down from the root
;; of the dag-fn; when we get to the point in question, we know that we
;; can stop because nothing in what follows will be above it.

(defun ie-1 (x orig dag bilattice &aux (v (dag-val x)))
  (dolist (item orig)
    (cond ((eq item x) (return v))
	  ((dag-le dag (dag-pt x) (dag-pt item))
	   (setq v (mvl-or (dag-val item) v bilattice))))))

;; This next group of functions computes the *hypothetical* truth value
;; of a task.  The arguments are the task whose truth value is being
;; computed, the subtask that is getting a modified value, and the
;; modified value that it's getting.  We also pass the "competing" value,
;; since this is relevant to computing truth values for quantifiers.
;;
;; The procedure is as follows:
;; 1.  If the task is a quantification task, we recompute NEW using the
;;     information in OTHER.
;; 2.  If NEW and OLD are equal (no change in truth value), and
;;     compute-hypothetical-truth-value isn't going to change anything
;;     else, we just use the given truth value for the task.
;; 3.  Otherwise, we have to recompute it.  We temporarily write the new value
;;     into the appropriate slot; there are then three cases.  One of them
;;     is easy -- if the task is of type modal-clause, we can just do it
;;     normally.

;; This computation is done in two ways.  In the first, we assume that
;; any "secondary" tasks continue to take their current values.  Thus
;; a modal fn of two args would assume that the other arg continued to take
;; the value it is currently known to take.  In the second approach,
;; the other args are assumed to succeed.  The first approach is easy
;; (just change the value of the subtask and call compute-truth-value);
;; the second is harder.

(defun compute-hypothetical-truth-value
    (task subtask new other &aux (old (consider-truth-value subtask)) ans)
  (when (quantifier-p task)
    (setq new
      (recompute-for-quantification new other (modal-parity task)
				    (if (modal-parity task) 
					(modal-clause-pos subtask)
				      (modal-clause-neg subtask)))))
  (setq ans (list (if (mvl-eq old new bdg-to-truth-val)
		      (consider-truth-value task)
		    (prog2 (setf (consider-truth-value subtask) new)
			(compute-truth-value task)
		      (setf (consider-truth-value subtask) old)))))
  (unless (one-hypothetical task subtask)
    (push (prog2 (setf (consider-truth-value subtask) new)
	      (if (modal-p task)
		  (compute-hypothetical-modal-truth-value task subtask)
		(compute-hypothetical-proof-truth-value task subtask))
	    (setf (consider-truth-value subtask) old))
	  ans))
  ans)

;; is there only one hypothetical value?  Yes, if:
;;  1.  The task is modal but this is the last argument.
;;  2.  The task is modal-clause.
;;  3.  The task is of type inference but there are no following tasks
;;      in any clause.

(defun one-hypothetical (task subtask)
  (typecase task
    (modal (not (cdr (member subtask (consider-children task)))))
    (modal-clause t)
    (t (not (tasks-to-remove (inference-just task) subtask)))))

(defun tasks-to-remove (just subtask)
  (some #'(lambda (x) (ttr-1 (cdr x) subtask)) just))

(defun ttr-1 (cnf subtask)
  (some #'(lambda (x) (ttr-2 x subtask)) cnf))

(defun ttr-2 (conj subtask)
  (some #'modal-p (cdr (member subtask conj))))

;; Is this task considering a quantified sentence?  Yes, if it's modal
;; and involves the right quantifier depending on the parity.

(defun quantifier-p (task)
  (and (modal-p task)
       (eq (car (consider-prop task))
	   (if (modal-parity task) 'forall 'exists))))

;; Here is where we figure out what to use for the "new value" in the
;; quantified case.  The story is that the given task involves a quantified
;; sentence, and we are looking at its modal-clause child.  This child is
;; being assumed to take the value NEW instead of the value OTHER.
;; The problem is that NEW and OTHER may both fail to impact the quantified
;; value because they don't supply values for all bindings of the quantified
;; variable.

;; The way we handle this is to first find all the bindings where NEW and
;; OTHER differ; these are the "relevant" bindings.  Then we get the best
;; hypothetical value for the inference task; for each point at which NEW takes
;; a value, if the binding used is incomparable with all of the relevant
;; bindings, we use the best hypothetical value instead.  If the associated
;; inference task hasn't even gotten started, this is the "wrong side" of
;; the quantifier and we can just return NEW.

(defun recompute-for-quantification (new other parity inference-task)
  (when (proof-p (inference-proof inference-task))
    (setf new (copy-dag-fn new)
	  (dag-fn-list new) (copy-tree (dag-fn-list new)))
    (incorporate-value new (diff-bdgs new other) (if parity true false)))
  new)

(defun diff-bdgs (x y)
  (delete-if #'(lambda (b)
		 (mvl-eq (get-val b x) (get-val b y)))
	     (nunion (mapcar #'car (dag-fn-list x))
		     (mapcar #'car (dag-fn-list y)) :test #'equal-binding)))

(defun incorporate-value (value bdgs val &aux flag)
  (dolist (item (dag-fn-list value))
    (unless (some #'(lambda (b) (or (binding-le b (dag-pt item))
				    (binding-le (dag-pt item) b)))
		   bdgs)
      (setf (dag-val item) (mvl-plus (dag-val item) val)
	    flag t)))
  (if flag (simplify value) value))

;; The story on modal and proof tasks is that we want to assume that
;; all *subsequent* tasks succeed; for previous tasks we use the given
;; value.

;; In the modal case, this is pretty easy.  We find the given task on
;; the list of children of the parent, and for any subseqent task, set
;; the truth value to bottom.  Then we do the computation and reset the
;; truth values.

(defun compute-hypothetical-modal-truth-value
    (task subtask &aux olds (bot (bilattice-bottom bdg-to-truth-val))
		       (rest (cdr (member subtask (consider-children task)))))
  (prog2 (dolist (item rest)
	   (push (consider-truth-value item) olds)
	   (setf (consider-truth-value item) bot))
      (compute-modal-truth-value task)
    (setq olds (nreverse olds))
    (dolist (item rest)
      (setf (consider-truth-value item) (pop olds)))))

;; In the proof case, we work our way through the justifications, doing
;; basically the same thing.

(defun compute-hypothetical-proof-truth-value
    (task subtask &aux (just (copy-tree (inference-just task))))
  (prog2 (reset-other-modal-tasks (inference-just task) subtask)
      (compute-proof-truth-value task)
    (setf (inference-just task) just)))

;; for each element on the justification list, we ignore the binding and
;; just look at the cnf expression.  Then for each conjunction in that,
;; if the given subtask is a member, we simply remove any subsequent
;; clauses.

(defun reset-other-modal-tasks (just subtask)
  (mapc #'(lambda (x) (romt-1 (cdr x) subtask)) just))

(defun romt-1 (cnf subtask)
  (mapc #'(lambda (x) (romt-2 x subtask)) cnf))

(defun romt-2 (conj subtask &aux (tail (member subtask conj)))
  (when tail (setf (cdr tail) (delete-if #'active-modal (cdr tail)))))

(defun active-modal (task)
  (or (and (inference-p task) (or (eq (inference-status task) 'active)
				  (not (proof-p (inference-proof task)))))
      (some #'active-modal (consider-children task))))

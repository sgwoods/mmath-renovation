;;; -*- Mode: LISP; Syntax: Common-lisp; Package: MVL; Base: 10 -*-

(in-package "MVL")

;; inference using functions from binding lists to bilattice.

;; init-analysis (prop &key cutoffs succeeds initial-value)
;;			initializes prover
;; cont-analysis (analysis)
;;			continues prover

(defvar analysis)
(defvar *active-bilattice*)

;; This code has been written to be similar to the code underlying the
;; first-order prover itself, which is contained in first-order.lisp.
;; There, a structure <proof> was defined that contained high-level
;; information about the proof effort, what was left to do, and so on.
;; Here, a similar structure <analysis> is defined.  In both cases, a
;; global variable (proof for first-order, but analysis here) is locally
;; bound to the task being considered in order to avoid passing it
;; around from function to function.

;; There are three separate termination conditions that will cause the
;; prover to return.
;;   cutoffs		Cutoff information when you've got nothing left to do
;;   succeeds		Terminate early if you know that the final answer will
;;			satisfy this
;;   terminate		Stop immediately if the answer satisfies this (even if
;;			it might not after subtasks finish running)

;; An <analysis> has three fields corresponding to these three sorts of
;; termination criteria, and also the following:
;;
;;   prop		The proposition being analyzed
;;   active-tasks	Tasks that still require thought
;;   main-task		The top-level proof task
;;   returned-answers	Answers that have already been returned to the
;;   			user and should not be repeated (an element of
;;   			bdg-to-truth-val)

(defstruct (analysis (:print-function print-analysis))
  prop
  cutoffs succeeds terminate
  (active-tasks nil) main-task
  (returned-answers (bilattice-unknown bdg-to-truth-val)))

(defun print-analysis (analysis stream print-depth)
  (declare (ignore print-depth))
  (format stream #+ANSI "~@<~1I~:[completed ~;~]analysis of~:_ ~a~:>"
	         #-ANSI "~:[completed ~;~]analysis of~<~%~:; ~a~>"
		 (analysis-active-tasks analysis) (analysis-prop analysis)))

;; The analysis basically proceeds by maintaining a list of things to
;; think about, each a structure of type <consider>.  The first of these
;; is simply the task of type INFERENCE on which the prover was invoked,
;; but the whole thing is made more complex by the need to do
;; consistency checking and by the need to treat modal operators.  In
;; each case, it is important that a partial answer be maintained at all
;; times so that the prover exhibits some sort of anytime behavior.

;; The consistency check is the simpler of the two.  Here, a task of
;; type INFERENCE corresponding to the check is generated and
;; investigated like any other.

;; Modal operators are much more subtle.  Here, the parent task cannot
;; be used to collect the truth values of the clauses appearing under
;; the scope of the modal operator, so a separate task must be created
;; for this purpose.  This task is of type MODAL.  To retain the
;; information about the propositional arguments appearing in the scope
;; of a modal operator, the MODAL task spawns a task of type
;; MODAL-CLAUSE for each such argument, and under *these* tasks are
;; found the actual subtasks that are doing the work.

;; The upshot of this is that there are three types of tasks: inference,
;; modal and modal-clause.  In addition, a task of type INFERENCE has a
;; status of active or inactive, depending upon whether or not the
;; associated proof effort has completed.  (If it has, it may still need
;; to be reinvoked if some of the pruned nodes become relevant.)

;; The basic description of the task is given in part by the type of the
;; task in the first place, which is one of three possibilities.  For a
;; task of type INFERENCE, the slot <status> indicates whether the task
;; is active or inactive.  A subtask may also have status DEAD if there
;; is no associated proof effort.  (This is the case if the task is just
;; a place holder for a truth value returned by procedural attachment,
;; for example.)  Inference tasks also have lists of pending answers, so
;; an inference status with status INACTIVE may still have something to
;; contribute to a query if its PENDING field is nonempty.

;; Finally, tasks need pointers to their parents, and the fields discribed
;; in first-order.lisp and used in the relevance computations.  The slots
;; in the basic <consider> structure are as follows:

;;   prop		proposition being proved
;;   parent		parent of a given task
;;   children		children of a given task
;;   truth-value	accumulated truth value
;;   relevant		a list of answers known to be relevant
;;   irrelevant		a list of answers known to be irrelevant
;;   paths		relevance information (see relevance.lisp)

(defvar binding-dag)
(defvar bdg-to-truth-val)

(defstruct (consider (:print-function print-consider))
  prop
  parent (children nil)
  (truth-value (bilattice-unknown bdg-to-truth-val))
  (relevant nil) (irrelevant nil) (paths nil))

;; There are also less basic structures that include auxiliary
;; information that depends upon the type of the task.  Thus an instance
;; of type <inference> includes the fields in the <consider> structure,
;; together with the following:
;;   vars		variables in the proposition being proved
;;   status	       	active, inactive or dead
;;   just		a list of entries of the form (<bdg> . <just>)
;;   			where <just> is a justification in terms of
;;   			other tasks taken from the ATMS lattice
;;   base-value		Truth value that can be obtained by lookup alone
;;   proof		associated call to first-order theorem prover
;;			(set to the proposition being proved till the
;;			prover is set up)
;;   recheck		flag: irrelevant answers may now be relevant
;;   pending		a list of answers computed but not returned

;; An instance of type <modal> includes <consider> and the following fields:
;;   parity		Does the clause appear positively (T) or
;;			negatively (NIL) in the parent?
;;   op			The modal operator involved

;; An instance of type <modal-clause> includes <consider> and also:
;;   pos		The task considering the clause itself
;;   neg		The task considering the negation of this clause

(defstruct (inference (:print-function print-consider) (:include consider))
  vars
  (status 'active)
  (just nil)
  (base-value (bilattice-unknown bdg-to-truth-val))
  proof
  (recheck nil) (pending nil))

(defstruct (modal (:print-function print-consider) (:include consider))
  parity op)

(defstruct (modal-clause (:print-function print-consider) (:include consider))
  (pos nil) (neg nil))

(defun print-consider (task stream print-depth)
  (declare (ignore print-depth))
  (format stream #+ANSI "~@<~1ITask of type~:_ ~a to prove~:_ ~a~:>"
	         #-ANSI "Task of type ~a to prove~<~%~:; ~a~>"
		 (typecase task
		   (inference "INFERENCE")
		   (modal "MODAL")
		   (modal-clause "MODAL-CLAUSE"))
		 (consider-prop task)))

;; initialize the analysis process.  Sets up an <analysis> to
;; investigate the given proposition and initializes the main task to
;; instantiate most of its fields.  We have to set up the analysis
;; before calling generate-task because generate-task expects analysis
;; to be globally bound when it is called.

(defun init-analysis (prop
		      &key (cutoffs std-cutoffs)
			   (succeeds *never-succeeds*)
			   (terminate *never-succeeds*)
			   (initial-value unknown)
			   (analysis (make-analysis
				      :prop prop :cutoffs cutoffs
				      :succeeds succeeds :terminate terminate))
		      &aux (task (generate-task prop nil)))
  (setf (analysis-main-task analysis) task)
  (unless (eq initial-value unknown)
    (setf (inference-base-value task) 
      (make-root binding-dag *active-bilattice* initial-value)
      (inference-truth-value task) (inference-base-value task)))
  analysis)

;; cont-analysis returns two values -- the truth value computed and the
;; analysis used.  This allows the routine to be reinvoked if additional
;; answers are needed.  The way it works is as follows:
;;  1.  If there is nothing left to do, get the truth value of the main
;;  task and return that answer and the (completed) analysis.
;;  2.  Otherwise, take one analysis step.  Either return the result, or
;;  simply try again.

;; This function makes use of the following function in relevance.lisp:
;;
;; return-answer (main-task)	what can you return now?

(defun cont-analysis (analysis &aux (main-task (analysis-main-task analysis))
				    temp)
  (do ()
      ((null (analysis-active-tasks analysis))
       (values (consider-truth-value main-task) analysis))
    (consider-step)
    (unless (mvl-eq (setq temp (return-answer main-task))
		    (analysis-returned-answers analysis)
		    bdg-to-truth-val)
      (return (values temp analysis)))))

;; Much of this code involves computing (or recomputing) the truth value
;; to be associated to any particular task.  There are three ways in
;; which this is done:

;; 1.  The simplest is to merely compute the truth value as things
;; stand.

;; 2.  We may also want to compute the *hypothetical* truth value of a
;; task, assuming that some other tasks work out as well as possible.
;; This is needed by the relevance computations, and the associated code
;; is in relevance.lisp.

;; 3.  Finally, we may want to compute the truth value in a destructive
;; way, updating all of the associated data structures to reflect the
;; change.

;; We begin with case (1), because that's the simplest.  The following
;; functions compute the truth value only, without spawning new tasks
;; and so on.  There are three cases, depending on the type of the task.

;; At the end, we may have to plug in the bindings everywhere.  This
;; appears to only be a problem for modal-clause tasks, and there only
;; if the plugging function on the active bilattice is nontrivial.

(defun compute-truth-value (task)
  (ctv-plug (typecase task
	      (modal (compute-modal-truth-value task))
	      (modal-clause (compute-modal-clause-truth-value task))
	      (t (compute-proof-truth-value task)))
	    task))

(defun ctv-plug (ans task)
  (if (ctv-needs-plug ans task) (ctvp-1 ans) ans))

(defun ctv-needs-plug (ans task)
  (and (modal-clause-p task) (bilattice-plug *active-bilattice*)
       (not (eq ans (bilattice-unknown bdg-to-truth-val)))))

(defun ctvp-1 (f)
  (napcar #'(lambda (x) (cons (dag-pt x) (mvl-plug (dag-val x) (dag-pt x))))
	  (dag-fn-list f))
  (simplify f))

;; For a modal task, pass these truth values off to the combining
;; function associated to the modal operator.

(defun compute-modal-truth-value (task)
  (apply (modal-operator-function (modal-op task)) (modal-exp-args task)))

;; get the arguments for a modal expression.  task is the task whose
;; truth value is being computed, and fn is a function that takes a task
;; and returns the truth value to use (the existence of
;; hypothetical-truth-value means that fn is not always
;; consider-truth-value).  It's pretty easy -- we just walk down the
;; list of children.  The only catch is that we have to be careful to
;; insert any parametric arguments by pulling them off of the
;; proposition being considered.

(defun modal-exp-args (task &aux args (prop (consider-prop task))
		       (parameters (modal-operator-parameters (modal-op task)))
		       (kids (modal-children task)))
  (pop prop)
  (do ()
      ((null prop) (nreverse args))
    (push (cond ((pop parameters) (pop prop))
		(t (pop prop) (consider-truth-value (pop kids))))
	  args)))

;; For a MODAL-CLAUSE task, just combine the positive and negative
;; subtasks.  In some instances, this function may be called before
;; these subtasks are established, so we'll need to return unknown.

(defun compute-modal-clause-truth-value (task)
  (if (modal-clause-pos task)
      (mvl-plus (consider-truth-value (modal-clause-pos task))
		(mvl-not (consider-truth-value (modal-clause-neg task))
			 bdg-to-truth-val)
		bdg-to-truth-val)
    (bilattice-unknown bdg-to-truth-val)))

;; For a nonmodal task, the truth value can be computed using the
;; lookup-value and the truth values of the subtasks.  The justification
;; information for the given task is stored on the <just> property of
;; the task in the form of an ATMS-lattice value associated to each
;; binding for which a justification is known.  There is one additional
;; subtlety -- for a modal task, the parent tasks may actually use
;; either the modal proposition itself, or its negation.  For this
;; reason, modal tasks have a <parity> property that indicates whether
;; the negated (NIL) or nonnegated (T) version of the modal sentence is
;; used.  We also absorb the new binding into the existing answer using
;; bdg-absorb.  [This is described in load.lisp; search for absorption.]

(defun compute-proof-truth-value
    (task &aux (prop (consider-prop task)) (ans (inference-base-value task)))
  (dolist (item (inference-just task) (bdg-absorb ans (inference-vars task)))
    (dolist (conj (cdr item))
      (setq ans (mvl-plus ans (conj-to-val prop (car item) conj)
			  bdg-to-truth-val)))))

;; Here is where we absorb any superfluous variables in the answers returned
;; by the first-order prover.  Of course, if the absorption function is
;; trivial, we can just drop the variables.  If it isn't ...

(defun bdg-absorb (fn vars)
  (if (bilattice-absorb *active-bilattice*)
      (ba-1 fn vars)
    (dag-change-dag fn #'(lambda (x) (meaningful-bdgs x vars)))))

;; ... then we have to group the answers by the apparenlty relevant bindings
;; and, for each, absorb it into the overall answer.

(defun ba-1 (fn vars &aux alist relevant entry)
  (dolist (item (dag-fn-list fn) 
	    (make-dag-fn :dag (dag-fn-dag fn) :bilattice (dag-fn-bilattice fn)
			 :list (nreverse alist)))
    (setq relevant (meaningful-bdgs (dag-pt item) vars)
	  entry (assoc relevant alist :test #'equal-binding))
    (if entry
	(setf (cdr entry)
	  (mvl-absorb (cdr entry) (dag-pt item) (dag-val item)))
      (push (cons relevant (dag-val item)) alist))))

;; given a conjunct, construct a truth value.  Basically, combine the
;; truth values after including information from the bindings associated
;; with a particular justification.  But there is one proviso -- if
;; there is only one conjunct, and it's a modal task and the same as
;; plugging bdg into prop, then presumably the original proposition was
;; modal.  In this case, we just pass back the truth value itself,
;; rather than the t-grounded version.

(defun conj-to-val (prop bdg conj)
  (include-bdg-in-truth-value
    bdg
    (if (and (car conj) (not (cdr conj)) (modal-p (car conj))
	     (equal (plug prop bdg) (consider-prop (car conj))))
	(mvl-not (adjust-truth-value (car conj)) bdg-to-truth-val)
      (combine-for-proof conj))
    :modify #'bilattice-or))

(defun combine-for-proof (tasks)
  (if tasks
      (mvl-t-ground (mvl-not (reduce (bilattice-or bdg-to-truth-val)
				     (mapcar #'adjust-truth-value tasks))
			     bdg-to-truth-val)
		    bdg-to-truth-val)
      (bilattice-true bdg-to-truth-val)))

;; modify a truth value to include a particular "root" binding.  If the
;; root binding is null, just return the given truth value.  Otherwise,
;; append the given binding to the bindings of the truth value.

(defun include-bdg-in-truth-value (bdg value &key modify)
  (if bdg
      (dag-change-dag value #'(lambda (x) (append-binding-lists x bdg))
		      :bilattice-modify modify)
      value))

;; when computing the truth value contributed by a given task, if it is
;; a nonmodal task, just negate the given truth value.  If it is a modal
;; task, then check to see whether it is used positively or negatively
;; in the parent, and negate the truth value if necessary.  Actually,
;; the negation is done by combine-for-proof in order to save some of
;; the repeated calls to the negation function.  There are also dummy
;; tasks (status DEAD) that are basically just placeholders for truth
;; values.  So it turns out that the only time a truth value needs to be
;; negated is if the task is modal and the parity is *positive*.

(defun adjust-truth-value (task)
  (if (proof-normal-value task)
      (mvl-not (consider-truth-value task) bdg-to-truth-val)
    (consider-truth-value task)))

(defun proof-normal-value (task)
  (and (modal-p task) (modal-parity task)))

;; Here we *recompute* the truth value assigned to a task, making
;; whatever destructive modifications are appropriate as we go,
;; including recomputing the truth values of the parents.  If the new
;; truth value is different from the old one, this involves doing the
;; following:

;; 1.  The parent task needs to have its truth value recomputed.

;; 2. If the new task value is *not* different, then we have "bottomed out"
;; and, for every task under this one, reactivate it if it has pending
;; answers.

;; So the way it works is as follows:

;; 1.  For this task, we get the new truth value and see if
;; it's different than the original one.  If so, we:

;; 2.  Tell the user if tracing is on.  If the task has a parent,
;; we recompute *its* truth value and also have to wipe out all the
;; paths for *siblings* of this task.  If there is no parent, the root
;; of the whole tree has changed value and we have to recheck everything
;; for relevance.

;; 4.  Finally, if the task *hasn't* changed truth value, it's the root
;; of a group of tasks that have, and we have to update the rechecking
;; information for all of the decendants of the given task.

;; This function makes use of the following functions in relevance.lisp:

;; recheck-everything () reactivates all tasks with pending answers.

;; recheck-decendants (task) reactivates any proper decendant of task
;; that has pending answers.

(defun recompute-truth-value (task)
  (cond ((not (mvl-eq (consider-truth-value task)
		      (setf (consider-truth-value task)
			(compute-truth-value task))
		      bdg-to-truth-val))
	 (show-truth-value task)
	 (cond ((consider-parent task)
		(dolist (kid (consider-children (consider-parent task)))
		  (unless (eq kid task) (setf (consider-paths kid) nil)))
		(recompute-truth-value (consider-parent task)))
	       (t (recheck-everything))))
	(t (recheck-decendants task))))

;; Stuff to generate a task.  Different depending on whether the
;; proposition is modal (an assumption used in another argument) or not
;; (in which case it's a consistency check of some sort).

(defun generate-task (prop parent)
  (if (eq (car prop) 'modal)
      (generate-modal-task prop parent)
    (generate-nonmodal-task prop parent)))

;; Generate a modal task.  The proposition is of the form (MODAL . <prop>),
;; so that you actually want the modal task to be about the
;; proposition <strip-nots prop>, and need to record the parity as well.
;; It is at this point that we generate the MODAL-CLAUSE children as
;; well.  At the end, we recompute the truth value of the given (modal)
;; task.

(defun generate-modal-task (prop parent)
  (declare (special *prop*))
  (multiple-value-bind (p inv) (strip-nots (second prop))
    (let* ((op (bdg-modal-op (car p)))
	   (task (make-modal :prop p :parent parent :parity (not inv) :op op)))
      (push task (consider-children parent))
      (setf (consider-children task) (modal-task-children task (cdr p) op))
      (task-diagnostic task "Node for modal proposition" *prop*
		       "being constructed")
      (recompute-truth-value task)
      task)))

;; make the children of a modal task.  The only catch is that parametric
;; arguments do not spawn subtasks.

(defun modal-task-children (parent clauses op
			    &aux ans (info (modal-operator-parameters op))
				 task)
  (dolist (clause clauses (nreverse ans))
    (unless (pop info)
      (setf task (make-modal-clause :prop clause :parent parent)
	    (modal-clause-pos task) (generate-task clause task)
	    (modal-clause-neg task) (generate-task (negate clause) task))
      (push task ans)
      (setf (consider-truth-value task) (compute-truth-value task)))))

;; Generate an inference task.  There's a catch -- we are really
;; interested in the negation of the given proposition (since it's for a
;; consistency check), so we lookup (negate prop), negate the result and
;; initialize the prover to actually do the work.  In this case (unlike
;; generate-modal-task), parent might be null if the main task is the
;; one being initialized.

(defun generate-nonmodal-task (prop parent &aux task)
  (setq task (make-inference :prop prop :vars (vars-in prop) :parent parent))
  (if parent (push task (consider-children parent)))
  (cond ((inference-p parent)
	 (setf (inference-base-value task)
	   (mvl-f-ground (lookup-with-vars prop :cutoffs
					   `((,(make-test :value unknown 
							  :tag 't-not-ge))))
			 bdg-to-truth-val)
	   (inference-truth-value task) (inference-base-value task)))
	((modal-clause-p parent)
	 (let ((temp (lookup-with-vars prop :cutoffs *success-test*)))
	   (when (mvl-eq temp (bilattice-true bdg-to-truth-val) 
			 bdg-to-truth-val)
	     (setf (inference-base-value task) temp
		   (inference-truth-value task) temp)))))
  (setf (inference-proof task) prop)
  (push task (analysis-active-tasks analysis))
  task)

;; lookup a proposition, and construct the truth value as an element of
;; bdg-to-truth-val.  In addition, if the thing is a conjunction, get a
;; truth value by conjoining the truth values of the components.

(defun lookup-with-vars (prop &key (cutoffs *always-succeeds*)
			 &aux conj-val as temp)
  (cond ((eq (car prop) 'not)
	 (mvl-not (lookup-with-vars (second prop)
				    :cutoffs (cutoffs-not cutoffs))
		  bdg-to-truth-val))
	(t (setq as (lookups prop :cutoffs cutoffs)
		 temp (if as (construct-bdg-val as)))
	   (cond ((and (eq (car prop) 'and)
		       (setq conj-val (conj-lookup-with-vars
				       (cdr prop) :cutoffs cutoffs)))
		  (if temp (mvl-plus temp conj-val bdg-to-truth-val) conj-val))
		 (temp)
		 (t (bilattice-unknown bdg-to-truth-val))))))

;; Here's where we look up a conjunction.  One thing: if we bind a variable
;; in an early conjunct, we want to make sure that the binding is passed to
;; subsequent conjuncts.  So bdgs is a list of all the bindings we've
;; accumulated thus far.
	
; Replaced Sept 16/91 per Ginsberg instructions, repaired Sept 17.
;
; Lucid is buggy for the following cases:
; 
;  Remove-if
; 
;  (setq a (list 2))
;  (eql a (remove-if #'(lambda (x) (= x 3)) a))
; 
; This SHOULD return NIL, but in fact returns T
;

;(defun conj-lookup-with-vars (props &key (cutoffs std-cutoffs)
;			      &aux (ans (bilattice-true bdg-to-truth-val))
;				   (bdgs (list nil)))
;  (dolist (prop props ans)
;    (setq ans (mvl-and ans (lookup-conjunct-with-vars prop bdgs cutoffs)
;		       bdg-to-truth-val))
;    (unless (setq bdgs (ans-bdgs ans))
;      (return (bilattice-unknown bdg-to-truth-val)))))

(defun conj-lookup-with-vars (props &key (cutoffs std-cutoffs)
			      &aux (ans (bilattice-true bdg-to-truth-val))
				   (bdgs (list nil)))
  (dolist (prop props ans)
    (let ((temp (lookup-conjunct-with-vars prop bdgs cutoffs)))
      (setq ans (mvl-and ans temp bdg-to-truth-val))
     )
    (unless (setq bdgs (ans-bdgs ans))
      (return (bilattice-unknown bdg-to-truth-val)))))

;; lookup a single conjunct.  bdgs are the bindings from previous conjuncts

(defun lookup-conjunct-with-vars (prop bdgs cutoffs)
  (reduce (bilattice-plus bdg-to-truth-val)
	  (napcar #'(lambda (b) (lcwv-1 prop b cutoffs)) bdgs)))

(defun lcwv-1 (prop bdg cutoffs)
  (include-bdg-in-truth-value
   bdg (lookup-with-vars (plug prop bdg) :cutoffs cutoffs)))

;; What bindings do we have so far?  The point is that we don't want to
;; include anything more specific than something we've already got, since
;; it won't affect future lookups.  So as soon as the root value is ok to
;; return, we return that.  If the root value is unknown, we look at the
;; rest values.

; Replaced Sept 16 per discussion with Ginsberg
;(defun ans-bdgs (val &aux (ans (remove-if #'(lambda (x)
;					      (t-le (dag-val x) unknown))
;					  (dag-fn-list val))))
;  (napcar #'car ans)
;  (delete-subsumed-entries ans #'(lambda (x y) (binding-le x y))))

(defun ans-bdgs (val &aux (ans (delete-if #'(lambda (x)
					      (t-le (dag-val x) unknown))
					  (copy-list (dag-fn-list val)))))
  " New version  - sept 16/91 "
  (napcar #'car ans)
  (delete-subsumed-entries ans #'(lambda (x y) (binding-le x y))))

;; construct an element of bdg-to-truth-val from a list of answers.
;; *** THIS FUNCTION IS DESTRUCTIVE ***

(defun construct-bdg-val (answers)
  (dag-accumulate-fn binding-dag *active-bilattice*
		     (napcar #'(lambda (ans) (cons (answer-binding ans)
						   (answer-value ans)))
			     answers)
		     :modifier #'mvl-plus))

;; Invoke the prover.  Choose a task and invoke the prover to get a
;; new answer and list of conjuncts used.  (The answer will be nil if
;; the prover terminated without success.)  If the prover terminated,
;; mark the task as inactive.  If the prover succeeded, act on that.

;; It's made a bit more subtle by the relevance computations.  The details
;; are as follows:
;;
;; 1.  If the task needs to be rechecked, flush the list of answers known
;; to be relevant or irrelevant.
;; 2.  If the task doesn't have an associated proof effort:
;;   a.  If TRUE would be relevant, initialize the task.
;;   b.  If TRUE would not be relevant, give up.  Pop the task from the list
;;   of active tasks and mark it as inactive.  Return NIL.
;; 3.  Save the current list of pending answers.  (If you fail to generate
;; a new relevant answer, it is only the *currently* pending answers that
;; potentially need to be rechecked.)
;; 4.  Invoke the prover.
;;   a.  If a relevant answer is returned, set up any new tasks and return
;;   from consider-step.
;;   b.  If none is found, and you have to recheck the pending answers, do
;;   that.  If one is found, act on it and return.
;;   c.  If no pending answer is relevant, make the task as inactive and
;;   return.

(defun consider-step (&aux (task (choose-task)) pending
			   (proof (inference-proof task)))
  (when (inference-recheck task)
    (setf (inference-relevant task) nil
	  (inference-irrelevant task) nil))
  (unless (proof-p proof)
    (cond ((relevant-ans (make-answer) task)
	   (setf proof (init-prover (inference-proof task) task)
		 (inference-proof task) proof))
	  (t (popf (analysis-active-tasks analysis) task :count 1)
	     (setf (inference-status task) 'inactive)
	     (return-from consider-step nil))))
  (setq pending (inference-pending task))
  (or (do ((ans (cont-prover proof) (cont-prover proof)))
	  ((null ans))
	(cond ((relevant-ans ans task)
	       (cs-1 ans task nil)
	       (return t))
	      (t (cs-1 ans task t)
		 (push ans (inference-pending task)))))
      (when (inference-recheck task)
	(dolist (ans pending)
	  (when (relevant-ans ans task)
	    (cs-1 ans task nil)
	    (popf (inference-pending task) ans :count 1)
	    (return t))))
      (progn 
	(setf (inference-status task) 'inactive)
	(popf (analysis-active-tasks analysis) task :count 1))))

;; Here, we just found a new answer to the given task.  We find the meaningful
;; bindings, set up the conjunction that is to be considered by subsequent
;; tasks, inform the user and invoke prover-succeeded to set up any new
;; subsidiary tasks.

(defun cs-1 (ans task pending
	     &aux (new-bdg (meaningful-bdgs (answer-binding ans)
					    (proof-vars proof)))
		  (conj (just-plug (bcanswer-just ans)
				   (answer-binding ans))))
  (when (traced-task task) (prover-show-return new-bdg conj pending))
  (unless pending (prover-succeeded task new-bdg conj)))

;; pick a task to work on.  Pick the one with the smallest depth.

(defun choose-task (&aux (poss (analysis-active-tasks analysis))
			 best best-depth depth)
  (when poss
    (setq best (pop poss) best-depth (task-depth best))
    (dolist (task poss best)
      (when (< (setq depth (task-depth task)) best-depth)
	(setq best task best-depth depth)))))

(defun task-depth (task &aux (parent (consider-parent task)))
  (if parent (1+ (task-depth parent)) 0))

;; What to do if the prover succeeded.  We begin by finding those
;; conjuncts that only returned a truth value, so that we don't need to
;; attempt to process their negations to defeat the original proof.
;; lookup-flag is used to record the number of these conjuncts.  Then we
;; remove all of those conjuncts from conj and spawn the new task.

(defun prover-succeeded (task bdg conj &aux (lookup-flag 0) (lookup true))
  (dolist (item conj)
    (when (eq (car item) 'truth-value)
      (setq lookup (mvl-and lookup (second item)))
      (incf lookup-flag)))
  (unless (zerop lookup-flag)
    (setq conj (delete 'truth-value conj :key #'car :count lookup-flag)))
  (spawn-new-task task bdg (recompute-conj conj) lookup))

;; what conjuncts should be passed off for the next proof task?  The only
;; conjuncts that you need to combine are the nonmodal ones.  These are
;; kept in new-conj; the others are kept in old-conj.

(defun recompute-conj (conj &aux new-conj old-conj)
  (dolist (item conj)
    (if (eq (car item) 'modal)
	(push item old-conj)
      (push item new-conj)))
  (if new-conj (cons (conj-to-logic new-conj) old-conj) old-conj))

;; tasks resulting from successful proof effort when new tasks need to be
;; spawned.  Arguments are:
;;   task that succeeded
;;   binding returned
;;   conjuncts used (does not include truth value due to looked-up terms)
;;   truth value due to procedurally looked-up terms
;;
;; First, for each item that has to be spawned as a subtask, generate
;; the subtask.  Following this, we add a new justification to the
;; justification list of the given task.  This justification includes
;; a dummy task that records any looked-up truth value.

(defun spawn-new-task (task bdg conj lookup)
  (napcar #'(lambda (x)
	      (generate-task (if (eq (car x) 'modal) x (negate x)) task))
	  conj)
  (setq conj (nreverse conj))
  (recompute-just task bdg (if (mvl-eq lookup true) conj
			     (cons (make-inference
				    :truth-value
				    (make-root binding-dag *active-bilattice*
					       (mvl-not lookup))
				    :status 'dead :parent task)
				   conj)))
  (recompute-truth-value task))

;; recompute the justification of a specific task, given a new
;; justification and a new binding.  First find any existing
;; justification; if so, just add in the new justification (they are
;; both elements of the atms lattice).  If not, stick a new entry onto
;; the justification list.  In the code that follows, j is the result of
;; turning the new justification into an element of the atms lattice.

(defun recompute-just (task bdg just &aux (temp (find-just task bdg)))
  (if temp
      (setf (cdr temp) (djl-simplify (cons just (copy-list (cdr temp)))))
    (push (list bdg just) (inference-just task))))

;; given a task and a binding, is there justification information for
;; that binding already on the task's justification list?  Return that
;; element of the justification list if so or NIL if not.

(defun find-just (task bdg)
  (find bdg (inference-just task) :test #'equal-binding :key #'car))

;; remove leading negations from a proposition.  Returns two values --
;; 2nd is t if an odd number of negations were encountered and nil
;; otherwise.

(defun strip-nots (prop)
  (do ((p prop (second p)) (inv nil (not inv)))
      ((not (eq (car p) 'not)) (values p inv))))

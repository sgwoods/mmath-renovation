; MINI-TWEAK.LSP  -  A Simplified Version of Chapman's Non-Linear Planner TWEAK
; (See Chapman's AI journal article, Vol. 32, 1987, pp. 333-377.)

; To run the planner, define a set of operators, then provide
; initial and goal state descriptions to the function MINI-TWEAK.

; Copyright (C) 1988 by Jude William Shavlik.
;       This program may be freely copied, used, or 
;       modified provided that this copyright notice 
;       is included in each copy of this code and parts thereof.

;; ******************** SIMPLIFYING ASSUMPTIONS ********************
;   Assume no variables - ie, use propositional rules only
;   (hence no need for TWEAK's separation technique).
;   Rules must be conjunctive and can only contain LITERALS.
;   That is, atomic predicates (represented as Lisp atoms) and their 
;   negations - represented as (NOT <lisp atom>).
;   See the files "~cs731/SAMPLE-TWEAK.DATA" 
;   and "~cs731/LENS-MAKER.DATA" for examples.

;   Don't perform backtracking.
;    - goes as far as possible, then state
;      partial plan as of time when "stuck."
;    - repeats this *tries* times 
;      (crude form of nondeterministic problem solving
;       - be sure to use CHOOSE-ONE-RANDOMLY when making arbitrary choices)

;   - evaluate (run-mini-tweak) for the first and for the second
;     evaluate (run-mini-tweak '(SAND) '(REFLECTIVE-LENS) 
;                              "/home/inst/0/cs731/LENS-MAKER.DATA")
;   The flag
;   *TRACE-TWEAK* controls how much information is provided by MINI-TWEAK.

;   (Note:  Our Common Lisp (KCL) cannot handle the "~" notation for
;   pathways.  You have to provide the complete path to the LOAD function for
;   files located outside of the directory in which you're working.)

;   ************************ Representing Plan Steps ************************
; TWEAK works by inserting steps (operator applications) into a plan to achieve
; goals, partially ordering them to avoid conflicts.  
;  In MINI-TWEAK, assume a plan step is presented by two states - 
;  the time immediately before the plan step and
;  the point in time immediately after it. 
;  (Except for the initial and goal states,
;all states arise from operator applications.)  Say MINI-TWEAK needs to achieve
;  predicate P in state S and chooses to use operator O.  
;  You should generate two
;   new states, S-before and S-after, and assert the following constraints:
;                    (BEFORE S0  S-before)
;                    (CONTIGUOUS S-before S-after)
;                    (BEFORE S-after  S).
;  It actually is not necessary that S-after occur before S - they could be the
;   same state.  However, it is a mistake to REQUIRE them to be the same state,
;   because you later may have to insert a step between S-after and S.
;   The CONTIGUOUS constraint prevents the insertion of a step between S-before
;  (and S-after.)

;   Assuming O has the preconditions {A1,A2} and the effects {P,E1}, you should
;   assert that P and E1 hold in state S-after (not S necessarily).  You should
;   also post the new subgoals of achieving A1 and A2 in state S-before.

;   You need not figure out at the end that some state Sa and
;   another state Sb can be equated.  We will assume that the plan executor
;   module (which you are not to write) realizes that if Sa must be before Sb
;   and no operator must be applied between these two states, then these two
;   states can be equated.  TWEAK insures that no inconsistencies result.

; ---------------------------------------------------------------------------
;                  Global Variables and Defstructs used in MINI-TWEAK
; ---------------------------------------------------------------------------

(defvar *operators* nil
  "A list of the operators known to MINI-TWEAK.  See the function BUILD-OPERATOR for
   assistance.  Be sure to clear *operators* before using this assistant function.
   Each list ELEMENT is an OPERATOR defstruct.")

(defstruct operator
  "Operators are named and defined by what literals must be true for them to apply
   (their preconditions) and what literals they make true or false (their effects).
   Both the preconditions and effects are lists of the form ( P Q (NOT R) )."
  (name         'unnamed)
  (preconditions nil)
  (effects       nil)
)

; The next four global variables hold plan-related information.

(defvar *states*               nil "Unordered list of states involved in the plan.")

(defvar *ordering-constraints* nil
  "Unordered list of statements about the temporal ordering of states in the plan.
    E.g., ( (before s1 s2)     (after s8 s11)   (contiguous s19 s20) 
            (initial-state s0) (final-state sN)  ...)
    Note:  Only use the literals BEFORE, AFTER, INITIAL-STATE, FINAL-STATE, and
           CONTIGUOUS.  All arguments must be states.")

(defvar *active-goals*  nil
  "Unordered list of the literals that must be achieved by TWEAK
    - a list of dotted pairs, i.e. ( ... (<literal> . <state>) ... )")

(defvar *achieved-literals*  nil
  "Unordered list of the literals that have been achieved by TWEAK
    - each item in this list is a STEP defstruct which records how they were achieved.
    - note: the literals need not have been goals; can be other effects of operators.")

(defvar *achieved-goals*  nil
  " Goals achieved by TWEAK (note: these are a subset of *achieved-literals*)
    - a list of dotted pairs, i.e. ( ... (<literal> . <state>) ... )")
 
(defstruct step
  "An STEP records how literals where achieved."
  (result  'unknown)  ;The literal asserted as a result of the action.
  (op      'USER)     ;The operator used (USER creates the initial state).
  (from    'S0)       ;State in which operator is applied.
  (to      'S0)       ;State produced by the operator.
)

(defvar *stuck* nil "Indicates that backtracking is necessary.")
(defvar *tries*  3  "Number of tries at a 'random' solution until giving up.")

(defvar *trace-tweak*   T "When true, reports operation of MINI-TWEAK.")
(defvar *trace-manager* T "When true, reports operation of the constraint manager.")

(setf *print-gensym* nil) ;Print gensyms more "neatly" (a standard Common Lisp global).

; --------------------------------------------------------------------------
;                         The Main Functions
; --------------------------------------------------------------------------

(defun run-mini-tweak (&optional 
		       (initial-state-literals '(P (NOT Q)))
		       (goal-state-literals    '((NOT P) Q (NOT R)))
		       (operator-file "/u/sgwoods/Plan/Mini-Tweak/example"))
  "Run the MINI-TWEAK system."
  (setf *operators* nil)
  (load operator-file)  
  (mini-tweak initial-state-literals goal-state-literals))

(defun mini-tweak (initial-state-literals goal-state-literals &aux (try 1))
  "Provide an initial state description, a desired final state description, and see
   what TWEAK comes up with as a plan for getting from one to the other."
  ;;Note - must provide two LISTS of literals.
  (format t "~%~%From the initial state S0:")
  (dolist (literal initial-state-literals) (format t " ~A" literal))
  (format t "~%Reach the goal state SN:  ")
  (dolist (literal goal-state-literals)    (format t " ~A" literal))
  (format t "~%~%")
  (loop
   (reset-mini-tweak initial-state-literals goal-state-literals)
   ;; Now must satisfy all of the active goals.
   (loop
    (if (or *stuck*                ;Unless stuck,
	    (null *active-goals*)) ;continue as long as there are literals to satisfy.
	(return)
      (let* ((chosen-goal (choose-one-randomly *active-goals*))
	     (p (first chosen-goal))
	     (s (rest chosen-goal)))
	(trace-print *trace-tweak* "~%Trying to achieve ~A in state ~A.~%" p s)
	(trace-print *trace-tweak* " Establishing ~A ...~%" p)
	(establish-literal-p-in-state-s p s) ;If "stuck", set *stuck*.
	(trace-print *trace-tweak* " Checking for clobberers of ~A ...~%" p)
	(remove-any-clobbers-of-p p s)
	(unless *stuck*
	  (push chosen-goal *achieved-goals*)
	  (setf *active-goals* (delete chosen-goal *active-goals*))))))
   ;;Finally, report plan constructed.
   (report-constructed-plan try)
   (unless *stuck* (return 'success)) ;See if a successful solution found.
   (incf try)  ;Keep trying until a complete solution found, or until
   (if (> try *tries*) ;the maximum number of tries exceeded. 
       (return 'failure)
     (wait-for-ack *trace-tweak*))))

(defun establish-literal-p-in-state-s (p s)
  "See if literal P holds in state S, otherwise add a plan step that achieves it."
  ;;Top half of Fig. 7.
  (cond ((p-established-in-earlier-situation? p s)
	 t) ;No need to do anything.
	((can-constrain-step-that-establishes-p-to-occur-before-s? p s)
	 ;See if an existing state can be constrained to occur before s.
	 (constrain-step-that-establishes-p-to-occur-before-s p s))
	((can-add-step-that-establishes-p? p s)
	 ;See if a new state can be added and constrained to occur before s.
	 (add-step-that-establishes-p p s))
	(t ;Stuck!
	 (format t "~%**** Need to backtrack to satisfy ~A in state ~A ****"
		 p s)
	 (setf *stuck* t)))) ;Wish to stop this loop of MINI-TWEAK.

(defun remove-any-clobbers-of-p (p s)
  "See if anything is preventing P from holding in state S."
  ;;Bottom half of Fig. 7.
  (dolist (state (permute *states*)) ;Consider states non-deterministically.
    (unless (or (equal s state)      ;See if there is nothing to worry about.
		(earlier-state? s state)
		(not (p-clobbered-by-creator-of-state? p state))
		(white-knight-for-p-exists-between-state-and-s? p state s))
      ;;Must avoid a "clobbering."
      (if (equal state 'S0)
	  (trace-print *trace-tweak* "  ~A clobbered in state ~A by the USER.~%"
		       p state)
	(trace-print *trace-tweak* "  ~A clobbered in state ~A by ~A.~%" 
		     p state (operator-name (find-creating-operator p state))))
      (cond ((can-promote-the-clobberer? state s)
	     ;See if the clobberer can be moved after state s.
	     (promote-the-clobberer state s))
	    ((can-place-existing-white-knight-for-p-between-state-and-s? p state s)
	     ;See if an existing operator application that re-establishes p
	     ;can be constrained to occur between state and s.
	     (place-existing-white-knight-for-p-between-state-and-s p state s))
	    ((can-construct-new-white-knight-for-p-between-state-and-s? p state s)
	     ;See if an operator can be applied that re-establishes p.
	     (construct-new-white-knight-for-p-between-state-and-s p state s))
	    (t ;Stuck!
	     (format t "~%**** Need to backtrack to satisfy ~A in state ~A ****"
		     p s)
	     (setf *stuck* t)))))) ;Wish to stop this loop of MINI-TWEAK.

; ---------------------------------------------------------------------------
;                          Secondary Functions
; ---------------------------------------------------------------------------

; You are to define these.  Feel free to use the TRACE-PRINT facility
; so that MINI-TWEAK reports its progress.  
;  Also feel free to define additional 
; functions - add them in the TERTIARY FUNCTIONS group. 

(defun p-established-in-earlier-situation? (p s &aux answer)
  "See if this literal is somewhere in the list of achieved literals
   and arose in a state that occurs before S."
  (when (some #'(lambda (x) (and (equal p (step-result x))
				 (earlier-state? (step-to x) s)
				 (setf answer x)))
	      *achieved-literals*)
    (when *trace-tweak*
      (format t "  ~A was established previously~%" p)
      (if (equal 'USER (step-op answer))
	  (format t "   - the USER said it holds in the initial state.~%")
	(format t "   - ~A produced ~A in state ~A from state ~A.~%" 
		(operator-name (step-op answer)) p (step-to answer) (step-from answer))))
    T))

(defun can-constrain-step-that-establishes-p-to-occur-before-s? (p s)
  "See if this literal is somewhere in the list of achieved literals
   and is achieved from a state that is unconstrained wrt S."
  (some #'(lambda (x) (and (equal p (step-result x))
			   (s1-and-s2-unrelated? (step-from x) s)))
	*achieved-literals*))

(defun constrain-step-that-establishes-p-to-occur-before-s (p s)
  "Non-deterministically find a constrainable state and constrain it."
  (dolist (achieved (permute *achieved-literals*))
    (when (and (equal p (step-result achieved))
	       (s1-and-s2-unrelated? (step-from achieved) s))
      (trace-print *trace-tweak* 
		   "  Constraining ~A to be before ~A~%  - so that ~A holds in ~A.~%" 
		    (step-to achieved) (get-earlier-partner s) p (get-earlier-partner s))
      (add-a-before-constraint (step-to achieved) s)
      (return))))  ;Have to stop once one is found.

(defun can-add-step-that-establishes-p? (p s)
  "See if there is an operator that asserts P."
  (declare (ignore s)) ;Tell compiler than variable S is not used.
  (some #'(lambda (op) (member p (operator-effects op) :test #'equal))
	*operators*))

(defun add-step-that-establishes-p (p s)
  "Non-deterministically patch in an operator that asserts P.
   Returns the two new states between which the operator is to be applied."
  (dolist (op (permute *operators*))
    (when (member p (operator-effects op) :test #'equal)
      (return (create-plan-step op p s)))))

(defun p-clobbered-by-creator-of-state? (p state &aux (positive-literal? (atom p)))
  "Was negating P one of the effects of the operator that created STATE?"
  (some #'(lambda (x) (and (equal state (step-to x)) ;Make sure this created STATE.
			   (if positive-literal? 
			       (equal `(NOT , p) (step-result x))    ;Look for NOT(P).
			     (equal (second p)   (step-result x))))) ;Look for P.
	*achieved-literals*))

(defun can-promote-the-clobberer? (state s)
  "See if STATE can be constrained to occur after S."
  ;;To prevent unnecessary backtracking, never promote S0.
  (s1-and-s2-unrelated? state s))

(defun promote-the-clobberer (state s)
  "State must occur after S."
  (trace-print *trace-tweak* "  Promoting the clobber ~A to occur after ~A.~%"
	       (get-earlier-partner state) (get-later-partner s)) 
  (add-an-after-constraint (get-earlier-partner state) (get-later-partner s)))

(defun white-knight-for-p-exists-between-state-and-s? (p state s)
  "See if P asserted by some action that took place between STATE and S."
  (some #'(lambda (x) (and (equal p (step-result x)) ;Make sure this involves P.
			   (s2-in-between-s1-and-s3? state (step-from x) s)))
	*achieved-literals*))

(defun can-place-existing-white-knight-for-p-between-state-and-s? (p state s)
  "See if some action established P and the state in which this action
   occurred is not known to be BEFORE STATE nor AFTER S."
  (some #'(lambda (x) (let ((apply-state (step-from x)))
			(and (equal p (step-result x)) ;Make sure this involves P.
			     (not (earlier-state? apply-state state))
			     (not (earlier-state?     s    apply-state)))))
	*achieved-literals*))

(defun place-existing-white-knight-for-p-between-state-and-s (p state s)
  "Non-deterministically constrain a white knight between STATE and S."
  (dolist (achieved (permute *achieved-literals*))
    (when (let ((apply-state (step-from achieved)))
	    (and (equal p (step-result achieved)) ;Make sure this involves P.
		 (not (member apply-state '(S0 SN))) ;Dont move these.
		 (not (earlier-state? apply-state state))
		 (not (earlier-state?     s    apply-state))))
      (trace-print *trace-tweak*  "  Constraining ~A to be between states ~A and ~A~%"
		   (step-from achieved) state s) 
      (trace-print *trace-tweak*  "   - so that ~A holds in ~A.~%" p s)
      (add-a-before-constraint (step-to achieved) s)
      (add-a-before-constraint state (step-from achieved))
      (return))))  ;Have to stop once one is found.

(defun can-construct-new-white-knight-for-p-between-state-and-s? (p state s)
  "See if there is an operator that asserts P that can be applied between STATE and S."
  (declare (ignore state)) ;Tell compiler this variable not used.
  (can-add-step-that-establishes-p? p s))

(defun construct-new-white-knight-for-p-between-state-and-s (p state s)
  "Non-deterministically apply an operator that achieves P.
   Apply this operator in a state between STATE and S."
  (let ((new-states (add-step-that-establishes-p p s)))
    ;;One additional constraint necessary; the operator must be applied
    ;;in STATE or later.  Using "later" here for simplicity.  The
    ;;corresponding assumption is made in ADD-STEP-THAT-ESTABLISHES-P in regards to S.
    (trace-print *trace-tweak*  "  Constraining ~A to be before ~A~%"
		 (get-later-partner state) (get-earlier-partner (first new-states)))
    (trace-print *trace-tweak*  
		 "   - to override state ~A's clobbering of ~A.~%" state p)
    (add-a-before-constraint state (first new-states))))

; -------------------------------------------------------------------------
;                          Tertiary Functions
; -------------------------------------------------------------------------

;          ***** Put any additional functions you write in this region. *****

(defun create-plan-step (op p s)
  "Create a new plan step defstruc; OP achieves literal P for use in state S.
   Add the preconditions of OP as new goals to achieve. 
   Return the list (from-state to-state) - OP acts between these two states."
  ;; Should use multi-value-return, but trying to avoid advanced lisp constructs.
  (let ((new-from-state (generate-new-state))
	(new-to-state   (generate-new-state)))
    (trace-print *trace-tweak*  "  Using operator ~A in hypothesized state ~A~%"  
		 (operator-name op) new-from-state)
    (trace-print *trace-tweak*  "   to achieve ~A in hypothesized state ~A.~%" 
		 p new-to-state)
    (trace-print (and *trace-tweak* (> (length (operator-effects op)) 1))
		 "  - will also achieve ~A as a side effect.~%"
		 (remove p (operator-effects op) :test #'equal))
    ;;Add ALL the effects of OP - they all hold in state NEW-TO-STATE.
    (dolist (effect (operator-effects op))
      (push (make-step :result effect       :op op
		       :from new-from-state :to new-to-state) 
	    *achieved-literals*))
    ;;State orderings necessary:  S0 < Snew-from < Snew-to < S < SN
    ;;(By assumption, all created states occur after S0, while
    ;; by construction, all new states will be before SN.)
    ;;Strictly speaking, states NEW-TO-STATE and S could co-designate.
    ;;However, we'll assume that the plan executor "automatically"
    ;;goes from one state to the other when no operator is specified.
    ;;Post the preconditions as new subgoals for MINI-TWEAK.
    (add-a-before-constraint 'S0 new-from-state)
    (add-a-before-constraint new-to-state s)
    (add-a-contiguous-constraint new-from-state new-to-state)
    ;;Add OP's preconditions as new requests to the planner.
    (dolist (precondition (operator-preconditions op))
      (trace-print *trace-tweak* 
		   "   - have the subgoal that ~A holds in state ~A.~%"
		   precondition new-from-state)
      (pushnew (cons precondition new-from-state) *active-goals* :test #'equal))
    ;;Look to see if adding this step may clobber a previously achieved goal.
    (check-to-see-if-added-step-clobbers-achieved-goal op new-to-state)
    (list new-from-state new-to-state)))

; ---------------------------------------------------------------------------
;                     Functions for Managing Constraint Posting
; ---------------------------------------------------------------------------

; The functions in this step manage the posting of constraints.
; Redundant ordering constraints are removed.

(defun add-a-contiguous-constraint (stateA stateB)
  "Add the constraint that these two states must be contiguous (A<B), 
   because an operator transitions between them."
  (trace-print *trace-manager* "     <adding the constraint (CONTIGUOUS ~A ~A)>~%" 
	       stateA stateB)
  (check-for-redundant-constraints stateA stateB) ;(must be before next line)
  (pushnew `(contiguous ,stateA ,stateB) *ordering-constraints* :test #'equal))

(defun add-a-before-constraint (early-state late-state)
  "If necessary, add the constraint (BEFORE early-S late-S)."
  ;;The simplifications below shouldnt be used if backtracking is implemented.
  (unless (and (earlier-state? early-state late-state)
	       (or (trace-print 
		    *trace-manager*
		    "     <the constraint (BEFORE ~A ~A) is already known>~%"
		    early-state late-state)
		   t))
    (trace-print *trace-manager* "     <adding the constraint (BEFORE ~A ~A)>~%" 
		 early-state late-state)
    ;;Look if any other constraints are now redundant.
    (check-for-redundant-constraints early-state late-state)
    (push `(before ,early-state ,late-state) *ordering-constraints*)))

(defun check-for-redundant-constraints (early-state late-state &aux theDs)
  "Given EARLY < LATE, see if any other ordering constraints can be removed safely."
  ;;If adding  A<B, then for all C s.t. B<=C
  ;;                       for all D s.t. D<=A can remove D<C.
  ;;     D <= A < B <= C
  ;;  [Note: Will not "kill" A<B, since this constraint not yet added.]
  ;;This is a very time intensive function.  Probably O(N^5-6), where N
  ;;is the number of states, assuming #constraints=O(# states) and
  ;;depending on the efficiency of EARLIER-STATE?.  This could
  ;;be improved, but regardless it is a good idea to at least have
  ;;EARLIER-STATE? compiled.
  (dolist (stateD *states*)  ;Need compute the D's one time only.
    (when (or (equal stateD early-state) (earlier-state? stateD early-state))
      (push stateD theDs)))
  (dolist (stateC *states*) ;Now look for C's.
    (when (or (equal late-state stateC) 
	      (and (not (member stateC theDs)) ;Assume this saves time.
		   (earlier-state? late-state stateC)))
      (dolist (stateD theDs)
	  (remove-this-before-constraint stateD stateC)))))
  
(defun remove-this-before-constraint (stateA stateB)
  "If it appears in the list of constraints, remove (BEFORE stateA stateB)."
  (trace-print (and *trace-manager* (member `(BEFORE ,stateA  ,stateB)
					  *ordering-constraints* :test #'equal))
	       "     <because of transitivity, can delete (BEFORE ~A ~A)>~%"
	       stateA stateB)
  (setf *ordering-constraints* (delete `(BEFORE ,stateA ,stateB)
				       *ordering-constraints*  :test #'equal)))))

(defun add-an-after-constraint (late-state early-state)
  "If necessary, add the constraint (AFTER late-state early-state)."
  ;; Express everything in turns of BEFORE's for convenience.
  (add-a-before-constraint early-state late-state))

; ---------------------------------------------------------------------------
;                     Some Useful Support Functions
; ---------------------------------------------------------------------------

(defun check-to-see-if-added-step-clobbers-achieved-goal (operator resulting-state)
  "See if including this step may clobber a predicate previously achieved."
  (dolist (already-achieved *achieved-goals*) ;Look at all achieved goals.
    (let ((p (first already-achieved))
	  (s (rest  already-achieved)))
      (unless (or (equal s resulting-state)      ;See if there is nothing to worry about.
		  (earlier-state? s resulting-state)
		  (not (p-clobbered-by-creator-of-state? p resulting-state))
		  (white-knight-for-p-exists-between-state-and-s? p resulting-state s))
	;;When there is a problem, remove this goal from the achieved list
	;;and put it back on the list of active goals.
	(trace-print *trace-tweak* 
		     "  ~A may clobber the previously achieved goal of ~A holding in ~A~%"
		     (operator-name operator) p s)
	(trace-print *trace-tweak* 
		     "   - so ~A holding in ~A reinstated as an active goal.~%"
		     p s)
	(setf *achieved-goals* (delete already-achieved *achieved-goals*))
	(push already-achieved *active-goals*)))))

(defun earlier-state? (s state)
  "Does S DEFINITELY occur before STATE?"
  (dolist (constraint *ordering-constraints* nil)
    (case (first constraint)
      (BEFORE     (if (and (equal (third  constraint) state)
			   (or (equal s (second constraint))
			       (earlier-state? s (second constraint))))
		      (return t))) ;Use transitivity if necessary.
      (AFTER      (if (and (equal (second constraint) state)
			   (or (equal s (third  constraint))
			       (earlier-state? s (third  constraint))))
		      (return t))) ;Use transitivity if necessary.
      (CONTIGUOUS (if (and (equal (third  constraint) state)
			   (or (equal s (second constraint))
			       (earlier-state? s (second constraint))))
		      (return t))) ;Use transitivity if necessary.
      (OTHERWISE nil))))) ;Ignore this constraint.

(defun contiguous-states? (s1 s2)
  "Are these two states the 'anchor' points of an operator application?"
  (member `(CONTIGUOUS ,s1 ,s2) *ordering-constraints* :test #'equal))

(defun get-later-partner (state)
  "If this state is known to be contiguous to another, 
   return the LATER partner.  If not contiguous, then return STATE."
  (dolist (constraint *ordering-constraints* state)
    (when (and (equal 'CONTIGUOUS (first constraint))
	       (or (equal state (second constraint))
		   (equal state (third  constraint))))
      (return (third constraint)))))

(defun get-earlier-partner (state)
  "If this state is known to be contiguous to another, 
   return the EARLIER partner.  If not contiguous, then return STATE."
  (dolist (constraint *ordering-constraints* state)
    (when (and (equal 'CONTIGUOUS (first constraint))
	       (or (equal state (second constraint))
		   (equal state (third  constraint))))
      (return (second constraint)))))

(defun s1-and-s2-unrelated? (s1 s2)
  "Are states S1 and state S2 unrelated?"
  (and (not (equal s1 s2))
       (not (earlier-state? s1 s2))
       (not (earlier-state? s2 s1))))

(defun s2-in-between-s1-and-s3? (s1 s2 s3)
  "Are these three states ordered this way?"
  (and (earlier-state? s1 s2) (earlier-state? s2 s3)))

(defun find-creating-operator (p state &aux (positive-literal? (atom p)))
  "Find an operator that created STATE and clobbered P."
  (dolist (achieve *achieved-literals*)
    (when (and (equal state (step-to achieve));Make sure it created STATE and added P.
	       (if positive-literal? 
		   (equal `(NOT , p) (step-result achieve)) ;Look for NOT(P).
		 (equal (second p) (step-result achieve)))) ;Look for P.
      (return (step-op achieve)))))

(defun reset-mini-tweak (initial-state-literals goal-state-literals)
  "Reset the system and assert these literals hold in the initial state."
  (unless *operators* (error "No operators defined!"))
  (gensym 0) ;Zero the gensym counter.
  (setf *stuck* nil)
  (setf *states*  '(SN S0))      ;States known to exist.
  (setf *ordering-constraints*   ;Provide info on the initial and goal states.
	'((FINAL-STATE SN) (INITIAL-STATE S0)))
  (add-a-before-constraint 'S0 'SN)
  (setf *achieved-goals* nil)
  (setf *achieved-literals* nil) ;Clear, then refill with literals about
  (dolist (literal initial-state-literals) ;the initial state.
    (pushnew (make-step :result literal) *achieved-literals* :test #'equalp))
  ;;Assert all what must hold in the final state, before turning TWEAK loose.
  (setf *active-goals* nil)      ;Clear the list of unsatisfied goals.
  (dolist (literal goal-state-literals) ;Assert the goal literals.
    ;;Must mark literals by state, as same literal may have to hold
    ;;in several states.
    (trace-print *trace-tweak* "Have the subgoal that ~A holds in state ~A.~%"
		 literal 'SN)
    (pushnew (cons literal 'SN) *active-goals* :test #'equal)))

(defun report-constructed-plan (N)
  "Report the (possibly partial) plan constructed."
  (if *stuck*
      (progn (format t "~%~%The Partial Plan Constructed (on ~:R try)~%" N)
	     (dolist (goal (reverse *active-goals*))
	       (format t " * did not achieve literal ~A in state ~A *~%" 
		       (first goal) (rest goal))))
    (format t "~%~%The Complete Plan Constructed (on ~:R try)~%" N))
  (format t "   (Sorting states.  Please wait ...")
  ;;[I'm not sure this sorting works with partially ordered plans.  Any comments?]
  (let ((complete-order (stable-sort (reverse *states*) #'earlier-state?))
	(constraints (reverse *ordering-constraints*)))
    ;;If there's no constraint, then stable sorting will keep in order created.
    (format t " done.)~%~%One consistent ordering of the states:~%  ")
    (dolist (state complete-order)
      (format t " ~A" state))
    (format t ".~%     (NOTE: The sorting algorithm does not necessarily~%")
    (format t "             correctly sort partially ordered items.)~%~%")
    (dolist (state complete-order) ;Consider what's known about each state.
      (dolist (item (reverse *achieved-goals*))
	(when (equal state (rest item)) ;Look at goals.
	  (format t " ~A was needed in state ~A.~%"(first item) (rest item))))
      (dolist (item (reverse *achieved-literals*))
	(when (equal state (step-to item)) ;Look for operator effects.
	  (if (equal (step-op item) 'USER)
	      (format t " ~A holds in the initial state.~%" (step-result item))
	    (format t " From ~A operator ~A produced ~A in ~A.~%"
		    (step-from   item) (operator-name (step-op item))
		    (step-result item) (step-to item)))))
      (dolist (item constraints)
	(when (equal state (second item))
	  (case (first item)
	    (INITIAL-STATE
	     (format t " State ~A is the initial state.~%"
		     (second item)))
	    (FINAL-STATE
	     (format t " State ~A is the final state.~%"
		     (second item)))
	    (BEFORE
	     (format t " State ~A must occur before state ~A.~%" 
		     (second item) (third item)))
	    (AFTER
	     (format t " State ~A must occur after  state ~A.~%" 
		     (second item) (third item)))
	    (CONTIGUOUS
	     (format t " States ~A and ~A are contiguous.~%" 
		     (second item) (third item)))
	    (OTHERWISE
	     (error "Bad temporal constraint -> ~A" item)))))))
  (format t "~%"))

(defmacro build-operator (name preconditions effects)
  "Build an operator defstruct and add it to the list of operators."
  `(pushnew (make-operator :name          (quote ,name) 
			   :preconditions (quote ,preconditions)
			   :effects       (quote ,effects))
	*operators* :test #'equal))

(defun generate-new-state (&aux (new-state (gensym "S")))
  "Generate an intermediate state."
  ;;Note: it seems KCL uses some gensym's "internally", so
  ;;some state numbers will be missing (this problem disappears when compiled).
  (push new-state *states*)
  new-state)

; ---------------------------------------------------------------------------
;                     Problem-Independent Functions
; ---------------------------------------------------------------------------

(defun choose-one-randomly (list)
  "Randomly choose an element in this list."
  (nth (random (length list)) list))

(defun permute (list)
  "Randomize the order of the elements in this list."
  ;;Understanding this function will give you practice with the advanced Lisp
  ;;constructs MAPCAR, LAMBDA, and #' (shorthand for FUNCTION).
  (mapcar #'(lambda (pair) (rest pair))
	  (sort (mapcar #'(lambda (item) (cons (random 1000) item)) list)
		#'(lambda (a b) (> (first a) (first b))))))

(defmacro trace-print (test-var &rest format-form)
  "Debugging aid for reporting program progress."
  `(if ,test-var (format t ,@format-form)))

(defmacro wait-for-ack (test-var)
  "Pause until user presses ENTER (LF/CR).  
   Note: Buggy in KCL for some reason.  First read-char 'swallowed.'"
  `(if ,test-var
       (progn (format t "Press <enter> to continue ")
	      (read-char))))


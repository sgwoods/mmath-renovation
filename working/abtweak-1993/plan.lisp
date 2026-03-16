; 
; (plan ...) is the main routine that invokes either abtweak or tweak.
;

(defun plan (initial goal &key 
			     
                                 (planner-mode 'abtweak)
				 (continue-p nil)
                                 (mp-mode  t)
                                 (mp-weak-mode 'nec)
                                 (abstract-goal-mode  t) 
                                 (drp-mode         nil)
                                 (left-wedge-mode t)
                                 (subgoal-determine-mode  'stack)
                                 (debug-mode      nil)
				 (drp-debug-mode nil)
                                 (heuristic-mode 'num-of-unsat-goals)
                                 (use-primary-effect-p  nil)
                                 (expand-bound      1000)
                                 (generate-bound   1000)
                                 (open-bound       1000)
				 (output-file t)  ;t/'no-output
				 (cpu-sec-limit 300)   ; 5 min
				 (init-plan nil)
				 (control-strategy 'bfs) ; or dfs.
				 (existing-only nil)
				 (solution-limit 100)
				 (abs-branching-limit 5)
				 (tc-mode nil)
               )
  "/Plan/plan.lsp
   initialize a plan, and invoke a search routine for 
   A* search.

   initial ---set of initial conditions  
   goal    ---set of goal conditions            "

  (declare 
        (type list initial)               
        (type list goal) 
        (type atom planner-mode)            ; tweak / abtweak / mr /mr-crit
        (type atom mp-mode)                 ; t/nil
        (type atom mp-weak-mode)            ; nec/pos
        (type symbol abstract-goal-mode)      ; t / nil
        (type symbol drp-mode)             ; t / nil
        (type symbol left-wedge-mode)      ; t/ nil
        (type atom subgoal-determine-mode)  ; random / tree / stack
        (type symbol debug-mode)            ; t / nil
        (type atom    heuristic-mode)        ; 'num-of-ops 
        (type symbol use-primary-effect-p)  ; t/nil
        (type integer expand-bound)
        (type integer generate-bound)
        (type integer open-bound)
	(type atom tc-mode)    ; t/nil
   )

  ; set control global flags (default values specified in planner function)
  (initialize-global-variables
   planner-mode continue-p mp-mode mp-weak-mode abstract-goal-mode 
   drp-mode left-wedge-mode subgoal-determine-mode debug-mode
   heuristic-mode use-primary-effect-p expand-bound
   generate-bound open-bound output-file cpu-sec-limit drp-debug-mode
   control-strategy existing-only  abs-branching-limit
   tc-mode)
  (setq *solution-limit* solution-limit)
  (let* (
         (initial-plan (if init-plan init-plan
			 (make-initial-plan initial goal))))

    (declare (type plan initial-plan))
    (setq *solution* initial-plan)
    ;;for the purpose of aborting successfully, should any
    ;;unexpected events occur.
    (if *use-primary-effect-p* 
	(setf (operator-primary-effects
	       (first (plan-a initial-plan))) ; initial operator
	      (operator-effects
	       (first (plan-a initial-plan)))))
    (let ((search-result (A-search initial-plan)))
      ;; Some historical failure paths return NIL without updating *solution*.
      ;; Preserve the successful initial-plan case, but avoid reporting the
      ;; untouched seed plan as if it were a real search result on failure.
      (when (and (null search-result)
                 (eq *solution* initial-plan))
        (setq *solution* 'open-exhausted))
      (output-solution-information    
       search-result :output output-file))
    ))


; ---- make-initial-plan ----

(defun make-initial-plan (initial goal)
  "/Planner/planner.lsp
    returns an initial plan - based on *planner-mode*"
  (declare
        (type list initial)
        (type list goal) )

  (if (or (eq *planner-mode* 'abtweak)
	  (eq *planner-mode* 'mr-crit))
      (ab-make-initial-plan initial goal)
      (tw-make-initial-plan initial goal)))


; --- termination ---

(defun goal-p (state)
  "/Abtweak/plan.lsp
    Abtweak/Tweawk/MR planning termination condition."
  (declare 
      (type plan state) )
  (cond((eq *planner-mode* 'abtweak)
	(ab-goal-p state))
       ((or (eq *planner-mode* 'mr)
	    (eq *planner-mode* 'mr-crit))
	(mr-goal-p state))
       (t (tw-goal-p state))))
      
; --- successors generation ---

(defun successors&costs (plan)
  "/planner/planner.lsp
    returns a list of successor states and costs."
  (declare (type plan plan) )

  (cond
   ((or (eq  *planner-mode* 'mr)
	(eq *planner-mode* 'mr-crit))
    (mr-successors&costs plan))
   ((eq *planner-mode* 'abtweak)
    (ab-successors&costs plan))
   (t
    (tw-successors&costs plan))))


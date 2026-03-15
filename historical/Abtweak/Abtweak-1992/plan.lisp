; 
; (plan ...) is the main routine that invokes either abtweak or tweak.
;

(defun plan (initial goal &key 
			     
                                 (planner-mode 'abtweak)
				 (continue-p nil)
                                 (mp-mode  t)
                                 (abstract-goal-mode  t) 
                                 (drp-mode         nil)
                                 (left-wedge-mode t)
                                 (subgoal-determine-mode  'stack)
                                 (debug-mode      nil)
				 (drp-debug-mode nil)
                                 (heuristic-mode 'num-of-unsat-goals)
                                 (use-primary-effect-p  nil)
                                 (expand-bound      500)
                                 (generate-bound   1000)
                                 (open-bound       1000)
				 (output-file nil)
				 (cpu-sec-limit 300)   ; 5 min
               )
  "/Plan/plan.lsp
   initialize a plan, and invoke a search routine for 
   A* search.

   initial ---set of initial conditions  
   goal    ---set of goal conditions            "

  (declare 
        (type list initial)               
        (type list goal) 
        (type atom planner-mode)            ; tweak / abtweak
        (type atom mp-mode)                 ; t/nil
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
   )

  ; set control global flags (default values specified in planner function)
  (initialize-global-variables
   planner-mode continue-p mp-mode abstract-goal-mode 
   drp-mode left-wedge-mode subgoal-determine-mode debug-mode
   heuristic-mode use-primary-effect-p expand-bound
   generate-bound open-bound output-file cpu-sec-limit drp-debug-mode)

  (let* (
         (initial-plan (make-initial-plan initial goal)))
    (declare (type plan initial-state))
    (search1 initial-plan)
    (output-solution-information)
    (if (not (equal *output-stream* *standard-output*))
	(close *output-stream*))
    ))


; ---- make-initial-plan ----

(defun make-initial-plan (initial goal)
  "/Planner/planner.lsp
    returns an initial plan - based on *planner-mode*"
  (declare
        (type list initial)
        (type list goal) )

  (if (eq *planner-mode* 'abtweak)
      (ab-make-initial-plan initial goal)
      (tw-make-initial-plan initial goal)))


; --- termination ---

(defun goal-p (state)
  "/planner/planner.lsp
    planning termination condition."
  (declare 
      (type plan state) )
  (if (eq *planner-mode* 'abtweak)
      (ab-goal-p state)
      (tw-goal-p state)))
      
; --- successors generation ---

(defun successors&costs (plan)
  "/planner/planner.lsp
    returns a list of successor states and costs."
  (declare (type plan plan) )

  (if (eq *planner-mode* 'abtweak)
      (ab-successors&costs plan)
      (tw-successors&costs plan)))


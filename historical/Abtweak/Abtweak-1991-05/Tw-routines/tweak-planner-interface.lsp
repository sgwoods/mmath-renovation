; Tweak-specific functions for interfacing with planner.

;  --- initialization routines. ------------

(defun tw-make-initial-plan (initial goal)
  "/planner/planner.lsp
    returns an initial tweak plan"
  (declare
        (type list initial)
        (type list goal) )
  (let (
        (i (create-operator-instance
              :opid 'i
              :name '(i)
              :preconditions nil
              :effects initial))
        (g (create-operator-instance
              :opid 'g
              :name '(g)
              :preconditions goal
              :effects nil))
        )
  (declare
       (type operator i)
       (type operator g) )

  (create-plan
	   'initial-plan
	   :a (list i g)
	   :b '(( i g))
	   :cost 0)))


; --- termination routines.  ---------------

(defun tw-goal-p (state)
  "/planner/planner.lsp
    tweak termination condition."
  (declare 
      (type plan state) )
  (mtc state) )


; --- Successor generation routines. -----------------

(defun tw-successors&costs (plan)
  "
   tweak - returns a list of successor states and costs."
  (declare (type array plan) )

  (mapcar #'(lambda (state) (list state (get-plan-cost state)))
               (successors plan)) )


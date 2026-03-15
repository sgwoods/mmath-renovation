; AbTweak and Planner interface routines.

;---------- make-initial plan

(defun ab-make-initial-plan (initial goal)
  "/planner/planner.lsp
    abtweak - returns a initial plan"
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
           :tree (list 'g)
           :kval  (find-initial-k-val) 
)))

; -------------   Solution Checking Part. ------------

(defun ab-goal-p (plan)
   "
     note :: a tweak plan is correct if prob is nil, default kval is 0
               abtweak plan is correct if prob is nil, and kval = 0"
   (declare 
       (type array plan) )

  (and (ab-mtc plan) 
       (= (plan-kval plan) 0)) )

;--------- successors and costs generation. -----------

(defun ab-successors&costs (plan)
  "
   abtweak - returns a list of successor states and costs."
  (declare (type array plan) )
  (mapcar #'(lambda (state) (list state (get-plan-cost state)))
          (ab-successors plan) ))


;----------- find-initial-k-val

(defun find-initial-k-val ()
  "returns the highest criticality value of the hierarchy"
  (apply 'max (mapcar 'car *critical-list*)))
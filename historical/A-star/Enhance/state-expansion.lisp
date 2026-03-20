;;; state expansion routines: (1) successors&costs (2) compute-priority

; Note:  each rule has the form:  (preconditions: (...)
;                                  effects:       (...))
; where preconditions is a predicate, and effects is a lambda expression 
; specifying a new state after the rule is applied.

; It is assumed that there is a global variable *rules* that contains the 
; list of all rules.

; (get-all-instances rule state) is supplied by the user, it returns a list of 
; successors and costs  instances for the rule and the state.

(defun successors&costs (state)
   "returns a list having the form 
  ((state1.cost1)(state2.cost2)...(staten.costn))
  where each state(i) is an immediate successor to state, and
  each cost in the cost of getting from state to state(i)"
   (let (successors&costs)
      (dolist (next-rule *rules*)
         (setq successors&costs 
            (append 
               (get-all-instances next-rule state)                  
               successors&costs)))
      successors&costs))

(defun compute-priority (priority-function state cost)
   "computes the priority of a node by applying pri function"
   (+ cost (funcall priority-function state)))


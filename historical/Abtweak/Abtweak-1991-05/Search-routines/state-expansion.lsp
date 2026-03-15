(defun compute-total-cost (heuristic-function state cost)
      "planner/search/state-expansion
       computes the priority of a node by applying heuristic function"
   (+ cost (funcall heuristic-function state)))

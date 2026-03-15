(defun search (initial-state)
  "planner/search/search
   generic search routine(s) call 
   SIMPLIFIED DEC 13/90 -sgw "
 (declare (type plan initial-state))
 (graphsearch initial-state 
                  :maintain-closed-p nil
                  :update-open-p     t))

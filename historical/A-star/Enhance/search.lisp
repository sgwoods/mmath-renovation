(defun search (initial-state
      &key
          (search-type '6)
           ; one of (1) DFS w Closed List  (2) DFS w/o Closed List
           ;        (3) BFS w Closed List  (4) BFS w/o Closed List
           ;        (5) IDA w Closed List  (6) IDA w/o Closed List
          (dfs-depth-limit 20)
           ; if DFS used: must specify maximum search depth to traverse
          (verbose-p nil) 
           ; if t, print out *open* and *closed* at every iteration
          (print-opt-p t)
           ; if t, print out optimal path upon termination
               )
  "Generic Search Routine "
;  Graphsearch 
;              initial-state
;              order open  - t as a stack (DFS) or nil - as a queue (BFS)
;              maintain closed list - don't expand duplicates, t or nil
;              updates to open list - allow replacement of open list nodes
;              dfs search limit   
;              verbose
;              print-opt-path
;              
   (case search-type
         (1 (c_graphsearch initial-state t   t   t   dfs-depth-limit
                         verbose-p print-opt-p ))
         (2 (c_graphsearch initial-state t   nil t   dfs-depth-limit
                         verbose-p print-opt-p ))
         (3 (c_graphsearch initial-state nil t   t   0
                         verbose-p print-opt-p ))
         (4 (c_graphsearch initial-state nil nil t   0
                         verbose-p print-opt-p ))
         (5 (ida-search  initial-state t   t   nil dfs-depth-limit 
                         verbose-p print-opt-p ))
         (6 (ida-search  initial-state t   nil nil dfs-depth-limit 
                         verbose-p print-opt-p ))
    ))

(defun ida-search (initial-state 
                   order-open-p maintain-closed-p update-open-p
                   dfs-depth-limit verbose-p print-opt-p
                   &key
                       (success-p nil)
                       (done-depth-p nil)
                  )
   "Iterative Depth First A* Search"
    (do 
       ( (cur_depth    1   (1+ cur_depth) )                
         (finish-p nil (or success-p done-depth-p))
        )
       ( 
         (eq finish-p t)                                  ; exit do when?
         (if success-p t nil)
        )
       (if (c_graphsearch initial-state 
                          order-open-p maintain-closed-p update-open-p
                          cur_depth verbose-p print-opt-p)
           (setq success-p t)                        ; solution found
           (progn 
              ; (princ "IDA* - depth = ") (princ cur_depth) (terpri) 
              ; (princ "       limit = ") (princ dfs-depth-limit) (terpri)
              (if (eq cur_depth dfs-depth-limit)           
                  (setq done-depth-p t)                 ;depth limit done
                  (setq done-depth-p nil))              ;depth limit not done
           ))
      ))

(defun c_graphsearch (initial-state 
                         order-open-p maintain-closed-p update-open-p
                         dfs-depth-limit verbose-p print-opt-p)
   "Call graphsearch routine with appropriate parameters"
     (graphsearch initial-state
                  :order-open-dfs-p  order-open-p
                  :maintain-closed-p maintain-closed-p
                  :update-open-p     update-open-p
                  :dfs-limit         dfs-depth-limit
                  :verbose-p         verbose-p
                  :print-opt-path-p  print-opt-p))
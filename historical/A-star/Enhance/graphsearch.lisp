(defvar *open* nil)
(defvar *closed* nil)

;user defined functions:  1. (goal-p state) 2. (which-pri-function)

(defun graphsearch (initial-state
      &key 
         (order-open-dfs-p  nil)   ; t - BFS  nil - DFS
         (maintain-closed-p   t)   ; t CLOSED in use  nil - CLOSED unused
         (update-open-p       t)   ; t OPEN checked   nil - OPEN not checked
         (dfs-limit           0)   ; if dfs, limit of depth
         (verbose-p         nil)   ; t - print open at each iteration
         (print-opt-path-p    t)   ; t - when done, print opt path if exists

         ) 
      "graphsearch searches a state space for a goal state using A* algorithm"
   (let ((cost 0)     ;the 'depth', # operator applications to node
         pri      ;the priority of a node (heuristic + cost)
         node      ;the entire current node structure
         newcost      ;the cost/depth to the new node
         newpri      ;the priority assigned to the new node
         newstate      ;the new state created in expanding the cur node
         newnode      ;the new node structure
         othernode      ;a node found containing the same state as cur
         node&position      ;a list containing the node & its list position
         priority-function      ;the heuristic function used
         (numexpanded 0)      ;Number of nodes expanded total
         (numgenerated 0)     ;Number of nodes generated total  
        )         
    (setq priority-function (which-pri-function))   ;select heuristic function
    (setq pri (compute-priority priority-function initial-state cost))
       ;Priority (i.e. Cost+Heur) of Current Node          
    (initialize-open (make-node pri initial-state cost nil))   
    (initialize-closed)  
    (do ()    ;Main loop.  Until goal is found or graph is exhausted, do...
       (    (list-empty-p *open*)              ; exit condition 

            (progn
                   (if (list-empty-p *open*)   ; exit action / return result
                       (progn
                             (princ "OPEN EXHAUSTED")  (terpri))
                       (if (and order-open-dfs-p (eq dfs-limit cost))
                           (progn 
                                 (princ "GS DFS LIMIT REACHED: ") 
                                 (princ dfs-limit) (terpri))
                           (progn
                                 (princ "ERROR IN GRAPHSEARCH") (terpri)) ))
                    nil 
             ))                 ;FAILURE - *open* empty or limit
        (if verbose-p
            (print-open-list))
        (setq node (get-next-open-node))    ;sel node to expand & remv off OPEN
        (setq *open* (remove-first-node *open*))
        (if maintain-closed-p
            (setq *closed*  (insert-node 
                             order-open-dfs-p node *closed*)))  ;add to CLOSED
        (setq state (get-state node))                 ;extract cur. state
        (setq cost (get-cost node))                   ;extract cur. cost
        (if (goal-p state) 
            (let () 
              (print-success print-opt-path-p node numexpanded numgenerated)
              (if order-open-dfs-p 
                  (progn (princ "Solution Depth : ") (princ dfs-limit) 
                         (terpri)))
              (return t)))
        (setq numexpanded (1+ numexpanded))   
        (dolist               ;GENERATE Successors of Node
            (newstate&cost (successors&costs state))  ;compute expansion states
            (setq newstate (first newstate&cost))       ;select one expansion
            (setq newcost                             ;calc new cost
                    (+ cost (second newstate&cost)))
    ;       (break "Before setq newnode")
            (setq newnode                             ;create new node
                    (make-node 
                       (compute-priority priority-function newstate newcost)
                        newstate newcost node))
            (setq numgenerated (1+ numgenerated))     ;count generated node
   ;        (break "Before cond")
            (cond 

             ;Is newstate in *open*  list?
              ( (and update-open-p (state-isin-p newstate *open*))      

  ;               (break "in open list")
                  (setq othernode (get-node-from-list newstate *open*)) 
                  (if (< newcost (get-cost othernode))
                     ;Yes - Lower Cost expansion found
                     ;Replace *open* list node with new one
                     (let () 
                            (setq *open* (remove-state newstate *open*))   
                            (setq *open* (insert-node 
                                          order-open-dfs-p newnode *open*)))
                   );of if
                ) ; of cond 1

              ;Is newstate in *closed*  list?
              ( (and maintain-closed-p (state-isin-p newstate *closed*))

 ;                (break "in closed list")
                  (setq othernode (get-node-from-list state *closed*)) 
                  (if (< newcost (get-cost othernode))
                      (let () 
                            (setq *closed*  (remove-state newstate *closed*)))
                   ); of if 
                 ); of cond 2
               ;Default case
               ( t      ;STATE generated is unique - add to *open* list

;                  (break "unique, add to open list")
		       ; Dont add new node if past max depth
                   (if (and order-open-dfs-p (> newcost dfs-limit)) 
                       nil
                       (setq *open* 
                             (insert-node order-open-dfs-p newnode *open*))
                    ); of if
                ); of cond 3
           ) ;cond
         ) ;do list
       ); do - Main loop
    ) ; let - cost
  ) ; defun
 



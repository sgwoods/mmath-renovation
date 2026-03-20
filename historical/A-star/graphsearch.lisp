(defvar *open* nil)
(defvar *closed* nil)

;user defined functions:  1. (goal-p state) 2. (which-pri-function)

(defun graphsearch (initial-state
      &key 
         (check-open-closed-p t)   
          ;t if checking if node is in *open* and *closed*  in every iteration.
         (print-open-closed-p nil)
          ;t if printing *open* and *closed* in every iteration.
         (print-optimal-path-p nil)
          ;t if print optimal path to goal upon termination.
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
    (setq priority-function (which-pri-function))   ;select heuristic function to use                                                     
    (setq pri (compute-priority priority-function initial-state cost))
       ;Priority (i.e. Cost+Heur) of Current Node          
    (initialize-open (make-node pri initial-state cost nil))   
    (initialize-closed)  
    (do ()    ;Main loop.  Until goal is found or graph is exhausted, do...
       ( (list-empty-p *open*) 'fail )                    ;FAILURE - *open* empty 
        (if print-open-closed-p (print-open-list))
        (setq node (get-next-open-node))   ;select node to expand and remove from OPEN
        (setq *open* (remove-first-node *open*))
        (setq *closed*  (insert-node node *closed*))       ;add to CLOSED
        (setq state (get-state node))                 ;extract cur. state
        (setq cost (get-cost node))                   ;extract cur. cost
        (if (goal-p state) 
           (let () (print-success node numexpanded numgenerated)
              (return t)))              
        (setq numexpanded (1+ numexpanded))   
        (dolist               ;GENERATE Successors of Node
            (newstate&cost (successors&costs state))  ;compute expansion states
            (setq newstate (first newstate&cost))       ;select one expansion
            (setq newcost                             ;calc new cost
                    (+ cost (second newstate&cost)))     
            (setq newnode                             ;create new node
                    (make-node 
                       (compute-priority priority-function newstate newcost)
                        newstate newcost node))
            (setq numgenerated (1+ numgenerated))     ;count generated node
            (cond 
               ((state-isin-p newstate *open*)               
               (setq othernode (get-node-from-list newstate *open*))                              
               (if (< newcost (get-cost othernode))
                  ;Yes - Lower Cost expansion found
                  ;Replace *open* list node with new one
                  (let () (setq *open* (remove-state newstate *open*))   
                          (setq *open* (insert-node newnode *open*)))))
                  ;Is newstate in *closed*  list?
               ((state-isin-p newstate *closed*) ;Yes - state expanded already
                  (setq othernode (get-node-from-list state *closed*)) ;identical state found                  
                  (if (< newcost (get-cost othernode))
                      (let () 
                            (setq *closed*  (remove-state newstate 
                                  *closed*)))))
                (t       ;STATE generated is unique - add to *open* list
                   (setq *open* (insert-node newnode *open*))))))))
 



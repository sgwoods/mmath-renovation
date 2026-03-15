; graphsearch
;
; note this version of gs has been modified via declarations to be planning structure
;  specific, and references are made to state as an instance of type plan
;  in order to speed up the compiled version of this code
;   sgw oct 2, 1990

; written by steve woods, april 1990
; modified by steve woods oct  1990

(defvar *open*   nil)     ; global open list
(defvar *closed* nil)     ; global closed list
(defvar *goal*   nil)     ; global solution plan 
(defvar *solution-depth*   0)     ; global solution plan depth

(defun graphsearch (initial-state
      &key 
         (order-open-dfs-p  nil)   ; t - bfs  nil - dfs
         (maintain-closed-p   t)   ; t closed in use  nil - closed unused
         (update-open-p       t)   ; t open checked   nil - open not checked
         (dfs-limit           0)   ; if dfs, limit of depth
         (verbose-p         nil)   ; t - print open at each iteration
         (print-opt-path-p    t) )   ; t - when done, print opt path if exists
      "planner/search/graphsearch
       special version of graphsearch modified for tweak and abtweak planning"

   (declare
       (type plan    initial-state)
       (type boolean order-open-dfs-p)
       (type boolean maintain-closed-p)
       (type boolean update-open-p)
       (type integer dfs-limit)
       (type boolean verbose-p)
       (type boolean print-opt-path-p) )
       
   (let (
         (cost 0)     ;the 'depth', # operator applications to node
         state        ;the current state in the search space (domain state)
         pri          ;the priority of a node (heuristic + cost)
         node         ;the entire current node structure
         newcost      ;the cost/depth to the new node
         newstate     ;the new state created in expanding the cur node
         newnode      ;the new node structure
         othernode    ;a node found containing the same state as cur
         priority-function  ;the heuristic function used
        )

    (declare
        (type integer cost)
        (type plan state)
        (type integer pri)
        (type list node)
        (type integer newcost)
        (type plan newstate)
        (type list newnode)
        (type list othernode)
        (type function priority-function)
     )
         
    (setq *numexpanded*  0) ; search counter variables - global
    (setq *numgenerated* 0)

       ;select heuristic function
    (setq priority-function (which-pri-function))   
       ;priority (i.e. cost+heur) of current node          
    (setq pri (compute-priority priority-function initial-state cost))

    (initialize-open (make-node pri initial-state cost nil))   
    (initialize-closed)  

    (do ()    ;main loop.  until goal is found or graph is exhausted, do...
       (    (list-empty-p *open*)              ; exit condition 

            (progn
                   (if (list-empty-p *open*)   ; exit action / return result
                       (progn
                             (princ "open exhausted")  (terpri))
                       (if (and order-open-dfs-p (eq dfs-limit cost))
                           (progn 
                                 (princ "gs dfs limit reached: ") 
                                 (princ dfs-limit) (terpri))
                           (progn
                                 (princ "error in graphsearch") (terpri)) ))
                    nil 
             ))                 ;failure - *open* empty or limit

        (if verbose-p
            (print-open-list))

               ;sel node to expand & remv off open
        (setq node (get-next-open-node))    
        (setq *open* (remove-first-node *open*))

               ;add to closed if applicable in this run
        (if maintain-closed-p
            (setq *closed*  (insert-node 
                             order-open-dfs-p node *closed*)))  

        (setq state (get-state node))             ;extract cur. state from node
        (setq cost (get-cost node))               ;extract cur. cost  from node

               ; goal node found in search?
        (if (goal-p state) 
            (let () 
              (if (eq *mode* 'abtweak)
                  (setf (plan-op-count state) 
                        (update-op-count (plan-op-count state)
                                         (find-initial-k-val)
                                         (length (plan-a state))
                                         0)))
             ; if using k-list, and learn mode then ck the num of 
             ;(this level = k)
             ; operators in this plan correct at level k
             (if (and *crit-depth-mode* *k-learn-mode*)
                 (learn-kmode state))

              (setq *goal* state)
              (setq *solution-depth* (get-solution-depth node))
              (print-success print-opt-path-p node)
              (if order-open-dfs-p 
                  (progn 
                         (princ "dfs solution depth : ") (princ dfs-limit) 
                         (terpri)))
              (return t)))

        (setq *numexpanded* (1+ *numexpanded*))   ; count expanded node

        (if (integerp (/ *numexpanded* *ck-line*))
            (progn 
              (princ "expanded  = ") (princ *numexpanded*) (terpri)
              (princ "generated = ") (princ *numgenerated*) (terpri)))

        (if (integerp (/ *numexpanded* *ck-cur*))
            (cur))

        (dolist               ;generate successors of node
                              ; note newstate&cost takes on value of successors
                              ;   one at a time until there are none left

            (newstate&cost (successors&costs state))  ;compute expansion states
            (setq newstate (first newstate&cost))       ;select one expansion
            (setq newcost                             ;calc new cost
                    (+ cost (second newstate&cost)))

            (setq newnode                             ;create new node
                    (make-node 
                       (compute-priority priority-function newstate newcost)
                        newstate newcost node))

            (setq *numgenerated* (1+ *numgenerated*))     ;count generated node

            (cond 

             ;is newstate in *open*  list?
              ( (and update-open-p (state-isin-p newstate *open*))      

                  (setq othernode (get-node-from-list newstate *open*)) 
                  (if (< newcost (get-cost othernode))
                     ;yes - lower cost expansion found
                     ;replace *open* list node with new one
                     (let () 
                            (setq *open* (remove-state newstate *open*))   
                            (setq *open* (insert-node 
                                          order-open-dfs-p newnode *open*)))
                   );of if
                ) ; of cond 1

              ;is newstate in *closed*  list?
              ( (and maintain-closed-p (state-isin-p newstate *closed*))

                  (setq othernode (get-node-from-list state *closed*)) 
                  (if (< newcost (get-cost othernode))
                      (let () 
                            (setq *closed*  (remove-state newstate *closed*)))
                   ); of if 
                 ); of cond 2
               ;default case
               ( t      ;state generated is unique - add to *open* list

		       ; dont add new node if past max depth
                   (if (and order-open-dfs-p (> newcost dfs-limit)) 
                       nil
                       (setq *open* 
                             (insert-node order-open-dfs-p newnode *open*))
                    ); of if
                ); of cond default
           ) ;cond
         ) ;do list
       ); do - main loop
    ) ; let - cost
) ; defun

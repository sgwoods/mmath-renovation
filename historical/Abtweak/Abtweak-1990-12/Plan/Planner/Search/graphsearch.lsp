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
         (maintain-closed-p   t)   ; t closed in use  nil - closed unused
         (update-open-p       t)   ; t open checked   nil - open not checked
                    )

      "planner/search/graphsearch
       special version of graphsearch modified for tweak and abtweak planning"

   (declare
       (type plan    initial-state)
       (type boolean maintain-closed-p)
       (type boolean update-open-p) )
       
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
                             (princ "open exhausted")  (terpri)))
                    nil 
             ))        ;failure - *open* empty 
         
               ;sel node to expand & remv off open
        (setq node (get-next-open-node))    
        (setq *open* (remove-first-node *open*))

               ;add to closed if applicable in this run
        (if maintain-closed-p
            (setq *closed*  (insert-node node *closed*)))  

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
              (setq *goal* state)
              (setq *solution-depth* (get-solution-depth node))
              (print-success node)

              (return t)))

        (setq *numexpanded* (1+ *numexpanded*))   ; count expanded node

          ; Print out Expand/Generate levels of Search as desired
        (if (integerp (/ *numexpanded* *ck-line*))
            (progn 
              (princ "expanded  = ") (princ *numexpanded*)  (princ "     ")
              (princ "generated = ") (princ *numgenerated*) (princ "     ")
              (princ "Open Size = ") (princ (length-of-open)) (terpri))) 

          ; Print out Search Statistics as desired
        (if (integerp (/ *numexpanded* *ck-cur*))
            (cur))

          ; Limit Search Space via Number of Nodes Expanded
          ;                                        Generated
          ;                                        Size of Open
        (if (or (> *numexpanded* *max-exp*) 
                (> *numgenerated* *max-gen*)
                (> (length-of-open) *max-open*))
            (progn 
                (princ "One of set Limits Reached...") (terpri)
                (terpri)
                (princ "Expanded  ") (princ *numexpanded*) (princ " / ")
                                    (princ *max-exp*)     (terpri)
                (princ "Generated ") (princ *numgenerated*) (princ " / ")
                                    (princ *max-gen*)     (terpri)
                (princ "OPEN Size ") (princ (length-of-open)) (princ " / ")
                                    (princ *max-open*)     (terpri) 
                (terpri)
                (princ "Final Search stats are :")  (terpri)
                (cur) (terpri)
                 (break "in Graphsearch") ))

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
                            (setq *open* (insert-node newnode *open*)))
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

                  (setq *open* 
                         (insert-node newnode *open*))

                ); of cond default
           ) ;cond 
         ) ;do list

       ); do - main loop
    ) ; let - cost
) ; defun

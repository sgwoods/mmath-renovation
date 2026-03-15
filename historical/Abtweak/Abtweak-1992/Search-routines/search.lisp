
; search routine of the planner.  The basic structure of the routine is
; a graphsearch according to Nilssons routine.  However, there is no checking
; for cycles in the graph.  

(defun search1 (initial-state)
      "Search/search.
       Using the *operators* to generate a state space graph.  
       Terminates when (goal-p state) is true."

   (declare
       (type array initial-state))
       
   (let (
         (cost 0)     ;the 'depth', # operator insertions into node.
         state        ;the current state in the search space, which is a plan struct.
         total-cost   ;the total cost of a node (cost-so-far + heuristic).
         node         ;a node in the search graph.
         newcost      ;the cost/depth to the new node
         newstate     ;the new state created in expanding the cur node
         newnode      ;the new node structure
         heuristic-function  ;the heuristic function used
        )

    (declare
        (type integer cost)
        (type array state)
        (type integer total-cost)
        (type list node)
        (type integer newcost)
        (type array newstate)
        (type list newnode)
        (type function heuristic-function)
     )
    (setq heuristic-function (which-heuristic-function))
    
    (if (null *continue-p*)
	(let ()
	  (setq *internal-start-time*
		(get-internal-run-time))
	  (setq *num-expanded*  0) ; search counter variables - global
	  (setq *num-generated* 0)
	  (setq total-cost 
		(compute-total-cost 
		 heuristic-function
		 initial-state cost))
	  (initialize-open (make-node total-cost initial-state cost nil))
	  (initialize-closed)  
	  (setq *first-time-in-loop* t)))

    (do ()    ;main loop.  until goal is found or graph is exhausted, do...

	((list-empty-p *open*)              ; exit condition 
	 (format *output-stream* "***open exhausted***~&")  
	 nil)    ;failure, reuturn nil.

        (setq node (get-next-open-node)) ;Select node to expand & remv off open.
        (setq *open* (remove-first-node *open*))
	

        (setq state (get-state node))
					;extract cur. state from node.
	
					;Termination Conditions:

        (cond ((and (goal-p state) (not *first-time-in-loop*))
	       (let () 
		 (setq *solution* state)
		 (return t)))
	      ((> *num-expanded* *expand-bound*)
	       (setq *solution* 'expand-limit-exceeded)
	       (return nil))
	      ; check CPU time bound.
	      ((> (- (get-internal-run-time) 
		     *internal-start-time*)
		  (* *cpu-sec-limit* internal-time-units-per-second))
	       (let ()
		 (setq *solution* 'CPU-time-limit-exceeded)
		 (return nil))))

        (setq *num-expanded* (1+ *num-expanded*))   ; count expanded node.


        (dolist               ;generate successors of node
                              ; note newstate&cost is bound to each of successors
                              ; in turn, until there are none left.

            (newstate&cost (successors&costs state))  ;compute expansion states
            (setq newstate (first newstate&cost))       ;select one expansion
            (setq newcost 
		  (second newstate&cost))

	    (if *debug-mode*     ; debuging part.
		(let()  
		  (setq *parent-state* state)
		  (setq *current-successor* newstate)
		  (format *standard-output* 
			  "Please type :cont to continue...~&")
		  (format *standard-output* 
			  "~& Parent State *parent-state* = ~&")
		  (show-ops state)
		  (format *standard-output* 
			  "~& Children State *current-successor* = ~&")
		  (show-ops newstate)
		  (break)))

            (setq newnode                             ;create new node
                    (make-node 
                       (compute-total-cost heuristic-function 
					   newstate newcost)
		       newstate newcost node))

            (setq *num-generated* (1+ *num-generated*))     ;count generated node

	    (setq *open* 
		  (insert-node newnode *open*))
	    (setq *first-time-in-loop* nil)
	    ))))

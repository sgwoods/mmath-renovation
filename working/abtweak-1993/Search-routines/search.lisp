
; search routine of the planner.  The basic structure of the routine is
; a graphsearch according to Nilssons routine.  However, there is no checking
; for cycles in the graph.  

(defun A-search (initial-state)
      "Search/search.
       Using the *operators* to generate a state space graph.  
       Terminates when (goal-p state) is true."

   (declare
       (type plan initial-state))
       
   (let (
         (cost 0)     ;the 'depth', # operator insertions into node.
         state        ;the current state in the search space, 
	              ; which is a plan struct.
         total-cost   ;the total cost of a node (cost-so-far + heuristic).
         node         ;a node in the search graph.
         newcost      ;the cost/depth to the new node
         newstate     ;the new state created in expanding the cur node
         newnode      ;the new node structure
         heuristic-function  ;the heuristic function used
        )

	    (declare
	        (type integer cost)
	        (type list node)
	        (type list newnode)
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

	  (if (equal *control-strategy* 'bfs)
	      (initialize-open (make-node total-cost 
					 initial-state cost nil))
	    (stack-initialize-open (make-node total-cost 
					 initial-state cost nil)))


	  (initialize-closed)  
	  (setq *first-time-in-loop* t)))


    (do ()    	;;main loop.  until goal is found or graph is exhausted, do...
	
	((list-empty-p *open*)              ; exit condition 
         (if (and *drp-mode* *drp-stack*)
		;; if drp, then backtrack
		;; to a higher abs level:
		;; if drp-mode on, then check if *curr-level* is changed from
		;; i-1 to i.  If so,then an abstract level backtrack occured.
		;; Consequently, one should check *abs-branching-counts* at i,
		;; to see if it has exceeded the limit *abs-branching-limit*.
		;; If so, then *drp-stack* should be dumped till level i+1 plan
		;; appears.  

	      ;; drp-mode.
   	      (let (level)
		  (setq *open* (pop *drp-stack*))
		  (setq level
			(plan-kval (get-state (first-of-open))))

		  (if (= (get-abs-branching-count level)
			 *abs-branching-limit*)
		      (let ()
			(setq *open*
			      (reset-abs-branching-counts level))
			(if (null *open*)
			    (let ()
			      (setq *solution* 'open-exhausted)
			      (return nil)))
			(format  *output-stream*
				 "~%Abs Limit Exceeded at ~D;" level)
			(format *output-stream*
				"~%Abs Branching Counts: ~S.~&" 
				*abs-branching-counts*)
			(setq level (plan-kval 
				     (get-state (first-of-open))))))

		  (if *drp-debug-mode*
		      (break 
		       "~% Backtracking Across Abstraction Levels: ~D to ~D" 
		       (1- level)	level)))

	      ;; not drp-mode.
	      (let () 
		(setq *solution* 'open-exhausted)
		(format *output-stream* "***open exhausted***~&")  
		(return nil))     ;failure, reuturn nil.
             ))

        (setq node (if (equal *control-strategy* 'bfs)
		       (get-next-open-node)
		       (stack-get-next-open-node)
		     )) ;Select node to expand & remv off open.

        (setq *open* (if (equal *control-strategy* 'bfs)
			 (remove-first-node *open*)
		        (stack-remove-first-node *open*)))

        (setq state (get-state node))
					;extract cur. state from node.
					;Termination Conditions:

        (cond ((goal-p state)
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
                              ; note newstate&cost bound to each of successors
                              ; in turn, until there are none left.

            (newstate&cost 
	     (if (< (- (length (plan-a state)) 2) *solution-limit*)
		 (successors&costs state)   ;compute expansion states
		 nil)
             )   

            (setq newstate (first newstate&cost))       ;select one expansion
            (setq newcost 
		  (second newstate&cost))

	    (if *debug-mode*     ; debuging part.
		(let()  
		  (setq *ps* state)
		  (setq *cs* newstate)
		  (format *standard-output* 
			  "Please type :cont to continue...~&")
		  (format *standard-output* 
			  "~& Parent State ~S *ps* = ~&" (plan-id state))
		  (show-ops state)
		  (format *standard-output* 
			  "~& Children State ~S *cs* = ~&" (plan-id newstate))
		  (show-ops newstate)
		  (break)))

            (setq newnode                             ;create new node
                    (make-node 
                       (compute-total-cost heuristic-function 
					   newstate newcost)
		       newstate newcost node))

            (when (and (boundp '*score-trace-enabled*)
                       *score-trace-enabled*
                       (fboundp 'record-score-trace-node))
              (record-score-trace-node newnode state))

            (setq *num-generated* (1+ *num-generated*)) ;count generated node

	    (if (> *num-generated* *generate-bound*)
		(let ()
		  (setq *solution* 'generate-limit-exceeded)
		  (return-from A-search nil)))

	    (setq *open* 
		  (if (equal *control-strategy* 'bfs)
		      (insert-node newnode *open*)
		    (stack-insert-node newnode *open*)))

	    (if (and (equal *control-strategy* 'bfs)
		     (> (length-of-open) *open-bound*))
		(let ()
		  (setq *solution* 'open-limit-exceeded)
		  (return-from A-search nil)))

	    (if (and (not (equal *control-strategy* 'bfs))
		     (> (stack-length-of-open) *open-bound*))
		(let ()
		  (setq *solution* 'open-limit-exceeded)
		  (return-from A-search nil)))

	    (setq *first-time-in-loop* nil)

      ) ;; matches  dolist  generate successors
    ) ;; matches do main loop
  ) ;; matches
) ;; matches

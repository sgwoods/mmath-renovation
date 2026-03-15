; output-solution-information outputs the information of the 
; planning session, including the total number of states expanded, etc.


(defun output-solution-information (success &key (output t))
  "output function upon termination."
  
  (setq *output-stream* output)
  (setq *success* success)
  (if (not (eq output 'no-output))
      (let ()
	(format *output-stream* 
		"~&~&***** ~A plan Terminated ***** ~2&" *planner-mode*)
	(format *output-stream* 
		"Subgoal-determine-mode: ~A ~&" *subgoal-determine-mode*)
	(format *output-stream* 
		"Heuristic-mode: ~A ~&" *heuristic-mode*)
	(format *output-stream* 
		"--- Statistics ---~2&")
	(format *output-stream* 
		"Total Number of Nodes Expanded: ~D ~&" *num-expanded*)
	(format *output-stream* 
		"Total Number of Nodes Generated: ~D ~2&" *num-generated*)
	(format *output-stream* 
		"Total CPU Seconds: ~D ~2&" 
		(/ (- (get-internal-run-time)
		      *internal-start-time*)
		   (* 1.0 internal-time-units-per-second)))
	(if *drp-mode*
	    (drp-solution-information output))
	(cond (success
	       (format *output-stream*
		       "Solution --- in (operator1 operator2) pairs:~&")
	       (show-ops *solution*))
	      (t  (format *output-stream* "Incomplete Termination..."))))))




;-------- Debugging routines  (cur)

(defun cur ()
  "output planning information."

  (setq *output-stream* t)
	 (format *output-stream* 
		 "~&~&***** Planner-Mode ***** ~A ~&" *planner-mode*)
	 (format *output-stream* 
		 "Subgoal-determine-mode: ~A ~&~&" *subgoal-determine-mode*)
	 (format *output-stream* 
		 "Heuristic-mode: ~A ~&~&" *heuristic-mode*)
	 (format *output-stream* 
		 "Monotonic Property Used: ~A ~&~&" *mp-mode*)
	 (if *mp-mode* 
	     (format *output-stream* 
		     "Monotonic Property Pruned: ~A ~&~&" *mp-pruned*))
	 (format *output-stream* 
		 "Left-Wedge-mode: ~A ~&~&" *left-wedge-mode*)
	 (format *output-stream*
		 "Downward Refinement Property Mode: ~A ~&~&" *drp-mode*)
	 (format *output-stream* 
		 "--- Statistics ---~&~&")
	 (format *output-stream* 
		 "Total Number of Nodes Expanded: ~D ~&~&" *num-expanded*)
	 (format *output-stream* 
		 "Total Number of Nodes Generated: ~D ~&~&" *num-generated*)
	 (format *output-stream* 
		 "Total CPU Seconds: ~D ~2&" 
		 (/ (- (get-internal-run-time)
		       *internal-start-time*)
		    (* 1.0 internal-time-units-per-second)))
	 (format *output-stream* 
		 "Size of Open List: ~D ~&~&" (length-of-open)))


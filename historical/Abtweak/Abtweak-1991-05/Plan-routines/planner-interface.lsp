; output-solution-information outputs the information of the 
; planning session, including the total number of states expanded, etc.


(defun output-solution-information ()
  "output function upon termination."
  (if (equal *planner-mode* 'tweak)
      (tweak-output-solution-information)
    (abtweak-output-solution-information)))

;-------- Tweak Output Information.

(defun tweak-output-solution-information ()
  "output function upon termination."


	 (format *output-stream* 
		 "~&~&***** Tweak Terminated ***** ~2&")
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
	 (cond ((or (eq (type-of *solution*) 'array)
		    (eq (type-of *solution*) 'plan))
		(format *output-stream*
			"Solution --- in (operator1 operator2) pairs:~&")
		(show-ops *solution*))
	       (t  (format *output-stream* "Incomplete Termination..."))))


;-------- AbTweak Output Information.

(defun abtweak-output-solution-information ()
  "output function upon termination."


	 (format *output-stream* 
		 "~&~&***** AbTweak Terminated ***** ~2&")
	 (format *output-stream* 
		 "Subgoal-determine-mode: ~A ~&" *subgoal-determine-mode*)
	 (format *output-stream* 
		 "Heuristic-mode: ~A ~&" *heuristic-mode*)
	 (format *output-stream* 
		 "Monotonic Property Used: ~A ~&" *mp-mode*)
	 (format *output-stream* 
		 "Goal Literals Abstracted: ~A ~&" *abstract-goal-p*)
	 (format *output-stream* 
		 "Left-Wedge-mode: ~A ~&" *left-wedge-mode*)
	 (format *output-stream*
		 "Downward Refinement Property Mode: ~A ~2&" *drp-mode*)
	 (format *output-stream* 
		 "--- Statistics ---~&~&")
	 (format *output-stream* 
		 "Total Number of Nodes Expanded: ~D ~&" *num-expanded*)
	 (format *output-stream* 
		 "Total Number of Nodes Generated: ~D ~&" *num-generated*)
	 (if *mp-mode* 
	     (format *output-stream* 
		     "Monotonic Property Pruned: ~A ~2&" *mp-pruned*))
	 (format *output-stream* 
		 "Total CPU Seconds: ~D ~2&" 
		 (/ (- (get-internal-run-time)
		       *internal-start-time*)
		    (* 1.0 internal-time-units-per-second)))

	 (cond ((or (eq (type-of *solution*) 'array)
		    (eq (type-of *solution*) 'plan))
		(format *output-stream*
			"Solution Plan Structure Stored in *solution*~2&")
		(format *output-stream*
			"Solution --- in (operator1 operator2) pairs:~&")
		(show-ops *solution*))
	       (t (format *output-stream* " Incomplete Termination..."))))



;-------- Debugging routines  (cur)

(defun cur ()
  "output planning information."


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


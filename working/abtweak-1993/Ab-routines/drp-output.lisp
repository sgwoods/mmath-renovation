(defun drp-solution-information (output-stream)
  (update-abs-ref-counts 0)
  (if *success* (update-abs-succ-counts 1))
  (if *success* (setf (aref *abs-success-counts* 0) 1))
  (format output-stream 
	  "Total Number of Abs Refinements: ~D ~2&" 
	  *abs-node-count*)
  (format output-stream 
	  "~% Level     Probability ~&")
  (dotimes (i (length *critical-list*))
	   (let* ((level 
		  (- (1- (length *critical-list*)) i))
		 (prob
		  (if (> (aref *abs-ref-counts* level) 0)
		      (/ 
		       (aref *abs-success-counts* level)
		       (aref *abs-ref-counts* level))
		    0)))
	     (format output-stream 
		     "~% ~D" level)

	     (format output-stream
		     "           ~,3F ~&" 
		     prob))))



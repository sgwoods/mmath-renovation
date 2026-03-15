; --- AbTweak functions ---

(defun ab-which-heuristic-function ()
   "/planner/planner.lsp
     abtweak priority calculation - heuristic selection"
   #'(lambda (state)
       (+ (funcall (tw-which-heuristic-function)
		 state)
	  (if *left-wedge-mode*
	      (funcall (left-wedge-function) state)
	   0)
	 )))

(defun left-wedge-function ()
   "Use *left-wedge-list*"

   #'(lambda (state) 
       (let ((value 
	      (nth (get_kval state) 
		   (reverse *left-wedge-list*))))
	 (if (numberp value)
	     (- 0 value)
	   0))))

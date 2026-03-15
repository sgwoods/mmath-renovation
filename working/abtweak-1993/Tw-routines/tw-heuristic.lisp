; ----- Tweak heuristic functions.-----

(defun tw-which-heuristic-function ()
   "/Tweak/
  Returns a heuristic function."

   (cond ( (equal *heuristic-mode* 'num-of-unsat-goals)   ; default
           (tw-heuristic-function-1))
	 ( (equal *heuristic-mode* 'user-defined)   ; user defined
	   (user-heuristic))   ; has to be loaded by user.
	 (t #'(lambda (state) 0))))


(defun tw-heuristic-function-1 ()
  "/Tweak/tw-heuristic.lsp
   default heuristic: (case 1) 
        = number of un-necessarily satisfied goals."

 #'(lambda (state) (num-of-unsat-goals state)))

; --- Supporting Functions. ---

(defun num-of-unsat-goals (plan)
  "Tweak - returns the total number of satisfied goals."
  (declare 
   (type plan plan) )
  (count-if-not
   #'(lambda (ith-goal)
       (hold-p plan 'g ith-goal))
   (get-preconditions-of-opid 'g plan)))


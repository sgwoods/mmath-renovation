; /Tweak/spp-succ.lsp - modified for Heuristic single producer property

; Successor Procedure for the search routine.
;
; Input: a plan structure instance.  Output: a list of successor plans.
;

 (setq *SP-property* t)   ; flag Single Producer Property as loaded
                          ; note different versions of SUCCESSORS

;*********** successors ***********

(defun successors ( plan )
  "Generates all successors of plan: 1. finding out all establishers for 
   an unachieved precondition p of user U.  2. making each 
   establisher necessary."

 (declare 
        (type plan plan))

 (let* ((U-and-p  (determine-U-and-p plan))
      
; Sel an oper with unsat preconds
	(U (first U-and-p))
	(p (second U-and-p))
	
	intermediates successors)

   (declare (type atom U))
   (declare (type list p))   
   (declare (type (list list) intermediates))

;Sel an unsatisfied precond p in this U

; each intermediates is a list of pairs (establisher-id new-plan)
	(setq intermediates 
	      (find-nec-exist-ests plan U p))

; using one-establisher heuristic.

	(if (null intermediates)
	    (setq intermediates
		  (remove-if
		   #'(lambda (pair) (invalid-p (second pair)))

; remove pair when pair= (est-id invalid-plan)

		   (append 
		    (find-pos-exist-ests plan U p)            
		    (find-new-ests plan U p)))))

	(setq successors (declobber-all intermediates U p))
   

   (remove-if 'invalid-p successors)))




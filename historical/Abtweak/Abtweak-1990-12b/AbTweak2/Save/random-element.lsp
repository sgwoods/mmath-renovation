; /AbTweak/random-element.lsp

; Random Ab-Determine-U-and-p  replacement function

(setq *ab-random* t)  ; flag AbTweak Random as loaded

(defun ab-determine-U-and-p (plan)
  "Tweak/random-element.lsp - to replace AbTweak/ab-succ.lsp:this function
   Returns (list U p) where U is an operator with precondition
   p possibly unsatisfied, where p has a criticality = Kval of plan
   NOTE: the current implementation will find the first U and p. "

  (declare 
     (type plan plan))

  (let ( (result nil) )
   (dolist (opid (get-opids-from-plan plan) result)
                   ; find all preconditions of opid at level K
      (dolist (precondition 
                        (adjust-pre-list  (get-preconditions-of-opid opid plan)
                                          (plan-kval plan)) )
                   ; this opid-precondition does not hold
                (if (not (hold-p plan opid precondition))
                    (setq result
                          (append result (list (list opid precondition)))))
        ))
   ;(break)
   (random-element result) ))



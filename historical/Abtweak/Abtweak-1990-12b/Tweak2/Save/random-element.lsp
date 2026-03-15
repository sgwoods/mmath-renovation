; /Tweak/random-element.lsp

; Random Determine-U-and-p  replacement function

(setq *tw-random* t)  ; flag Tweak Random as loaded

(defun determine-U-and-p (plan)
  "Tweak/random-element.lsp - to replace Tweak/successors.lsp:this function
   Returns (list U p) where U is an operator with precondition
   p possibly unsatisfied.
   NOTE: the current implementation will find the first U and p. "

  (declare 
     (type plan plan))

  (let ( (result nil) )
    (dolist (opid (get-opids-from-plan plan) result)
                   ; find all preconditions of opid
      (dolist (precondition (get-preconditions-of-opid opid plan))
                   ; this opid-precondition does not hold
                (if (not (hold-p plan opid precondition))
                    (setq result
                          (append result (list (list opid precondition)))))
        ))
;  (break)
   (random-element result) ))


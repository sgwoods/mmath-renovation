; /tweak/succ/discard-ops.lsp

; written by steve woods,  jan 1990

(defun discard (operators precond)
  "Discard potential establisher operators for a (precond constant ...)
   if it is listed as NOT-MOTIVATOR in *not-motives*"
;
; ie do not establish (in robot domain)
;     (inroom robot $somewhere) by adding an operator
;          carry-thru-door or push-thru-door
;
  (declare 
      (type list operators)
      (type list precond)  )
   (remove-if
     #'(lambda (operator)
          (in-discard-list precond operator))
        operators))

(defun in-discard-list (precond operator)
  "Return true if operator is listed as a NOT-MOTIVATOR for precond"
   (declare
        (type list precond)
        (type list operator) )
   (if (member (first (operator-name (car operator)))
               (get-discard-list precond *not-motive* ))
       t
       nil))

(defun get-discard-list (precond motives )
  "Return the NOT-MOTIVATOR list of operators for precond"
   (declare 
       (type list precond)
       (type list motives))
   (if (null (car motives))
       nil
       (if (and 
              (poss-codesignates precond (first (car motives)))
              (let (
                    (p1 (first (cdr (strip-negate precond))))
                    (p2 (first (cdr (strip-negate (first (car motives)) ))))
                   )
                 (if (and (constant-p p1) (constant-p p2) )
                     (if (eq p1 p2) 
                         t
                         nil)
                     nil)) )
            (second (car motives))
            (get-discard-list precond (cdr motives)))))


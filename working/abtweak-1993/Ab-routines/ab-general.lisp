; General Routines used in AbTweak.

; If *abstract-goal-mode* flag, 
; then for opid = g (goal) return all preconds
; ie.,  perform no abstraction on the goal operator

(defun adjust-pre-list (opid plist k)
   "abtweak/ab-successors.lsp  
    return a reduced precondition list for a certain level of criticality."

  (declare 
      (type atom opid)             ; opid involved
      (type list plist)     ; list of conditions
      (type integer k) )           ; criticality level

  (if (and (not *abstract-goal-mode*) (equal opid 'g))  
      plist
    (adjust-pre-list-others plist k)	))


; Note that the reduced list is used in problem identification, but the plan
; itself always contains all level preconditions so that any subsequent
; bindings are not lost

(defun adjust-pre-list-others (plist k)
   "abtweak/ab-successors.lsp  
    return a reduced precondition list for a certain level of criticality"

     (declare 
        (type list plist)     ; list of conditions
        (type integer k) )           ; criticality level

      (if (null (car plist))  
					; remv all preconds of criticality < given level
          nil
          (let* (         
                 (this    (car plist))      ; precondition name
                 (this-k  (find-crit this))); precondition criticality

             (declare 
                (type list this)  ; precondition including 'not !
                (type integer this-k))

            (if (null this-k)
                (progn             
                       (terpri) 
                       (princ "no criticality for precond, fatal error")
                       (terpri) (princ "precond = ") (princ this) (terpri)
                       (break "in abtweak/ab-succ")
                ))
            (if (>= this-k k)                           ; check each pre
                (cons  this
                       (adjust-pre-list-others (cdr plist) k))   ; keep
                (adjust-pre-list-others (cdr plist) k)           ; discard
              ))) )


(defun find-crit (pname)
   "abtweak/ab-successors.lsp
    return the criticality level of a precondition"
   (declare 
      (type list pname))
    ; check create parameter list as constants, vars == $
    ;  then match precondition to criticality level list

   (let ((crit
	  (find-crit1 (substitute-pre pname) *critical-list*)))
     (if (numberp crit) crit
       0)))

 (defun substitute-pre (pname)
    "abtweak/ab-successors.lsp
     substitute occurences of variables by $"
   (declare 
      (type list pname))
   (append (find-pre-head pname)
           (sub-pre-tail  (get-proposition-params pname)) )
  )

(defun find-pre-head (precond)
   "abtweak/ab-successors.lsp
    return the precond without parameters"
   (declare (type list precond))
   (if (eq (car precond) 'not)
       (list (first precond) (second precond))  ; (not whatever)
       (list (first precond)) )                 ; (whatever)
 )

(defun sub-pre-tail (params)
   "abtweak/ab-successors.lsp
    substitute occurences of vars in param list by $"
   (declare 
      (type list params))
   (if (null (car params))
       nil
       (if (constant-p (car params))
           (cons (car params)
                 (sub-pre-tail (cdr params)))
           (cons '$
                 (sub-pre-tail (cdr params)))
        )) ) 

 (defun find-crit1 (pname clist)
    "abtweak/ab-successors.lsp"
    (declare 
         (type list pname)
         (type list clist)
     )

    (if (null (car clist))
               ; failure - precondition not found in domain definition
               ;    as is, if constants exist, try without them
               ;    removing them consecutively right to left til 
               ;    a match is found or no more constants exist
        (if (contains-constants-p (get-proposition-params pname))
            (find-crit (remove-a-constant pname))
            nil
         )
        (let (
              (pre  (car clist))  ; this value preconditions             
              (rest (cdr clist))  ; others
             )
          (declare 
              (type list pre)
              (type list rest))
           (if (memb pname (cdr pre)) ; ie precond is in this level list
               (car pre)                ; return this level
               (find-crit1 pname rest)  ; keep looking
            ))) )

(defun contains-constants-p (params)
   "abtweak/ab-successors.lsp
    true iff pname contains at least one constant as a parameter"
   (declare 
       (type list params))
   (if (null (car params))
       nil
       (if (or (constant-p (car params))
               (contains-constants-p (cdr params)))
           t
           nil)) )

(defun remove-a-constant (pname)
   "abtweak/ab-successors.lsp
    replace rightmost constant in pname with $"
   (declare 
       (type list pname))
   (replace-i pname '$ (find-right-constant pname (1- (length pname)) )) )

(defun find-right-constant (pname right-pos)
   "abtweak/ab-successors.lsp
    return position of rightmost constant in pname"
    (declare
        (type list pname)
        (type integer right-pos))
    (if (constant-p (ith right-pos pname))
        right-pos
        (find-right-constant pname (1- right-pos)) ))
    
(defun replace-i (list with pos)
   "abtweak/ab-successors.lsp
    replace element pos of list by with"
    (declare 
        (type list list)
        (type atom with)
        (type integer pos) )
    (append 
            ;head - list from 0 to pos - 1
       (sublist list 0 (1- pos))
       (list with)
            ;tail - list from pos to length(list) - 1
       (sublist list (1+ pos) (1- (length list)))
    ))

(defun sublist (list from to)
   "abtweak/ab-successors.lsp
    return sublist of list (from .... to) "
    (declare 
        (type list list)
        (type integer from)
        (type integer to) )    
    (if (> from to)
        nil
        (if (eq from to)
            (list (nth from list))
            (cons
                (nth from list)
                (sublist list (1+ from) to) ))))


; ***************************************************************************
; plan dependent function to descend abstraction hierarchy
; ***************************************************************************

(defun add-a-level (plan )
  "abtweak/ab-successors.lsp
   generate a more specific (level k-1) successor of level k correct plan, 
   with level k-1 problem list.  record level k causal relations"
   (declare 
      (type plan plan))
    (let* ( (old-k (plan-kval plan))
            (new-k (1- old-k)) )

      (setf (plan-kval plan) new-k)
      (setf (plan-cr plan) (new-cr plan old-k))
      (setf (plan-op-count plan)  (update-op-count (plan-op-count plan) 
                                             (find-initial-k-val) 
                                             (length (plan-a plan))
                                             old-k))
   plan
    ))

; op-count mode

(defun update-op-count (op-count max-k length-a lev-k)
   "abtweak/ab-successors.lsp
    update op-count for this past level completed"
    (declare 
        (type list op-count)
        (type integer max-k)
        (type integer length-a)
        (type integer lev-k))
       (if (eq lev-k max-k)                              ; first lev solution
           (list (list lev-k (- length-a 2)))
           (cons                                         ; all ops - prev - 2
                (list lev-k (-  length-a
                                2
                                (total-ops op-count)))
                 op-count)))

(defun total-ops (op-count)
   "abtweak/ab-successors.lsp
    how many ops indicated in plan by op-count"
  (declare  (type list op-count))
  (eval (cons '+
          (mapcar #'(lambda (level-cntr) 
                  (second level-cntr))
              op-count))))



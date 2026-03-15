; /abtweak/ab-successors.lsp

; written by steve woods, july 1990

;***************************************************************************
;*  abtweak successor creation
;*

(defun ab-successors (plan )
  "abtweak/ab-successors.lsp
    find successors in plan at level k of criticality"
   ; when level k plan completed, ie no prob exists, advance to
   ; level k-1, unless k=0, in which case there are no successors
  (declare 
      (type plan plan))
   
  (if (ab-mtc plan)               ; plan correct at level k
      (let* (
               ; descend abstraction hier to level k-1
               ;  note op-count level indicators updated at this point
             (new-level-plan-list (list (add-a-level plan))) )

         (declare
             (type (list plan) new-level-plan-list))

            ; count # ab exp nodes
         (setq *ab-count* (1+ *ab-count*))                

            ; display parent and children 
         (if *debug* (debug-s plan new-level-plan-list))

            ; never go back to old level k
         (if *td-mode* 
                  (opt-purge-level-k (get_kval plan)))    

            ; learning via k-list values...
            ; if using k-list, and learn mode then ck the num of 
            ;(this level = k)
            ; operators in this plan correct at level k

         (if (and *crit-depth-mode* *k-learn-mode*)
             (learn-kmode (car new-level-plan-list)))

         new-level-plan-list   ; return abstract plan in a list alone
       )
    
      ; normal tweak successors
      (let* (precond-index
                 (u-and-p  (ab-determine-u-and-p plan))
                 (u (first u-and-p))  ; sel an op w unsat preconds at level k
                 (p (second u-and-p)) ; sel an unsat lev k pre p in this u
		 intermediates 
                 successors)

          (declare 
             (type list u-and-p)
             (type atom u)
             (type list p)   
             (type (list list) intermediates)
             (type (list plan) successors) )

	  (setq precond-index (precond-to-index p u plan))

      ; each intermediates is a list of pairs (establisher-id new-plan)

	  (setq intermediates 
		(remove-if
		 #'(lambda (pair) (invalid-p (second pair)))
 			; remove pair when pair= (est-id invalid-plan)
		 (append 
		  (find-exist-ests plan u p)            
		  (find-new-ests plan u p))))

	  (setq successors (declobber-all intermediates u precond-index))

	; remove plans flagged as invalid -ie conflicting constraints exist
        ;   and any that violate the msp property
	  (setq successors  (remove-if 'violates-msp 
                                  (remove-if 'invalid-p successors)))

            ; display parent and children 
	  (if *debug* (debug-s plan successors))

        ; check for current maximum successor size, and update if nec	  
	  (if (< *count* (length successors)) 
	      (setq *count* (length successors)))

        ; record branching factor values for later averaging
	  (update-br-factor (plan-kval plan) (length successors) )

	  successors))) 

; new-routines oct 29, qiang yang.
;*******************************************************

(defun precond-to-index (precond userid plan)
  "returns the index of precond in user of plan"
   (1- 
    (length 
     (member precond 
	     (reverse (get-preconditions-of-opid userid plan))
	     :test 'equal))))


(defun index-to-precond (precond-index userid plan)
  (nth precond-index (get-preconditions-of-opid userid plan)))

;********************************************************


(defun ab-determine-u-and-p (plan)
  "abtweak/ab-successors.lsp   nov 17/90
   returns (list u p) where u is an operator with precondition
   p possibly unsatisfied.
   note: the current implementation will find either a random up, a 
   tree up, or the first up in a list"

  (declare 
     (type plan plan))

  (let (
        (uandp
          (if (eq *determine-mode* 'random)               ; random u and p
              (ab-determine-random-u-and-p plan) 
              (if (eq *determine-mode* 'tree)             ; preorder tree u and p 
                  (ab-determine-tree-u-and-p plan)
                  (ab-determine-first-u-and-p  plan))))   ; first from a list
        )
     (if (or *debug* *show-up*)
         (progn
            (princ "<plan> selected u and p : ")
            (princ "<") (princ (plan-id plan)) (princ "> ")
            (princ uandp) (terpri)
         ))

     uandp))

(defun ab-determine-tree-u-and-p (plan)
  "tweak/successors.lsp
   returns (list u p) where u is an operator with precondition
   p possibly unsatisfied.
   note: the current implementation will find the first u and p- in the 
   preorder traversal of the plan operator tree where p has a criticality
   = kval of plan "

  (declare 
     (type plan plan))

  (let ( (result nil) )
   (dolist (opid (pre-order (get_tree plan)) result)
      (dolist (precondition 
                        (adjust-pre-list opid 
                            (get-preconditions-of-opid opid plan)
                            (plan-kval plan)) )
                   ; this opid-precondition does not hold
                (if (not (hold-p plan opid precondition))
                    (return (setq result (list opid precondition)))
                    nil)
        )
       (if result (return result))
    )))

(defun ab-determine-first-u-and-p (plan)
  "abtweak/ab-successors.lsp  oct 19/90
   returns (list u p) where u is an operator with precondition
   p possibly unsatisfied, where p has a criticality = kval of plan
   note: the current implementation will find the first u and p. "

  (declare 
     (type plan plan))

  (let ( (result nil) )
   (dolist (opid 
                (if *backwards* (reverse (get-opids-from-plan plan))
                                (get-opids-from-plan plan))
                result)
                   ; find all preconditions of opid at level k
      (dolist (precondition 
                        (adjust-pre-list  opid
                                          (get-preconditions-of-opid opid plan)
                                          (plan-kval plan)) )
                   ; this opid-precondition does not hold
                (if (not (hold-p plan opid precondition))
                    (return (setq result (list opid precondition)))
                    nil)
        )
       (if result (return result))
    )))

(defun ab-determine-random-u-and-p (plan)
  "abtweak/ab-successors.lsp
   returns (list u p) where u is an operator with precondition
   p possibly unsatisfied.
   note: the current implementation will find a random u and p. "
  (declare (type plan plan))
  (random-element (ab-unsat-up-pairs plan)))

(defun ab-unsat-up-pairs (plan)
 "abtweak/successors.lsp 
  return a list of all unsatisfied (user precondition) pairs in plan"

  (declare (type plan plan))

  (remove-if #'(lambda (pair)
                  (hold-p plan (first pair) (second pair)))
      (mapcan #'(lambda (opid) 
                    (mapcar #'(lambda (pre) 
                                 (list opid pre ))
                          (adjust-pre-list opid
                             (get-preconditions-of-opid opid plan)
                             (get_kval plan) )))
            (get-opids-from-plan plan))))


(defun adjust-pre-list (opid plist k)
   "abtweak/ab-successors.lsp  
    return a reduced precondition list for a certain level of criticality
    (check for goal abstraction flag - added nov 5"
 ;;
 ;; nov 5 - if *abs-goal* flag, then for opid = g (goal) return all preconds
 ;;         ie perform no abstraction on the goal operator

  (declare 
      (type atom opid)             ; opid involved
      (type (list list) plist)     ; list of conditions
      (type integer k) )           ; criticality level

  (if (and *abs-goal* (eq opid 'g))  ; possibly do not abstract goal node
      plist
      (adjust-pre-list-others plist k)))


(defun adjust-pre-list-others (plist k)
   "abtweak/ab-successors.lsp  
    return a reduced precondition list for a certain level of criticality"

 ;;
 ;; note that the reduced list is used in problem identification, but the plan
 ;; itself always contains all level preconditions so that any subsequent
 ;; bindings are not lost

     (declare 
        (type (list list) plist)     ; list of conditions
        (type integer k) )           ; criticality level

      (if (null (car plist))  ;; remv all preconds of criticality < given level
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

      (find-crit1 (substitute-pre pname) *critical-list*)
  )

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
         (type (list list) clist)
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
              (type (list list) rest))
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
        (type (list list) op-count)
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
  (declare  (type (list list) op-count))
  (eval (cons '+
          (mapcar #'(lambda (level-cntr) 
                  (second level-cntr))
              op-count))))


;*end*************************************************************************


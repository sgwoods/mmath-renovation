; /abtweak/ab-mono.lsp

; written by steve woods, june 1990

;***************************************************************************
;ab-monotonic expansion enforcement
;
; allow for stopping of backtracking between any criticality levels 
;  specified.  in certain domains, it may be advantageous to never go
;  back to a certain k level once a solution has been found at that level
;  already - in this manner, a soution will be found top-down only.
;
; tech note: simply purge open list of all plans with level k when one sol'n
;            is found at level k.
;
; note: call to opt-purge-level-k is within ab-succ, and is triggered only
;  when global variable *td-mode* is set.
;  purging of *open* occurs when an abtweak successor is about to be
;  inserted into *open* with no conflicts/probs, and a kval greater than
;  0.

(defun opt-purge-level-k (old-k-val)
 "abtweak/ab-mono
  given an abtweak k value, purge *open* of all nodes with state kval
  the same as this old-k-value"
  (declare (type integer old-k-val))
 ;
 ; ensure only one abstraction is performed at each level specified
 ;  in the domain definition global variable *top-down-levels* list
 ; 
  (if (member old-k-val *top-down-levels*)  
      (progn
          (if *debug* (progn
                         (terpri)
                         (princ "purging open list for kvalue = ") 
                         (princ old-k-val)
                         (terpri) (terpri)
                       ))
          (setq *open* (purge-node-list *open* old-k-val)) )
       t))

(defun purge-node-list (open-list remv)
 "abtweak/ab-mono"
 (declare (type (list list) open-list) (type integer remv))
 (remove-if 'null
  (mapcar #'(lambda (priority-list)
               (let (
                     (purge-list 
                       (purge-this-node-list (second priority-list) remv)) )
                 (declare (type list purge-list))
                 (if (null (second purge-list))
                     nil
                    (list (first priority-list) purge-list))))
          open-list)))

(defun purge-this-node-list (node-list remv)
 "abtweak/ab-mono"
 (declare (type (list list) node-list) (type integer remv))
  (remove-if 'null
   (mapcar #'(lambda (node)
                (if (eq (plan-kval (second node)) remv) 
                    (progn 
                          (setq *top-down-num* (1+ *top-down-num*))
                           nil)
                    node))
         node-list)))

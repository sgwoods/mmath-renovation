; /abtweak/ab-causal.lsp

;***************************************************************************
; 
; causal relations
;
; for all level k preconditions, find all tuples
;  (u estu (esti .... estj) ) 
;  where esti are "establishers" of estu, a precondition of user op u
;
; note:: the "abtweak" definition of "establishes" indicates 
;  "a and b operators, p a precondition of b, and u an effect of a.
;  a establishes p for b with u (establishes a, b, p, u).
;
; implementation note::
;  since codesig. relations have been simplified to free or constant, p and
;   u are the same in tweak/abtweak here.
;
; note:: all establishers that precede u are considered, not only those
;  necessary establishers.  for example, no mention is made of possible
;  clobberers.  for some a to exist such that a < u, and a asserts u
;  with no other operators a' between a and u that also asserts u is enough
;  to make a an "establisher" by this definition.
; 
; note:: a weaker condition (less restrictive) would be to insist that
;  establishes refers only to necessary establishment, and then only
;  "protect" these casual relations.  
;

(defun new-cr (plan k)
  "abtweak/ab-causal
   return the entire new cr structure for plan at this level"
  (declare (type plan plan)
           (type integer k)
   )
  (append (plan-cr plan) (find-k-cr plan k))
 )
 
(defun find-k-cr (plan k)
  "abtweak/ab-causal
   find all causal relations to preserve at level k in plan"
  (declare (type plan plan) (type integer k) )
  ;
  ; find k level precondition types from domain definition
  ;
  ; for each op in plan, for each use of a level-k-pre type, 
  ; create a tuple (op level-k-pre)
  ; create a list of these for the whole plan :: "level-k-oplist"
  ;
  ; for each level-k-oplist, find all "establishers" as defined above
  ; "est-tuples" is of the form:
  ; (level-k-op level-k-pre (e1 ...)) where ei are the "establishers" of op-pre
  ;
 (let* ( 
        (level-k-pre-types (get-level-k-pre k *critical-list* )) 
        (level-k-oplist    (get-level-k-oplist (plan-a plan) level-k-pre-types))
       )
    (declare 
       (type list level-k-pre-types)
       (type list level-k-oplist)
     )
    (get-est-tuples plan level-k-oplist) ))

(defun get-est-tuples (plan level-k-oplist)
  "abtweak/ab-causal
   find all establishers tuples"
   (declare (type plan plan)
            (type list level-k-oplist)
    )
   (if (null (car level-k-oplist))
       nil
       (let (
             (this-op-ests ( get-est-this-op plan (car level-k-oplist)))
            )
         (if (eq this-op-ests nil)
             (get-est-tuples plan (cdr level-k-oplist))
             (cons
               this-op-ests
               (get-est-tuples plan (cdr level-k-oplist)))
          ))) )

(defun get-est-this-op (plan op-pre)
   "abtweak/ab-causal
    find establishers of this op-pre pair"
   (declare (type plan plan) 
            (type list op-pre))
   (let ( 
          (opid (first op-pre))   ; user operator id
          (pre  (second op-pre))  ; user precondition
        )
      (declare 
          (type atom opid)
          (type list pre)
      )
     ; return (u p- (... est ... )) if est list not nil
    (let ( 
          (estlist (find_establishers plan opid pre)) 
         )
      (declare (type list estlist))
      (if (null estlist)
          nil
          (list opid pre estlist)
      )) ))

(defun get-level-k-oplist (a level-k-pre-types)
   "abtweak/ab-causal
    create list of all ops in plan with level-k-pre-types"
   (declare 
       (type list a)
       (type list level-k-pre-types)
    )
     ; returns (... (opid precondition) ... )
   (if (null (car level-k-pre-types))
       nil
       (append (get-this-level-k-type a (car level-k-pre-types))
               (get-level-k-oplist a (cdr level-k-pre-types)) )) )
 
(defun get-this-level-k-type (a one-k-pre-type)
   "abtweak/ab-causal
    create list of all ops in plan with this level-k-pre-type"
   (declare 
       (type list a)
       (type list  one-k-pre-type)
    )
    (if (null (car a))
        nil
        (let ( 
               (this-a-pre (find-this-a-pre 
                                     (operator-preconditions (car a))
                                      one-k-pre-type    ))
              ) 
             (declare (type list this-a-pre))
             (if (null this-a-pre )
                 (get-this-level-k-type (cdr a) one-k-pre-type)
                 (append
                      (create-tuples (operator-opid (car a)) this-a-pre)
                      (get-this-level-k-type (cdr a) one-k-pre-type) )
              ))) )

(defun find-this-a-pre (pre-list one-k-pre-type)
  "abtweak/ab-causal
   "
  (declare
      (type list pre-list)
      (type list one-k-pre-type)
   )
  (if (or (null pre-list)
          (null (car pre-list)) )
      nil
      (if (equal-pre (car pre-list) one-k-pre-type)
          (cons (car pre-list)
                (find-this-a-pre (cdr pre-list) one-k-pre-type) )
          (find-this-a-pre (cdr pre-list) one-k-pre-type) )))

(defun equal-pre (pre-type one-k-pre-type)
   "abtweak/ab-causal
    are the pre-type from the pre list and one-k-pre-type equiv and same k?"
    (declare (type list pre-type)
             (type list one-k-pre-type) )
    (let (
          (first-pre-type  (car  pre-type))
          (second-pre-type (cadr pre-type))
          (first-one-k     (car  one-k-pre-type))
          (second-one-k    (cadr one-k-pre-type))
      )
     (if (or                                    
             (and                                   ; both have not
                 (eq first-pre-type 'not)       
                 (eq first-one-k    'not) 
                 (eq second-pre-type second-one-k)  ; same name, criticality
                 (eq (find-crit pre-type) (find-crit one-k-pre-type)) )

             (and                               ; neither have not
                 (not (eq first-pre-type 'not))
                 (not (eq first-one-k    'not)) 
                 (eq first-pre-type first-one-k)  ; same name, criticality
                 (eq (find-crit pre-type) (find-crit one-k-pre-type)) )
           )
          t    ;match
          nil  ;no match
        )) )

(defun create-tuples (opid pre-list)
   "abtweak/ab-causal
    "
   (declare
       (type atom opid)
       (type list pre-list)
    )
   (if (null (car pre-list))
       nil
       (append
           (list
              (list opid (car pre-list)))
           (create-tuples opid (cdr pre-list)) )) )

(defun get-level-k-pre (k pre-list)
   "abtweak/ab-causal
    find all preconditions of level k in precondition list"
   (declare (type integer k)
            (type list pre-list)
    )
   (if (null (car pre-list) )
       nil
       (if (eq k (first (car pre-list)))   ; precond at level k?
           (cdr (car pre-list))
           (get-level-k-pre k (cdr pre-list))
        ))
 )  
       

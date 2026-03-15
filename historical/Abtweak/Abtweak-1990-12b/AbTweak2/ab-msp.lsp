; /abtweak/ab-msp.lsp

; written by steve woods, july 1990

; ***************************************************************************
; check plan for msp protection violation, discard if violation exists
;

(defun violates-msp (plan)
   "abtweak/ab-msp
    check plan for msp protection violation as indicated for this run"
  (declare (type plan plan))

   (if (null *msp-mode*)
       nil                                          ;return nil - no violation
       (if (eq *msp-mode* 'weak)                    ;weak msp flag on
           (violates-msp-weak plan)
           (if (eq *msp-mode* 'strong)              ;strong msp flag on
               (violates-msp-strong plan)
               (progn 
                     (princ "error : *msp-mode* invalid: ")       
                     (princ *msp-mode*)
                     (terpri)
                     nil      ; no default violation
                    )
                ))) )

;***************************************************************************
;  weak monotonic solution property implementation
;***************************************************************************

(defun violates-msp-weak (plan )
  "abtweak/ab-msp
   true if plan violates weak msp"
   ; ie must have only successors that do
   ; if all est( ek/i u/i p/i) is nec clob at any cr/i, discard - ie return t
   ; 
  (declare (type plan plan) )
;  (break "violates-msp-weak")
  (let* (
         (cr             (get_cr plan))           ; causal relations
         (up-pairs       (find-all-up-pairs cr))  ; abbrev all u p- pairs in cr
         (v-msp-w-flag   (weak-violation-p plan cr up-pairs))
        )
    (declare 
             (type list cr)
             (type (list list) up-pairs)
             (type boolean v-msp-w-flag)
     )
    (if (and *debug* v-msp-w-flag)
        (progn
              (terpri)
              (princ "plan violating weak msp not expanded: ")
              (princ (get_id plan))
              (terpri) (terpri)
         ))
    (if v-msp-w-flag 
        (setq *w-msp-pruned* (1+ *w-msp-pruned*)))
    v-msp-w-flag
 ))

(defun find-all-up-pairs (cr)
   "abtweak/ab-msp
    return a list of ( (u p-) ... ) where all pairs u p- in cr are returned"
   (declare (type list cr))

   (let* (
          (cri  (car cr))
          (u    (first  cri ))  ; get u  from cr/i
          (p-   (second cri ))  ; get p- from cr/i
    )
   (if (null cri)        ; no more cri to look at
       nil
       (cons
            (list u p-)    ; create pair from this cri
            (find-all-up-pairs (cdr cr))
        ))) )

(defun weak-violation-p (plan cr up-pairs)
  "abtweak/ab-msp
   true if any of up-pairs indicate a weak msp violation"
    (declare 
             (type plan plan)
             (type list cr)
             (type (list list) up-pairs)
     )
    (if (null (car up-pairs))     ; no more cr/i to check?
        nil                       ;   done, no violation found
        (if (or
                 ; this cri indicates a weak violation?
               (all-est-clob-this-cri plan cr (car up-pairs))
                 ; other cri indicates a weak violation?
              (weak-violation-p plan cr (cdr up-pairs)) )
            t    ;(progn (break) t)
            nil  
        )) )

(defun all-est-clob-this-cri (plan cr cri)
   "abtweak/ab-msp
    true if all of any one (level k) cri is clobbered in level k-1 plan"
  (declare
          (type plan plan)
          (type list cr)
          (type list cri)
   )
  (let* (
         ; list of k-1 establishers of this u p- (cri)
         (u        (first  cri))
         (p-       (second cri))
         (pos-ests (get-cr-ests cr u p-))
        )
     (declare
             (type atom u)
             (type list p-)
             (type list pos-ests)
      )
     (if (all-ests-clob-p plan pos-ests u p-)
         t
         nil
     )) )

(defun get-cr-ests (cr u p-)
   "abtweak/ab-msp
    return list of ests from cr for u p- pair"
   (declare 
            (type list cr)
            (type atom u)
            (type list p-)
    )
   (if (null (car cr) )
       nil
       (if (and (equal (first   (car cr)) u)       ;abbrev cri found in cr
                (equal (second  (car cr)) p-) )
           (third (car cr))                        ;return est list of cri
           (get-cr-ests (cdr cr) u p-) )) )
       
(defun all-ests-clob-p (plan pos-ests u p-)
  "abtweak/ab-msp
   return true if all establishers in list are clobbered"
  (declare
          (type plan plan)
          (type list pos-ests)
          (type atom u)
          (type list p-)
   )
  (if (null (car pos-ests))
      t
      (if (and
               ; cri est nec clobbered?
              (if (eq *msp-weak-mode* 'nec)
                  (nec-clobbered-p     plan (car pos-ests) u p-)
                  (cond ( (eq *domain* 'nilssons-blocks-world)
                          (nec-pos-clobbered-p plan (car pos-ests) u p-) )
                        ( (or (eq *domain* 'hanoi-3-ispeg)
                              (eq *domain* 'hanoi-2-ispeg) )
                          (pos-clobbered-p plan (car pos-ests) u p-) )
                        ( t
                            (progn
                                  (princ "error in ab-msp: unknown domain")
                                  (terpri) (break "in abmsp"))) )
               )
               ; other cri ests nec clobbered?
              (all-ests-clob-p plan (cdr pos-ests)  u p-))
          t
          nil
       )) )

(defun nec-clobbered-p (plan e u p-)
   "abtweak/ab-msp
    original w-msp implementation  hanoi domains
    return true if establisher e is necessarily clobbered"
    ; ie iff
    ; exists some operator c, nec between pos-est and u such that
    ;                      c  nec denies  p- 
    ;   or 
    ; exists some operator c, nec between pos-est and u such that
    ;                      c  nec asserts p- 
 (declare 

         (type plan plan)
         (type atom e)    ; establisher
         (type atom u)    ; user
         (type list p-)   ; predicate
  )
 (let (
        (n-betw  (all-nece-between e u plan))
      )
    (declare (type list n-betw)
     )
    (if (and (null (n-clobbers-p plan n-betw p-))  ; true if any nec clob p-
             (null (n-asserts-p  plan n-betw p-)) ); true if any nec assrts p-
        nil                ; no necessary clobberers / new ests
        t                  ; clobberers / new ests exist
     )) )

(defun pos-clobbered-p (plan e u p-)
   "abtweak/ab-msp
    modified w-msp implementation
    return true if establisher e is possibly clobbered"
    ; ie iff
    ; exists some operator c, nec between pos-est and u such that
    ;                      c  pos denies  p- 
    ;   or 
    ; exists some operator c, nec between pos-est and u such that
    ;                      c  pos asserts p- 
 (declare 

         (type plan plan)
         (type atom e)    ; establisher
         (type atom u)    ; user
         (type list p-)   ; predicate
  )
 (let (
        (n-betw  (all-nece-between e u plan))
      )
    (declare (type list n-betw)
     )
    (if (and (null (p-clobbers-p plan n-betw p-))  ; true if any pos clob p-
             (null (p-asserts-p  plan n-betw p-)) ); true if any pos assrts p-
        nil                ; no possible clobberers / new ests
        t                  ; possible clobberers / new ests exist
     )) )

(defun nec-pos-clobbered-p (plan e u p-)
   "abtweak/ab-msp
    modified w-msp implementation - nils blocks domain
    return true if establisher e is 1st param necessarily clobbered
                                    rest params possibly clobbered "
    ; ie iff
    ; exists some operator c, nec between pos-est and u such that
    ;                      c  nec denies  param 1 of p- &
    ;                      c  pos denies  rest params of p- 
    ;   or 
    ; exists some operator c, nec between pos-est and u such that
    ;                      c  nec asserts param 1 of p- &
    ;                      c  pos asserts rest params of p-
 (declare 

         (type plan plan)
         (type atom e)    ; establisher
         (type atom u)    ; user
         (type list p-)   ; predicate
  )
 (let (
        (n-betw  (all-nece-between e u plan))
      )
    (declare (type list n-betw)
     )
    (if (and (null (np-clobbers-p plan n-betw p-))  ; t if any necpos clob p-
             (null (np-asserts-p  plan n-betw p-)) ); t if any necpos assrts p-
        nil                ; no possible clobberers / new ests
        t                  ; possible clobberers / new ests exist
     )) )

(defun np-clobbers-p (plan n-betw p-)
  "abtweak/ab-msp
   true if any of ops in n-betw s.t. ops necpos deny p-"
   (declare
           (type plan plan)
           (type list n-betw)
           (type list p-)
    )
   (if (null (car n-betw))
       nil
       (if (np-est-p (car n-betw) (negate p-) plan)  ;this op ests (not p-)
           t
           (np-clobbers-p plan (cdr n-betw) p-))) )

(defun np-asserts-p (plan n-betw p-)
  "abtweak/ab-msp
   true if any of ops in n-betw s.t. ops necpos assert p-"
   (declare
           (type plan plan)
           (type list n-betw)
           (type list p-)
    )
   (if (null (car n-betw))
       nil
       (if (np-est-p (car n-betw) p- plan)
           t
           (np-asserts-p plan (cdr n-betw) p-))) )

(defun n-clobbers-p (plan n-betw p-)
  "abtweak/ab-msp
   true if any of ops in n-betw s.t. ops nec deny p-"
   (declare
           (type plan plan)
           (type list n-betw)
           (type list p-)
    )
   (if (null (car n-betw))
       nil
       (if (nece-est-p (car n-betw) (negate p-) plan)  ;this op ests (not p-)
           t
           (n-clobbers-p plan (cdr n-betw) p-))) )

(defun p-clobbers-p (plan n-betw p-)
  "abtweak/ab-msp
   true if any of ops in n-betw s.t. ops pos deny p-"
   (declare
           (type plan plan)
           (type list n-betw)
           (type list p-)
    )
   (if (null (car n-betw))
       nil
       (if (poss-est-p (car n-betw) (negate p-) plan)  ;this op ests (not p-)
           t
           (p-clobbers-p plan (cdr n-betw) p-))) )

(defun n-asserts-p (plan n-betw p-)
  "abtweak/ab-msp
   true if any of ops in n-betw s.t. ops nec assert p-"
   (declare
           (type plan plan)
           (type list n-betw)
           (type list p-)
    )
   (if (null (car n-betw))
       nil
       (if (nece-est-p (car n-betw) p- plan)
           t
           (n-asserts-p plan (cdr n-betw) p-))) )

(defun p-asserts-p (plan n-betw p-)
  "abtweak/ab-msp
   true if any of ops in n-betw s.t. ops pos assert p-"
   (declare
           (type plan plan)
           (type list n-betw)
           (type list p-)
    )
   (if (null (car n-betw))
       nil
       (if (poss-est-p (car n-betw) p- plan)
           t
           (p-asserts-p plan (cdr n-betw) p-))) )

;***************************************************************************
;  strong monotonic solution property implementation
;***************************************************************************

(defun violates-msp-strong (plan )
  "abtweak/ab-msp
   true if plan violates strong msp"
   ; ie must have only successors that do
   ; if any est( ek/i u/i p/i) is nec clob at any cr/i, discard - ie return t
   ; 
 (declare (type plan plan))
 (let* (
         (cr            (get_cr plan))
         (up-pairs      (find-all-up-pairs cr))
         (v-msp-s-flag  (strong-violation-p plan cr up-pairs))
        )
  (declare 
          (type list cr)
          (type (list list) up-pairs)
          (type boolean v-msp-s-flag)
   )
    (if (and *debug* v-msp-s-flag)
        (progn
              (terpri)
              (princ "plan violating strong msp not expanded: ")
              (princ (get_id plan))
              (terpri) (terpri)
         ))
    (if v-msp-s-flag 
        (setq *s-msp-pruned* (1+ *s-msp-pruned*)))
    v-msp-s-flag
 ))


(defun strong-violation-p (plan cr up-pairs)
  "abtweak/ab-msp
   true if up-pairs indicates a strong msp violation"
  (declare 
           (type plan plan)
           (type list cr)
           (type (list list) up-pairs)
   )
  (if (null (car up-pairs))     ; no more cr/i to check?
      nil                       ;   done, no violation found
      (if (or
              (any-est-clob-this-cri plan cr (car up-pairs))
              (strong-violation-p plan cr (cdr up-pairs)) )
          t    ; a  violation of strong msp found 
          nil  ; no violation of strong msp found
      )) )

(defun any-est-clob-this-cri (plan cr up-cr)
   "abtweak/ab-msp
    true if any of any one (level k) cri is clobbered in level k-1 plan"
  (declare
          (type plan plan)
          (type list cr)
          (type list up-cr)
   )
  (let* (
        ; list of k-1 establishers of this u p- (up-cr)
        (u        (first up-cr))
        (p-       (second up-cr))       
        (pos-ests (get-cr-ests cr u p-))
       )
     (declare
             (type list pos-ests)
             (type atom u)
             (type list p-)
      )
     (if (any-ests-clob-p plan pos-ests u p-)
         t
         nil
     )) )

(defun any-ests-clob-p (plan pos-ests u p-)
  "abtweak/ab-msp
   return true if any establishers in list are clobbered"
  (declare
          (type plan plan)
          (type list pos-ests)
          (type atom u)
          (type list p-)
   )
  (if (null (car pos-ests))
      nil
      (if (or
              (nec-clobbered-p     plan (car pos-ests) u p-)
              (any-ests-clob-p plan (cdr pos-ests)  u p-) )
          t
          nil
       )) )


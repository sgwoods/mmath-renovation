;***************************************************************************
; tower of hanoi (2) domain definition
;  modified oct 11, 1990 for ispeg
;***************************************************************************
(setq *domain* 'hanoi-2-ispeg)

(setq a (create-operator-instance
         :opid 'moveb
         :name '(moveb $x $y)
         :cost 1
         :preconditions '((not ons $x) (onb $x) (not ons $y)
                          (ispeg $x) (ispeg $y))
         :effects '((not onb $x) (onb $y))))

(setq b (create-operator-instance
         :opid 'moves
         :name '(moves $x $y)
         :cost 1
         :preconditions '((ons $x) (ispeg $x) (ispeg $y))
         :effects '((not ons $x) (ons $y))))

(setq *operators* (check-primary-effects (list a b)))

; initial state
;
(setq initial '((ispeg peg1) (ispeg peg2) (ispeg peg3)
                (onb peg1) (ons peg1)
                (not onb peg2)
                (not onb peg3)
                (not ons peg2)
                (not ons peg3)))

; goal state
;
(setq goal '((onb peg3) (ons peg3)))
(setq goals '((ons peg3)))
(setq goalb '((onb peg3)))

;***************************************************************************
; abtweak domain part criticality assignments.
;***************************************************************************

(setq *ibs* '(
   (2 (ispeg $))
   (1 (not onb $) (onb $))
   (0 (not ons $) (ons $))
))

(setq *sib* '(
   (2 (not ons $) (ons $))
   (1 (ispeg $))
   (0 (not onb $) (onb $))
))

(setq *bsi* '(
   (2 (not onb $) (onb $))
   (1 (not ons $) (ons $))
   (0 (ispeg $))
))

(setq *bis* '(
   (2 (not onb $) (onb $))
   (1 (ispeg $))
   (0 (not ons $) (ons $))
))

(setq *sbi* '(
   (2 (not ons $) (ons $))
   (1 (not onb $) (onb $))
   (0 (ispeg $))
))

(setq *isb* '(
   (2 (ispeg $))
   (1 (not ons $) (ons $))
   (0 (not onb $) (onb $))
))

(setq *ibs-k-list* '(0 1 3))
(setq *sib-k-list* '(1 1 3))
(setq *bsi-k-list* '(1 3 3))
(setq *bis-k-list* '(0 1 3))
(setq *sbi-k-list* '(1 3 3))
(setq *isb-k-list* '(0 1 3))

(setq *critical-list* *ibs*)
(setq *critical-loaded* 'ibs-default)
(setq *left-wedge-list* *ibs-k-list*)

;***************************************************************************
; tower of hanoi (2) domain definition 
;  modifed oct 11, 1990 for ispeg 
;***************************************************************************
(setq *domain* 'hanoi-2-ispeg)

(setq a (create-operator-instance
	 :opid 'moveb
	 :name '(moveb $x $y)
	 :preconditions '((not ons $x) (onb $x) (not ons $y)
                          (ispeg $x) (ispeg $y) )
	 :effects '((not onb $x) (onb $y))))

(setq b (create-operator-instance
	 :opid 'moves
	 :name '(moves $x $y)
	 :preconditions '((ons $x)
                          (ispeg $x) (ispeg $y) )
	 :effects '((not ons $x) (ons $y))))


(setq *operators* (list a b))

; initial state
;
(setq initial '((ispeg peg1) (ispeg peg2) (ispeg peg3)
                (onb peg1) (ons peg1) 
		(not onb peg2)
		(not onb peg3)
		(not ons peg2)
		(not ons peg3)))

;goal state
;
(setq goal '((onb peg3) (ons peg3)))

;***************************************************************************
; abtweak domain part - refered to only in abtweak
;***************************************************************************

(setq *critical-list* '(
   (2  (ispeg $) )
   (1  (not onb $) (onb $) )
   (0  (not ons $) (ons $) )
))

(setq *critical-loaded* 'ibs-default)

(setq *k-list* '(0 1 2))

(setq *top-down-levels*     
'(
  2
  1
))


; load testing criticality definition load routines (hanoi2)
;
;(load "/u/sgwoods/plan/planner/domains/hanoi-2/load-tests")

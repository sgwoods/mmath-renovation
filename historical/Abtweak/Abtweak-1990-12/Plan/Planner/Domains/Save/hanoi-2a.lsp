;***************************************************************************
; tower of hanoi (2) domain definition 
;  modifed oct 11, 1990 for ispeg 
;  modified oct 13 for simpler preconditions
;***************************************************************************
(setq *domain* 'hanoi-2-ispeg)

(setq a (create-operator-instance
	 :opid 'moveb
	 :name '(moveb $x $y $z)
	 :preconditions '((onb $x) (ons $z)
                          (ispeg $x) (ispeg $y) (ispeg $z) )
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
   (0  (ispeg $) (not ons $) (ons $) )
   (1  (not onb $) (onb $) )
))

(setq *top-down-levels*     
'(
  1
))


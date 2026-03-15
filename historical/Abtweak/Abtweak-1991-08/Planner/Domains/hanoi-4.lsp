;***************************************************************************
; tower of hanoi (4) domain definition
;  modifed oct 11, 1990 for ispeg 
;***************************************************************************
(setq *domain* 'hanoi-4-ispeg)

(setq z (create-operator-instance
	 :opid 'moveh
	 :name '(moveh $x $y)
	 :preconditions '((ispeg $x) (ispeg $y)
                          (not ons $x) 
			  (not onm $x) 
			  (not onb $x) 
			  (not ons $y)
			  (not onm $y)
			  (not onb $y)
			  (onh $x))
	 :effects '((not onh $x) 
		    (onh $y))))

(setq a (create-operator-instance
	 :opid 'moveb
	 :name '(moveb $x $y)
	 :preconditions '((ispeg $x) (ispeg $y)
                          (not ons $x) 
			  (not onm $x) 
			  (not ons $y)
			  (not onm $y)
			  (onb $x))
	 :effects '((not onb $x) 
		    (onb $y))))

(setq b (create-operator-instance
	 :opid 'movem
	 :name '(movem $x $y)
	 :preconditions '((ispeg $x) (ispeg $y)
                          (not ons $x) 
			  (not ons $y)			 
			  (onm $x))
	 :effects '((not onm $x) 
		    (onm $y))))

(setq c (create-operator-instance
	 :opid 'moves
	 :name '(moves $x $y)
	 :preconditions '((ispeg $x) (ispeg $y) (ons $x))
	 :effects '((not ons $x) (ons $y))))


(setq *operators* (list z a b c))

; initial state
;
(setq initial '((ispeg peg1) (ispeg peg2) (ispeg peg3) 
                (onh peg1) (onb peg1) (onm peg1) (ons peg1) 
		(not onh peg2)
		(not onh peg3)
		(not onb peg2)
		(not onb peg3)
		(not onm peg2)
		(not onm peg3)
		(not ons peg2)
		(not ons peg3)))

;goal state
;
(setq goal '( (onh peg3) (onb peg3) (onm peg3) (ons peg3)))

;***************************************************************************
; abtweak domain part - refered to only in abtweak
;***************************************************************************

(setq *critical-list* '(
   (3  (ispeg $) (not onh $) (onh $) )
   (2  (not onb $) (onb $) )
   (1  (not onm $) (onm $) )
   (0  (not ons $) (ons $) )
))

(setq *top-down-levels*     
'(
  3
  2
  1
))



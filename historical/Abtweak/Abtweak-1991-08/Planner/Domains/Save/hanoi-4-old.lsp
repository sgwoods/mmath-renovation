;***************************************************************************
; TOWER OF HANOI (4) DOMAIN DEFINITION
;  NOT modifed oct 11, 1990 for ISPEG 
;***************************************************************************
(setq *DOMAIN* 'hanoi-4-old)

(setq z (create-operator-instance
	 :opid 'moveh
	 :name '(moveh $x $y)
	 :preconditions '(
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
	 :preconditions '(
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
	 :preconditions '(
                          (not ons $x) 
			  (not ons $y)			 
			  (onm $x))
	 :effects '((not onm $x) 
		    (onm $y))))

(setq c (create-operator-instance
	 :opid 'moves
	 :name '(moves $x $y)
	 :preconditions '((ons $x))
	 :effects '((not ons $x) (ons $y))))


(setq *operators* (list z a b c))

; Initial State
;
(setq initial '(
                (onh peg1) (onb peg1) (onm peg1) (ons peg1) 
		(not onh peg2)
		(not onh peg3)
		(not onb peg2)
		(not onb peg3)
		(not onm peg2)
		(not onm peg3)
		(not ons peg2)
		(not ons peg3)))

;Goal State
;
(setq goal '( (onh peg3) (onb peg3) (onm peg3) (ons peg3)))

;***************************************************************************
; ABTWEAK DOMAIN PART - refered to ONLY IN AbTweak
;***************************************************************************

(setq *critical-list* '(
   (3  (not onh $) (onh $) )
   (2  (not onB $) (onB $) )
   (1  (not onM $) (onM $) )
   (0  (not onS $) (onS $) )
))

(setq *top-down-levels*     
'(
  3
  2
  1
))



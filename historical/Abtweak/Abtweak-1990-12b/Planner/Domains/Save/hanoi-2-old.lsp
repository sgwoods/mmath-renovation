;***************************************************************************
; TOWER OF HANOI (2) DOMAIN DEFINITION 
;  NOT modifed oct 11, 1990 for ISPEG 
;***************************************************************************
(setq *DOMAIN* 'hanoi-2-old)

(setq a (create-operator-instance
	 :opid 'moveb
	 :name '(moveb $x $y)
	 :preconditions '((not ons $x) (onb $x) (not ons $y) )
	 :effects '((not onb $x) (onb $y))))

(setq b (create-operator-instance
	 :opid 'moves
	 :name '(moves $x $y)
	 :preconditions '((ons $x) )
	 :effects '((not ons $x) (ons $y))))

(setq *operators* (list a b))

; Initial State
;
(setq initial '(
                (onb peg1) (ons peg1) 
		(not onb peg2)
		(not onb peg3)
		(not ons peg2)
		(not ons peg3)))

;Goal State
;
(setq goal '((onb peg3) (ons peg3)))

;***************************************************************************
; ABTWEAK DOMAIN PART - refered to ONLY IN AbTweak
;***************************************************************************

(setq *critical-list* '(
   (0  (not onS $) (onS $) )
   (1  (not onB $) (onB $) )
))

(setq *top-down-levels*     
'(
  1
))


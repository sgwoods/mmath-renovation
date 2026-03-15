;***************************************************************************
; TOWER OF HANOI (3) DOMAIN DEFINITION
;  NOT modifed oct 11, 1990 for ISPEG 
;***************************************************************************
(setq *DOMAIN* 'hanoi-3-old)

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
	 :preconditions '( (ons $x))
	 :effects '((not ons $x) (ons $y))))


(setq *operators* (list a b c))

; Initial State
;
(setq initial '(
                (onb peg1) (onm peg1) (ons peg1) 
		(not onb peg2)
		(not onb peg3)
		(not onm peg2)
		(not onm peg3)
		(not ons peg2)
		(not ons peg3)))

;Goal State
;
(setq goal '((onb peg3) (onm peg3) (ons peg3)))

;***************************************************************************
; ABTWEAK DOMAIN PART - refered to ONLY IN AbTweak
;***************************************************************************

; Default Criticality List
;
; see others in:
; /u/sgwoods/Plan/Tweak2/Examples/hanoi-3/critical-N.lsp
;  where N = the number of the example

(setq *critical-list* '(
   (2  (not onB $) (onB $) )
   (1  (not onM $) (onM $) )
   (0  (not onS $) (onS $) )
))

(setq *top-down-levels*     
'(
  2
  1
))



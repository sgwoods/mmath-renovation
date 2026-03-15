;***************************************************************************
; tower of hanoi (3) domain definition
;  modifed oct 11, 1990 for ispeg 
;  modifed oct 13, 1990 for preconditions: chg (~ons x) (~ons y) to (ons z)
;                           taking advantage of the fact that there are 
;                           only 3 pegs !! (qiang)
;***************************************************************************
(setq *domain* 'hanoi-3a-ispeg)

(setq a (create-operator-instance
	 :opid 'moveb
	 :name '(moveb $x $y $z)
	 :preconditions '((ispeg $x) (ispeg $y) (ispeg $z)
                          (ons $z) 
			  (onm $z) 
			  (onb $x))
	 :effects '((not onb $x) 
		    (onb $y))))

(setq b (create-operator-instance
	 :opid 'movem
	 :name '(movem $x $y $z)
	 :preconditions '((ispeg $x) (ispeg $y)
                          (ons $z) 
			  (onm $x))
	 :effects '((not onm $x) 
		    (onm $y))))

(setq c (create-operator-instance
	 :opid 'moves
	 :name '(moves $x $y)
	 :preconditions '((ispeg $x) (ispeg $y) (ons $x))
	 :effects '((not ons $x) (ons $y))))


(setq *operators* (list a b c))

; initial state
;
(setq initial '((ispeg peg1) (ispeg peg2) (ispeg peg3) 
                (onb peg1) (onm peg1) (ons peg1) 
		(not onb peg2)
		(not onb peg3)
		(not onm peg2)
		(not onm peg3)
		(not ons peg2)
		(not ons peg3)))

;goal state
;
(setq goal '((onb peg3) (onm peg3) (ons peg3)))

;***************************************************************************
; abtweak domain part - refered to only in abtweak
;***************************************************************************

; default criticality list
;
; see others in:
; /u/sgwoods/plan/tweak2/examples/hanoi-3/critical-n.lsp
;  where n = the number of the example

(setq *critical-list* '(
   (2  (ispeg $) (not onb $) (onb $) )
   (1  (not onm $) (onm $) )
   (0  (not ons $) (ons $) )
))

(setq *top-down-levels*     
'(
  2
  1
))



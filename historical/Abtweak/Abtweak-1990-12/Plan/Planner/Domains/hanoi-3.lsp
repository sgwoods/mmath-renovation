;***************************************************************************
; tower of hanoi (3) domain definition
;  modifed oct 11, 1990 for ispeg 
;  modifed oct 24, 1990 for k-setting
;***************************************************************************
(setq *domain* 'hanoi-3-ispeg)

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
; /u/sgwoods/plan/tweak2/examples/hanoi-3/

(setq *critical-list* '(
   (5  (not onm $) )
   (4  (not ons $) )
   (3  (onb $) )
   (2  (onm $) )
   (1  (ons $) )
   (0  (ispeg $) )
))
(setq *critical-loaded* 'ibms-new-default)

; preference values for each successive level of abstraction
;  - related to top down property
;  this value is factored into the heuristic for preference of
;  plans - essentially preferring level k over level k+1 by a
;  depth-factor as indicated in *k-list* at this k
;
(setq *k-list* '(0 1 3 7))

(setq *top-down-levels*     
'(
  3
  2
  1
))

; load testing criticality definition load routines (hanoi3)
;
;(load "/u/sgwoods/plan/planner/domains/hanoi-3/load-tests")

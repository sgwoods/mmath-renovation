;***************************************************************************
; tower of hanoi (3) domain definition
;  modifed oct 11, 1990 for ispeg 
;  modifed oct 24, 1990 for k-setting
;***************************************************************************
(setq *domain* 'hanoi-3-ispeg)

(setq a (create-operator-instance
	 :opid 'moveb
	 :name '(moveb $x $y)
	 :cost 1
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
	 :cost 1
	 :preconditions '((ispeg $x) (ispeg $y)
                          (not ons $x) 
			  (not ons $y)			 
			  (onm $x))
	 :effects '((not onm $x) 
		    (onm $y))))

(setq c (create-operator-instance
	 :opid 'moves
	 :name '(moves $x $y)
	 :cost 1
	 :preconditions '((ispeg $x) (ispeg $y) (ons $x))
	 :effects '((not ons $x) (ons $y))))


(setq *operators* (check-primary-effects (list a b c)))

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
(setq goals '((ons peg3)))
(setq goalm '((onm peg3)))
(setq goalb '((onb peg3)))


;***************************************************************************
; abtweak domain part criticality assignments.
;***************************************************************************

; default criticality list
;
(setq *critical-list-2* '(
   (5 (ispeg $))			  
   (4  (onb $) )
   (3  (not onm $) )
   (2  (onm $) )
   (1  (not ons $) )
   (0  (ons $) )
))

(setq *critical-list-1* '(
   (3 (ispeg $))			
   (2  (not onb $) (onb $) )
   (1  (not onm $) (onm $) )
   (0  (not ons $) (ons $) )
))

(setq *ismb* '(
   (3 (ispeg $))			
   (2  (not ons $) (ons $) )
   (1  (not onm $) (onm $) )
   (0  (not onb $) (onb $) )
))

(setq *imbs* '(
   (3 (ispeg $))			
   (2  (not onm $) (onm $) )
   (1  (not onb $) (onb $) )
   (0  (not ons $) (ons $) )
))

(setq *ibsm* '(
   (3 (ispeg $))
   (2  (not onb $) (onb $) )
   (1  (not ons $) (ons $) )
   (0  (not onm $) (onm $) )
))

(setq *isbm* '(
   (3 (ispeg $))
   (2  (not ons $) (ons $) )
   (1  (not onb $) (onb $) )
   (0  (not onm $) (onm $) )
))



(setq *critical-loaded* 'ibms-new-default)

;**************** settings for left-wedge mode *************

; preference values for each successive level of abstraction
;  - related to top down property
;  this value is factored into the heuristic for preference of
;  plans - essentially preferring level k over level k+1 by a
;  depth-factor as indicated in *k-list* at this k
;
(setq *k-list-1* '(0 1 3 7))
(setq *k-list-2* '(0 1 3 5 7 9))

(setq *critical-list* *critical-list-1* )
(setq *left-wedge-list* *k-list-1*)

;***************************************************************************
; tower of hanoi (4) domain definition
;***************************************************************************
(setq *domain* 'hanoi-4)

(setq d (create-operator-instance
	 :opid 'moveh
	 :name '(moveh $x $y)
	 :cost 1
	 :preconditions '((ispeg $x) (ispeg $y)
			  (not onb $x)
			  (not onb $y)
			  (not onm $x) 
			  (not onm $y)
			  (not ons $x)
                          (not ons $y) 
			  (onh $x))
	 :effects '((not onh $x) 
		    (onh $y))))


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


(setq *operators* (list a b c d))

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
(setq goal '((onh peg3 )(onb peg3) (onm peg3) (ons peg3)))
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
   (4 (ispeg $))			
   (3  (not onh $) (onh $) )
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

; additional permutation-style hierarchy variants, mirroring the historical
; hanoi-3 experiment family while allowing omitted predicates to fall to
; criticality 0 via find-crit.
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

; historical 1991 four-disk default hierarchy where peg identity and onh share
; the top abstraction level. This is kept separate from the later 1993 default
; so we can compare the two control surfaces directly.
(setq *legacy-1991-default* '(
   (3  (ispeg $) (not onh $) (onh $) )
   (2  (not onb $) (onb $) )
   (1  (not onm $) (onm $) )
   (0  (not ons $) (ons $) )
))


(setq *critical-loaded* '*critical-list-1*)

;**************** settings for left-wedge mode *************

; preference values for each successive level of abstraction
;  - related to top down property
;  this value is factored into the heuristic for preference of
;  plans - essentially preferring level k over level k+1 by a
;  depth-factor as indicated in *k-list* at this k
;
(setq *k-list-1* '(0 1 3 7 9))
(setq *k-list-2* '(0 1 3 5 7 9))
(setq *legacy-1991-k-list* '(0 1 3 7))

(setq *critical-list* *critical-list-1* )
(setq *left-wedge-list* *k-list-1*)

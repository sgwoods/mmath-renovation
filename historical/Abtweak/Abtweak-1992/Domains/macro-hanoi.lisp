;***************************************************************************
; tower of hanoi (3) domain definition
;***************************************************************************

(setq *domain* 'hanoi-learned)

(setq a (create-operator-instance
	 :opid 'move
	 :name '(move $disk $x $y)
	 :cost 1
	 :preconditions '((smaller $disk $y)
			  (clear $disk)
  			  (clear $y)
			  (on $disk $x))
	 :effects '((not clear $y)
		    (on $disk $y)
		    (not on $disk $x)
		    (clear $x))))


(setq b (create-operator-instance
	 :opid 'macro-move
	 :name '(move-stack $x $from $temp $to $u)
	 :cost 1
	 :preconditions '((on $u $x)
			  (on $x $from)
			  (clear $to)
  			  (clear $temp)
			  (smaller $x $to)
			  (smaller $u $temp))

	 :effects '((not clear $to)
		    (on $x $to)
		    (not on $x $from)
		    (clear $from))))



(setq *operators* (list a b))

; initial state
;
(setq initial '(
		(on b peg1) (on m b) (on s m) 
		(clear s) (clear peg2) (clear peg3)
		(smaller s m)
 		(smaller m b) 
		(smaller s b) 
		(smaller s peg1) 
		(smaller s peg2)
		(smaller s peg3) 
		(smaller m peg1) 
		(smaller m peg2)
		(smaller m peg3) 
		(smaller b peg1) 
		(smaller b peg2)
		(smaller b peg3)))

;goal state
;
(setq goal '((on s m) (on m b) (on b peg3)))

; Moving a stack of blocks may seem to make planning useless.
; However, the trick is, what if you move some disks: say that you
; want to move a subset of blocks from some initial stacks.  How do
; you do that using the macros?  Thus, it is still valuable to do.

(setq initial-4 '(
		  (on s m) (on m b) (on b h) (on h  peg1) 

		(clear s) (clear peg2) (clear peg3)

		(smaller s h)
		(smaller m h)
		(smaller b h)
		(smaller h peg1)
		(smaller h peg2)
		(smaller h peg3)

		(smaller s m)

 		(smaller m b) 
		(smaller s b) 

		(smaller s peg1) 
		(smaller s peg2)
		(smaller s peg3) 
		(smaller m peg1) 
		(smaller m peg2)
		(smaller m peg3) 
		(smaller b peg1) 
		(smaller b peg2)
		(smaller b peg3)))

;goal state
;
(setq goal-4 '((on h peg3) (on m h)))


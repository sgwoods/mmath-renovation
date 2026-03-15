;***************************************************************************
; nilsson blocks world domain definition
;***************************************************************************
(setq *domain* 'nilssons-blocks-world)

; operators

(setq a (make-operator
	 :opid 'pickup
	 :name '(pickup $x)
	 :cost 1
	 :preconditions '((ontable $x)
			  (clear $x)
			  (handempty))

	 :effects '((holding $x)
		    (not ontable $x)
		    (not clear $x)
		    (not handempty))))



(setq b (make-operator
	 :opid 'putdown
	 :name '(putdown $x)
	 :cost 1
	 :preconditions '((holding $x))

	 :effects '((ontable $x)
		    (clear $x)
		    (handempty)
		    (not holding $x))))


(setq c (make-operator
	 :opid 'stack
	 :name '(stack $x $y)
	 :cost 1
	 :preconditions '((holding $x)
			  (clear $y))

	 :effects '((on $x $y)
		    (clear $x)
		    (handempty)
		    (not holding $x)
		    (not clear $y))))


(setq d (make-operator
	 :opid 'unstack
	 :name '(unstack $x $y)
	 :cost 1
	 :preconditions '((on $x $y)
			  (clear $x)
                          (handempty))

	 :effects '((clear $y)
		    (not clear $x)
		    (not handempty)
		    (holding $x)
		    (not on $x $y))))





(setq *operators* (list a b c d))

; initial state
;
(setq initial '((on c a) (ontable a) (ontable b)
		(clear c) (clear b) (handempty)))


;goal state
;
(setq goal '((on a b) (on b c)))

;***************************************************************************
; abtweak domain part - refered to only in abtweak
;***************************************************************************

(setq *critical-list* '(
   (1  (not on $ $) (on $ $) )
   (0  (clear $) (not clear $) 
       (ontable $) (not ontable $)
       (holding $) (not holding $) 
       (handempty) (not handempty) )
 ))
(setq *critical-loaded* 'nils-default)

(setq *left-wedge-list* '(0 1 2))


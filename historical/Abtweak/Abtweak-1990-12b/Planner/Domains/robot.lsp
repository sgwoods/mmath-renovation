;***************************************************************************
; Strips ROBOT domain definition
;***************************************************************************
(setq *domain* 'robot)

; operators

(setq a (make-operator
	 :opid 'puton
	 :name '(puton $x $y $z)
	 :preconditions '((not-table $x)
			  (not-table $y)
			  (on $x $z)
			  (clear $x)
			  (clear $y))
	 :effects '((on $x $y)
		    (not on $x $z)
		    (not clear $y)
		    (clear $z))))

(setq b (make-operator
	 :opid 'newtower
	 :name '(newtower $x $z)
	 :preconditions '((not-table $x)
			  (not-table $z)
			  (on $x $z)
			  (clear $x))
	 :effects '((on $x  table)
		    (not on $x $z)
		    (clear $z))))

(setq *operators* (list a b))

; initial state
;
(setq initial '((on c a) (on a table) (on b table) 
		(clear c) (clear b) (not-table a) (not-table b)
		(not-table c)))

;goal state
;
(setq goal '((on a b) (on b c)))

;***************************************************************************
; abtweak domain part - refered to only in abtweak
;***************************************************************************

(setq *critical-list* '(
   (2  (not on c $) (on c $) )
   (1  (not on b $) (on b $) )
   (0  (not on $ $) (on $ $) (clear $) (not clear $) (not-table $) )
))

(setq *top-down-levels*     
'(
  2
  1
))

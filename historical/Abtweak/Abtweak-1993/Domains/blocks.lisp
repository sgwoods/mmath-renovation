;***************************************************************************
; blocks world domain definition
;***************************************************************************
(setq *domain* 'blocks-world)

; operators

(setq a (make-operator
	 :opid 'puton
	 :name '(puton $x $y $z)
	 :cost 1
	 :preconditions '((is-block $x)
			  (is-block $y)
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
	 :cost 1
	 :preconditions '((is-block $x)
			  (is-block $z)
			  (on $x $z)
			  (clear $x))
	 :effects '((on $x  table)
		    (not on $x $z)
		    (clear $z))))

(setq *operators* (list a b))

; initial state
;
(setq initial '((on c a) (on a table) (on b table) 
		(clear c) (clear b) (is-block a) (is-block b) (is-block d)
		(is-block c)))

;goal state
;
(setq goal '((on a b) (on b c)))


;***************************************************************************
; abtweak domain part - refered to only in abtweak
;***************************************************************************

(setq *critical-list* '(
   (2  (is-block $))
   (1 (clear $) (not clear $) (not on $ $))
   (0  (on $ $) )
))

(setq *critical-list* '(
   (2  (is-block $) (clear c) (not clear c) (not on c $) (on c $))
   (1   (clear b) (not clear b) (not on b $) (on b $))
   (0   (clear $) (not clear $) (not on $ $) (on $ $))
))



(setq *left-wedge-list* '(0 1 2))


(defun sussman ()
  (setq initial '((on c a) (on a table) (on b table) 
		(clear c) (clear b) (is-block a) (is-block b) (is-block d)
		(is-block c)))

;goal state
;
(setq goal '((on a b) (on b c))))


(defun interchange ()

  (setq initial '((on a b) (on b table) (on c d) (on d table)
		  (clear a) (clear c) 
		  (is-block a) (is-block b) (is-block d)
		  (is-block c)))

					;goal state
					;
  (setq goal '((on a d) (on c b))))


(defun flatten ()
  

  (setq initial '((on a b) (on b table) (on c d) (on d table)
		  (clear a) (clear c) 
		  (is-block a) (is-block b) (is-block d)
		  (is-block c)))

					;goal state
					;
  (setq goal '((on a table) (on b table) (on c table) (on b table))))

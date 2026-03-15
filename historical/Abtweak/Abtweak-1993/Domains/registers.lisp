; register exchange example.

(setq *domain* 'register-exchange)

; operators

(setq a (make-operator 
	 :opid 'assign
	 :name '(assign $x $y $u $v)
	 :cost 1
	 :preconditions
	 '( (content $x $u)
	    (content $y $v))

	 :effects
	 '( (content $x $v)
	    (not content $x $u))))

(setq *operators* (list a))

; initial state

(setq initial '((content x a) (content y b) (content z c)))

(setq goal '((content x b) (content y a)))

(setq *critical-list* 
      '((0 (content $ $) (not content $ $))))

(setq *k-list '(0))

;
; Loop example, from Chapman 1987.
;
(setq *domain* 'loop-world)

; operators

(setq a (make-operator
	 :opid 'a
	 :name '(a )
	 :cost 1
	 :preconditions '((not h))

	 :effects '((g)
		    (not h))))



(setq b (make-operator
	 :opid 'b
	 :name '(b )
	 :cost 1
	 :preconditions '((not g))

	 :effects '((h)
		    (not g))))

(setq *operators* (list a b))

; initial state
;
(setq initial '((not h) (not g)))

;goal state
;
(setq goal '((g) (h)))



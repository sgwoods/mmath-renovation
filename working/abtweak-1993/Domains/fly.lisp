;;; flying domain.
;;;
;;; remember to use :use-primary-effect-p t.
;;;
;;; Demonstrate:
;;; When the probability is low, one should not use abstraction!
;;; ---Even when the domain is OM.


(setq o1 (make-operator
	  :cost 1
	  :opid 'fly
	  :name '(fly $x $y)
	  :preconditions
	  '( (connected $x $y)
	     (at-terminal takeoff $x)
	     (at-airport $x))

	  :effects
	  '( (at-airport $y)
	     (at-terminal land $y)
	     (not at-airport $x)
	     (not at-terminal takeoff $x))
	  :primary-effects
	  '((at-airport $y))))


(setq o2 (make-operator
	  :cost 1
	  :opid 'switch-terminals
	  :name '(switch-terminal land takeoff $x)
	  :preconditions
	  '( (functional $x)
	     (at-airport $x))
;	     (at-terminal land $x))
	  :effects
	  '( (at-terminal takeoff $x)
	     (not at-terminal land $x))
	  :primary-effects
	  '( (at-terminal takeoff $x))))

(setq *operators* (check-primary-effects (list o1 o2)))

(setq *critical-list*
      '( (2 (connected $ $) (functional $))
	 (1 (at-airport $) (not at-airport $))
	 (0 (at-terminal $ $) (not at-terminal $ $))))

(setq *left-wedge-list* '(0 1 3))

(setq initial
      '(
	(at-airport toronto)
	(at-terminal takeoff toronto)

	(connected toronto detroit)
	(connected detroit washington-dc)
	(connected detroit mn)
	(connected detroit la)
	(connected mn san-francisco)
	(connected san-francisco la)
	(connected la san-francisco)
	(connected washington-dc ny-city)
	
	(functional toronto)
	(functional detroit)
	(functional mn)
;	(functional la)
	(functional san-francisco)
	(functional washington-dc)))
	

(setq goal-sf '((at-airport san-francisco)))

(setq goal-dc '((at-airport washington-dc)))
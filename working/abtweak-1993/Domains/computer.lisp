(setq o1 
      (make-operator
       :opid 'print
       :cost 1
       :name '(print $file $computer $printer)
       :preconditions
       '( 
	 (power-on $computer)
	 (power-on $printer)
	 (is-computer $computer)
	 (is-printer $printer)
	 (loaded $file $computer)
	 )
       :effects
       '(
	 (printed $file)
	 )))

(setq o2
      (make-operator
       :opid 'turn
       :cost 1
       :name '(turn-on $device)
       :preconditions
       '(
	 (plugged-in $device)
	 (functional $device)
	 )
       :effects
       '(
	 (power-on $device)
	 )))

(setq o3
      (make-operator
       :opid 'plug
       :cost 1
       :name '(plug-in $device $outlet)
       :preconditions
       '(
	 (is-outlet $outlet)
	 (cable-can-reach $device $outlet)
	 )
       :effects
       '(
	 (plugged-in $device)
	 )))

(setq o4 
      (make-operator
       :opid 'load
       :cost 1
       :name '(load $file $computer)
       :preconditions
       '(
	 (is-computer $computer)
	 (power-on $computer)
	 )
       :effects
       '(
	 (loaded $file $computer)
	 )))


(setq *operators* (check-primary-effects (list o1 o2 o3 o4)))

(setq *critical-list*
      '(
	(3 (is-outlet $)
	   (is-computer $)
	   (is-printer $)
	   (functional $)
	   (cable-can-reach $ $))
	(2 (printed $)
	   (loaded $ $))
	(1 (power-on $))
	(0 (plugged-in $))))


(setq *left-wedge-list* '(0 1 3 5 7 9 11))


(setq 
 initial 
 '(
   (functional mac1)
   (is-computer mac1)
   (cable-can-reach mac1 outlet1)

   (functional sun1)
   (is-computer sun1)

   
   (functional laser-printer-1)
   (is-printer laser-printer-1)
   (cable-can-reach laser-printer-1 outlet1)

   (is-outlet outlet1)))


(setq goal '((printed aaai.dvi)))

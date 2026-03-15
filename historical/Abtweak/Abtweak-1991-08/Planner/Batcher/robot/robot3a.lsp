(robot)

(setq goal '( (at box3 loc20) (at robot loc15) ))

(time (planner initial goal
	       :planner-mode 'abtweak
	       :crit-depth-mode t
	       :motive-discard t
	       :msp-mode 'weak
 ))

(bye)



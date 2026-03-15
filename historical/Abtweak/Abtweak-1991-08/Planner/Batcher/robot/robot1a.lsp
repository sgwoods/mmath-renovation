(robot)

(setq goal '( (at robot loc20) (holding box3) ))

(time (planner initial goal
	       :planner-mode 'abtweak
	       :crit-depth-mode t
	       :motive-discard t
	       :msp-mode 'weak
 ))

(bye)



(robot)

(setq goal '( (at box3 loc18) (inroom robot room5) ))

(time (planner initial goal
	       :planner-mode 'abtweak
	       :crit-depth-mode t
	       :motive-discard t
	       :msp-mode 'weak
 ))

(bye)



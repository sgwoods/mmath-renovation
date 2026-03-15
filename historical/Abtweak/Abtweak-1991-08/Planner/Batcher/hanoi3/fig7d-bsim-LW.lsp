(h3)
(load "Domains/hanoi3/bsim")

(time (planner initial goal 
	       :planner-mode 'abtweak
               :crit-depth-mode t
 ))

(bye)



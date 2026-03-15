(h3)
(load "Domains/hanoi3/ismb")

(time (planner initial goal 
	       :planner-mode 'abtweak
               :msp-mode 'weak
               :msp-weak-mode 'pos
               :crit-depth-mode t
 ))

(bye)



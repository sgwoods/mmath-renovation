(h3)
(load "Domains/hanoi3/sbmi")

(time (planner initial goal 
	       :planner-mode 'abtweak
               :msp-mode 'weak
               :msp-weak-mode 'nec
 ))

(bye)



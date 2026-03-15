(h3)
(load "Domains/hanoi3/issbmm")

(time (planner initial goal 
	       :planner-mode 'abtweak
	       :msp-mode 'weak
	       :msp-weak-mode 'pos
 ))

(bye)



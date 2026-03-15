(h3)
(load "Domains/hanoi3/issbmm")

(time (planner initial goal 
	       :planner-mode 'abtweak
	       :crit-depth-mode t
 ))

(bye)



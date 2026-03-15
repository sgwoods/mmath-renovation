(load-hanoi3)

(load "/u/sgwoods/Plan/Planner/Domains/hanoi-3/bmmiss")

(driver initial goal 
:planner-mode 'abtweak
:msp-mode 'weak
:msp-weak-mode 'pos
:output-file "/u/sgwoods/Plan/Planner/Batcher/hanoi3/bmmiss-ab-Wp.1130")

(driver initial goal 
:planner-mode 'abtweak
:msp-mode 'weak
:msp-weak-mode 'nec
:output-file "/u/sgwoods/Plan/Planner/Batcher/hanoi3/bmmiss-ab-Wn.1130")

(driver initial goal 
:planner-mode 'abtweak
:output-file "/u/sgwoods/Plan/Planner/Batcher/hanoi3/bmmiss-ab.1130")

(driver initial goal 
:planner-mode 'abtweak
:crit-depth-mode t
:output-file "/u/sgwoods/Plan/Planner/Batcher/hanoi3/bmmiss-ab-K.1130")

(bye)



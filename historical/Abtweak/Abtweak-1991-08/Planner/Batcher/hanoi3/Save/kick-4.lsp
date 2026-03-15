(load-hanoi3)
(load "/u/sgwoods/Plan/Planner/Domains/hanoi-3/smbi")

(driver initial goal 
:planner-mode 'abtweak
:msp-mode 'weak
:msp-weak-mode 'pos
:output-file "/u/sgwoods/Plan/Planner/Batcher/hanoi3/smbi-ab-Wp.1130")

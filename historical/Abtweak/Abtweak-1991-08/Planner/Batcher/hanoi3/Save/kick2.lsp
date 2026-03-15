(load-hanoi3)

(load "/u/sgwoods/Plan/Planner/Domains/hanoi-3/bmis")

(driver initial goal 
:planner-mode 'abtweak
:msp-mode 'weak
:msp-weak-mode 'pos
:output-file "/u/sgwoods/Plan/Planner/Batcher/hanoi3/bmis-ab-Wp.1130")

(load "/u/sgwoods/Plan/Planner/Domains/hanoi-3/bmsi")

(driver initial goal 
:planner-mode 'abtweak
:msp-mode 'weak
:msp-weak-mode 'pos
:output-file "/u/sgwoods/Plan/Planner/Batcher/hanoi3/bmsi-ab-Wp.1130")

(load "/u/sgwoods/Plan/Planner/Domains/hanoi-3/bsim")

(driver initial goal 
:planner-mode 'abtweak
:output-file "/u/sgwoods/Plan/Planner/Batcher/hanoi3/bsim-ab.1130")

(load "/u/sgwoods/Plan/Planner/Domains/hanoi-3/bsmi")

(driver initial goal 
:planner-mode 'abtweak
:output-file "/u/sgwoods/Plan/Planner/Batcher/hanoi3/bsmi-ab.1130")


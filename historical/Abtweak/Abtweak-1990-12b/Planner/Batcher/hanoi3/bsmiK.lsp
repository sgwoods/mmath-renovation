(load-hanoi3)

(load "/u/sgwoods/Plan/Planner/Domains/hanoi-3/bsmi")

(driver initial goal 
:planner-mode 'abtweak
:crit-depth-mode t
:output-file "/u/sgwoods/Plan/Planner/Batcher/hanoi3/bsmi-ab-K.1120")

(bye)


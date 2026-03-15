(load-hanoi3)

(load "/u/sgwoods/Plan/Planner/Domains/hanoi-3/bsim")

(driver initial goal 
:planner-mode 'abtweak
:crit-depth-mode t
:output-file "/u/sgwoods/Plan/Planner/Batcher/hanoi3/bsim-ab-K.1120")

(bye)


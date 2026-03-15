(load-hanoi3)

(load "/u/sgwoods/Plan/Planner/Domains/hanoi-3/mbis")

(princ "Klist = ") (princ *k-list*) (terpri)

(driver initial goal 
:planner-mode 'abtweak
:crit-depth-mode t
:output-file "/u/sgwoods/Plan/Planner/Batcher/hanoi3/mbisK-ab.1126")

(bye)


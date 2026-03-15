(load-hanoi3)

(load "/u/sgwoods/Plan/Planner/Domains/hanoi-3/bims")
(setq *k-list* '(1 1 3 7))
(princ "Klist = ") (princ *k-list*) (terpri)

(driver initial goal 
:planner-mode 'abtweak
:crit-depth-mode t
:output-file "/u/sgwoods/Plan/Planner/Batcher/hanoi3/bimsK-ab.1114")

(bye)


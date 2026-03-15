(load-hanoi3)

(setq *critical-loaded* 'ibmmss)
(setq *critical-list* '(
               (5 (ispeg $))
               (4 (onb $)) 
               (3 (not onm $)) 
               (2 (onm $)) 
               (1 (not ons $)) 
               (0 (ons $))
                         ))

(setq *k-list* '(0 0 0 0 0 0))

(driver initial goal 
:planner-mode 'abtweak
:msp-mode 'weak
:msp-weak-mode 'nec
:output-file "/u/sgwoods/Plan/Planner/Batcher/hanoi3/ibmmss-ab-N.1129")

(bye)



(load-hanoi3)

(setq *critical-loaded* 'bmmssi)
(setq *critical-list* '(
               (5 (onb $)) 
               (4 (not onm $)) 
               (3 (onm $)) 
               (2 (not ons $)) 
               (1 (ons $))
               (0 (ispeg $))
                         ))

(setq *k-list* '(0 0 0 0 0 0))

(driver initial goal 
:planner-mode 'abtweak
:msp-mode 'weak
:msp-weak-mode 'pos
:output-file "/u/sgwoods/Plan/Planner/Batcher/hanoi3/bmmssi-ab-Wp.1128")

(bye)



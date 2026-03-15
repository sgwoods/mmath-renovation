(load-hanoi3)

(setq *critical-loaded* 'bmmsis)
(setq *critical-list* '(
               (5 (onb $)) 
               (4 (not onm $)) 
               (3 (onm $)) 
               (2 (not ons $)) 
               (1 (ispeg $))
               (0 (ons $))
                         ))

(setq *k-list* '(0 0 0 0 0 0))

(driver initial goal 
:planner-mode 'abtweak
:msp-mode 'weak
:msp-weak-mode 'pos
:output-file "/u/sgwoods/Plan/Planner/Batcher/hanoi3/bmmsis-ab-Wp.1129")

(bye)



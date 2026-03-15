(load-hanoi2)

(setq *critical-loaded* 'biss)
(setq *critical-list* '(
               (3 (onb $)) 
               (2 (ispeg $))
               (1 (not ons $)) 
               (0 (ons $))
                         ))

(setq *k-list* '(0 0 0 0 ))

(driver initial goal 
:planner-mode 'abtweak
:msp-mode 'weak
:msp-weak-mode 'pos
:output-file "/u/sgwoods/Plan/Planner/Batcher/biss-ab-Wp.1129")

(bye)


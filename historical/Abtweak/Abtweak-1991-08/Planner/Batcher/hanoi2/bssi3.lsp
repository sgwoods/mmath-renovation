(load-hanoi2)

(setq *critical-loaded* 'bssi)
(setq *critical-list* '(
               (3 (onb $)) 
               (2 (not ons $)) 
               (1 (ons $))
               (0 (ispeg $))
                         ))

(setq *k-list* '(0 0 0 0 ))

(driver initial goal 
:planner-mode 'abtweak
:msp-mode 'weak
:msp-weak-mode 'nec
:output-file "/u/sgwoods/Plan/Planner/Batcher/bssi-ab-Wn.1129")

(bye)


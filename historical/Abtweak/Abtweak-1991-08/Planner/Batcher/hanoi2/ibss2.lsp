(load-hanoi2)

(setq *critical-loaded* 'ibss)
(setq *critical-list* '(
               (3 (ispeg $))
               (2 (onb $)) 
               (1 (not ons $)) 
               (0 (ons $))
                         ))

(setq *k-list* '(0 0 0 0 ))

(driver initial goal 
:planner-mode 'abtweak
:msp-mode 'weak
:msp-weak-mode 'nec
:output-file "/u/sgwoods/Plan/Planner/Batcher/ibss-ab-Wn.1129")

(bye)


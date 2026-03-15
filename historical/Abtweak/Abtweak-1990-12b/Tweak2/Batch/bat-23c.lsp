(load-hanoi3)                          ; Hanoi 3
(load-hanoi3-ab-crit23)                 ; test case
(if (eq *mode* 'tweak) (toggle))       ; ABTWEAK on
(if (eq *sp-property* t) (toggle-sp))  ; no spp
(setq *msp-flag* 'weak)                  ; MSP nil
(setq *prune-flag* t)                ; prune nil
(setq *top-down-flag* nil)             ; no tdp

(time (abtweak initial goal))          ; run


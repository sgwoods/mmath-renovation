(load-hanoi3)                          ; Hanoi 3
(load-hanoi3-ab-crit21)                 ; test case
(if (eq *mode* 'tweak) (toggle))       ; ABTWEAK on
(if (eq *sp-property* t) (toggle-sp))  ; no spp
(setq *msp-flag* nil)                  ; MSP nil
(setq *prune-flag* nil)                ; prune nil
(setq *top-down-flag* nil)             ; no tdp

(time (abtweak initial goal))          ; run


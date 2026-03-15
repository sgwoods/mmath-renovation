

(if (eq *mode* 'tweak) (toggle))       ; ABTWEAK on
(if (eq *sp-property* t) (toggle-sp))  ; no spp
(setq *msp-flag* 'weak)                ; MSP (WEAK)
(setq *prune-flag* t)                  ;     prune yes
(setq *top-down-flag* nil)             ; no tdp

(load "output")  ; test program
(run)




(if (eq *mode* 'tweak) (toggle))       ; ABTWEAK on
(if (eq *sp-property* t) (toggle-sp))  ; no spp
(setq *msp-flag* nil)
(setq *prune-flag* nil)
(setq *top-down-flag* nil)             ; no tdp

(load "output2")  ; test program
(run)


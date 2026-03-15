(load-hanoi3)
(if (eq *mode* 'abtweak) (toggle))  
(if (eq *sp-property* nil) (toggle-sp))
(setq *top-down-flag* t)
(toggle-tw-random)
(time (tweak initial goal))


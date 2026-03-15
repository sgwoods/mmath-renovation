; /Tweak/cond-load.lsp

; This file controls functions which load run-dependent pieces of TWEAK/ABTWEAK
; code including:

; AbTweak itself: 
;  trigger: *mode*  tweak/abtweak  indicator: *abload* t / nil  (once)
;  function: (toggle)  (mode tweak/abtweak)

; Single Producer Property
;  trigger *sp-property*   t/nil   indicator: *spload* t/nil
;  function: (toggle-sp)  (sp-mode t/nil)

; Top Down Property
;  indicator *top-down-flag* t/nil
;  functions (td-mode t/nil)

; Random U and p- selection in TWEAK
;  indicator *tw-random*  t/nil
;  function: (toggle-tw-random)   (rand-mode t/nil)
; Random U and p- selection in ABTWEAK
;  indicator *ab-random*  t/nil
;  function: (toggle-ab-random)   (rand-mode t/nil)

(defun cond-load ()
 "/Tweak/cond-load.lsp
  Load code as indicated by flags"

(mode *mode*)
(sp-mode *sp-property*)
(rand-mode t)

)

(defun debug-mode (to)
  "Tweak/cond-load
   Set debug mode t/nil"
   (setq *debug* to))

(defun ab-mode (set)
  "Tweak/cond-load
   Set tweak/abtweak mode"
   (if (eq set t)
       (mode 'abtweak)
       (mode 'tweak)))
           
(defun mode (set)
  "Tweak/cond-load
   Set tweak/abtweak mode"
   (if (eq set 'tweak)
       (progn
           (setq *mode* nil)
           (load "/u/sgwoods/Plan/Tweak2/tweak")
           (load "/u/sgwoods/Plan/Tweak2/tweak-flags")
           (setq *mode* 'tweak))
       (if (eq set 'abtweak)
           (progn 
               (setq *mode* nil)             
               (if (eq *abload* nil)   ; never loaded
                   (load "/u/sgwoods/Plan/AbTweak2/ab-init")
                   (progn                 ; abtweak loaded, just reset
                       (load "/u/sgwoods/Plan/AbTweak2/abtweak") 
                       (load "/u/sgwoods/Plan/AbTweak2/abtweak-flags")
                       (setq *mode* 'abtweak) )))
           (progn
                 (princ "MODE in error - reset to TWEAK") (terpri)
                 (setq *mode* nil)
                 (load "/u/sgwoods/Plan/Tweak2/tweak-flags")
                 (load "/u/sgwoods/Plan/Tweak2/tweak") 
                 (setq *mode* 'tweak) ))))


(defun toggle ()
  "Tweak/cond-load
   Toggle between ABTWEAK and TWEAK modes"
   (if (eq *mode* 'abtweak)
       (mode 'tweak)
       (if (eq *mode* 'tweak)   
           (mode 'abtweak)
           (mode 'tweak))))

(defun sp-mode (set)
   "Tweak/cond-load
    Set Single producter t/nil"
    (if (eq set t)
        (progn
                 (setq *SP-property* 'error)
                 (load "/u/sgwoods/Plan/Tweak2/spp-succ") 
                 (princ "Single Producer Property is ON") (terpri)
                 (setq *SP-property* t) )
        (if (eq set nil)
            (progn
                 (setq *SP-property* 'error)
                 (load "/u/sgwoods/Plan/Tweak2/successors")
                 (princ "Single Producer Property is OFF") (terpri)
                 (setq *SP-property* nil) )
            (progn 
                 (setq *SP-property* 'error)
                 (princ "SP-property flag in error - reset to nil") (terpri)
                 (load "/u/sgwoods/Plan/Tweak2/successors")
                 (princ "Single Producer Property is OFF") (terpri)
                 (setq *SP-property* nil) )
        )))


(defun toggle-SP ()
  "Tweak/cond-load
   Toggle between SUCCESSOR modes - Single Producer Property or not"
   (if (eq *SP-property* t)
       (sp-mode nil)
       (if (eq *SP-property* nil)
           (sp-mode t)
           (sp-mode nil))))


(defun rand-mode (set)
  "Tweak/cond-load"
  (if (eq *mode* 'tweak)
      (if (eq set t)
          (progn
                (setq *tw-random* 'error)
                (princ "Tweak Random determine-u-and-p is ON") (terpri)
                (load "/u/sgwoods/Plan/Tweak2/random-element") 
                (setq *tw-random* t) )
          (progn
             (setq *tw-random* 'error)
             (princ "Tweak Random det-u-and-po is OFF") (terpri)
             (load "/u/sgwoods/Plan/Tweak2/tweak") 
             (setq *tw-random* nil) ))
      (if (eq *mode* 'abtweak)
          (if (eq set nil)
              (progn
                  (setq *ab-random* 'error)
                  (princ "AbTweak Random det-u-and-po is OFF") (terpri)
                  (load "/u/sgwoods/Plan/AbTweak2/abtweak")
                  (setq *ab-random* nil) )
              (progn
                  (setq *ab-random* 'error)
                  (princ "AbTweak Random determine-u-and-p is ON") (terpri)
                  (load "/u/sgwoods/Plan/AbTweak2/random-element") 
                  (setq *ab-random* t) ))
          (progn
              (mode 'tweak)
              (rand-mode nil)))))
   
(defun toggle-tw-random ()
  "Tweak/cond-load
   Toggle between TWEAK Random determine-u-and-p functions"
   (if (eq *tw-random* t)
       (rand-mode nil)
       (if (eq *tw-random* nil)
           (rand-mode t)
           (rand-mode nil))))

(defun toggle-ab-random ()
  "Tweak/cond-load.lsp
   Toggle between ABTWEAK Random determine-u-and-p functions"
   (if (eq *ab-random* t)
       (rand-mode nil)
       (if (eq *ab-random* nil)
           (rand-mode t)
           (rand-mode nil) )))

; ABTWEAK SPECIFIC ROUTINES

(defun msp-mode (to)
  "Tweak/cond-load 
   Set MSP FLAG to weak/strong/nil"
   (setq *msp-flag* to)
   (prune-mode (if to t nil)))

(defun prune-mode (to)
  "Tweak/cond-load 
   Set PRUNE to T/NIL"
   (setq *prune-flag* to))

(defun td-mode (set)
  "Tweak/cond-load.lsp"
   (if (eq set t)
       (setq *top-down-flag* t)
       (setq *top-down-flag* nil)))

(defun k-mode (set)
  "Tweak/cond-load.lsp
   AbTweak heuristic part"
   (if (eq set t)
       (setq *k-mode* t)
       (setq *k-mode* nil))
   (if (eq *k-mode* t)
       (defun which-pri-function ()
          "/AbTweak/abtweak.lsp
           Priority calculation - heuristic (K-mode ON)"
           `(lambda (state) 
                     (- 
                        (- (num-of-ops state) (num-of-sat-goals state))
                        (nth (get_kval state) (reverse *k-list*)) )) )
       (defun which-pri-function ()
          "/AbTweak/abtweak.lsp
           Priority calculation - heuristic (K-mode OFF)"
           `(lambda (state) 
                        (- (num-of-ops state) (num-of-sat-goals state))))))


(defun abtweak (initial goal)
   "DUMMY"
   (mode 'abtweak)
   (abtweak initial goal))

(ab-mode t)
(load-nils)

(defun a (plan) (ab-successors plan))
(defun c (plan) (ab-determine-u-and-p plan))

(setq init (make-initial-plan initial goal))
(setq s1 (a init))
(setq s1-1 (car s1))
(setq s2 (a s1-1))
(setq s2-1 (car s2))
(setq s3 (a s2-1))
(setq s3-1 (car s3))
(setq s4 (a s3-1))
(setq s4-1 (first s4))
(setq s5 (a s4-1))
(setq s5-1 (first s5))
(setq s6 (a s5-1))
(setq s6-1 (car s6))
(setq s7 (a s6-1))
(setq s7-3 (third s7))
(setq s8 (a s7-3))        ; 33 successors for (op55 (clear $53)) goal

(setq u (car (c s7-3)))
(setq p (second (c s7-3)))

(defun ac (i) (create-alternative-constraints (get-inter-estid i) u p 
                (get-inter-plan i)))

;(length (find-new-ests s7-3 u p))   = 3
(setq new (find-new-ests s7-3 u p))
(setq new1 (first new))
 (setq c1 (ac new1))
 (setq n1 (declobber-all (list new1) u p))  ; 9 - 1 invalid = 8
(setq new2 (second new))
 (setq c2 (ac new2))
 (setq n2 (declobber-all (list new2) u p))  ; 9 - 1 invalid = 8
(setq new3 (third new))
 (setq c3 (ac new3))
 (setq n3 (declobber-all (list new3) u p))  ; 9 - 1 invalid = 8

;(length (find-exist-ests s7-3 u p)) = 3
(setq exist (find-exist-ests s7-3 u p))
(setq exist1 (first exist))
 (setq ce1 (ac exist1))
 (setq e1 (declobber-all (list exist1) u p)) ; 1
(setq exist2 (second exist))
 (setq ce2 (ac exist2))
 (setq e2 (declobber-all (list exist2) u p)) ; 4
(setq exist3 (third exist))
 (setq ce3 (ac exist3))
 (setq e3 (declobber-all (list exist3) u p)) ; 4   
                                                  ; (27 + 9 = 36)

(setq all (declobber-all (append new exist) u p))  ; 36 -
(length (remove-if 'invalid-p all))                ; 3 INVALID = 33 successors

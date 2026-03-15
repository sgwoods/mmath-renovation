(defun reset-flags ()
  (setq *mode*            'abtweak)
  (setq *msp-mode*        'weak)
  (setq *msp-weak-mode*   'pos)
  (setq *abs-goal*        nil)
  (setq *td-mode*         nil)
  (setq *crit-depth-mode* nil)
  (setq *random-mode*     nil)
  (setq *backwards*       nil)
  (setq *k-learn-mode*    nil)
  (setq *debug*           nil)
  (setq *search*          '4)
  (setq *heuristic*       'd)
  (setq *dfs-limit*       0)
  (setq *verbose-p*       nil)
  (setq *print-opt-p*     nil)

  (setq *numexpanded*    0) ; count of total nodes expanded
  (setq *numgenerated*   0) ; count of total nodes generated
  (setq *solution-depth* 0) ; remember search tree depth 
  (setq *count* 0)          ; remember maximum successors at any 1 node
  (setq *confl-count* 0)    ; remember maximum conflicts for any u p

(setq *ab-count*         0)
(setq *top-down-number*  0)
(setq *w-msp-pruned*     0)
(setq *s-msp-pruned*     0)

)


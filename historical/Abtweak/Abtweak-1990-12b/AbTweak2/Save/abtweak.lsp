; /AbTweak/abtweak.lsp

; Modified by Qiang Yang, Sept, 1990
;             Steve Woods, Oct, 1990

; Domain definitions for application to GRAPHSEARCH calls

(defun abtweak (initial goal)
  "/Tweak/abtweak.lsp
   calls the search function, and does a state space search.
   init---set of initial conditions.  goal---set of goal conditions"
  (declare 
        (type list initial)
        (type list goal) )

  (if (eq *mode* 'tweak) (mode 'abtweak))
  
  (setq *ab-count* 0)              ; reset counters this run
  (setq *top-down-num* 0)
  (setq *w-msp-pruned* 0)
  (setq *s-msp-pruned* 0)
  (let* (
         (initial-state (make-initial-plan initial goal)))
    (declare
         (type plan initial-state))
    (search initial-state) ))


; *** make-initial-plan

(defun make-initial-plan (initial goal)
  "/Tweak/abtweak.lsp
    returns a initial plan"
  (declare
        (type list initial)
        (type list goal) )
  (let (
        (I (create-operator-instance
              :opid 'I
              :name '(I)
              :preconditions nil
              :effects initial))
        (G (create-operator-instance
              :opid 'G
              :name '(G)
              :preconditions goal
              :effects nil))
        )
  (declare
       (type operator I)
       (type operator G) )

  (create-plan
	   'initial-plan
	   :a (list I G)
	   :b '(( I G))
           :Kval  (find-initial-k-val) 
   )))

; *** abtweak specific functions

(defun find-initial-k-val ()
  "/Tweak/abtweak.lsp
   Determine initial value of Abstraction level, Tweak => 0"
    ; Abtweak initial k is the MAXIMUM criticality value defined
       (maxint (get-k-vals *critical-list* nil) 0) )

(defun get-k-vals (c-list ints)
  "/Tweak/abtweak.lsp
   Return a list of integers, the kvals in c-list"
  (if (eq (car c-list) nil)
      ints
      (get-k-vals (cdr c-list) (cons (first (car c-list)) ints)) ))

(defun maxint (intlist prev)
  "/Tweak/abtweak.lsp
   Return the largest integer in list"
  (if (eq (car intlist) nil)
      prev
      (if (> (car intlist) prev)
          (maxint (cdr intlist) (car intlist))
          (maxint (cdr intlist) prev))) )

; *** search functions.

(defun goal-p (state)
   "AbTweak/abtweak.lsp
     Note :: A TWEAK plan is correct if prob is nil, default Kval is 0
               ABTWEAK plan is correct if prob is nil, and Kval = 0"
   (declare 
       (type plan state) )
   (and (ab-mtc state) 
        (eq (plan-kval state) 0)) )

;******  AbTweak heuristic evaluation part ********

(if (eq *k-mode* t)   ; refer to Tweak/cond-load.lsp
    (k-mode t)
    (k-mode nil) )
 
(defun num-of-ops (plan)
 "/AbTweak/abtweak.lsp
   returns the number of operators in plan"
 (declare 
      (type plan plan) )
 (length (get-opids-from-plan plan)))

(defun num-of-sat-goals (plan)
  "/Tweak/tweak.lsp
   returns the total number of satisfied goals."
  (declare 
      (type plan plan) )
  (count-if 
	    #'(lambda (ith-goal)
		      (hold-p plan 'g ith-goal))
 	        (get-preconditions-of-opid 'g plan)))
   
;(defun which-pri-function ()
;   "AbTweak/abtweak.lsp
;    Returns a priority function:  number of remaining Unsat preconditions"
;   '(lambda (state) (length (get_prob state))))

;(defun which-pri-function ()
;     '(lambda (state) (+ (length (get_prob state))
;                         (get_cost state) ) ))
                  

(defun successors&costs (plan)
  "/AbTweak/abtweak.lsp
   returns a list of successor states and costs."
  (declare
      (type plan plan) )

  (mapcar #'(lambda (state) (list state 0))
          (ab-successors plan) ))

(defun print-state (state)
  "/AbTweak/abtweak.lsp
   Print out search state"
  (declare 
      (type plan state))
  (let (
        (plan state))
    (declare
          (type plan plan))
    (showa plan)
    (showb plan)
    (shownc plan) ))


(defun print-stats ()
  "AbTweak/abtweak.lsp
   Print out RUN statistics, for use at any time"
    (if (null numexpanded)
        (setq numexpanded 0))
    (if (null numgenerated)
        (setq numgenerated 0))
    (princ "ABTWEAK PLANNER  RUN STATISTICS")  (terpri)
    (princ "Planner Mode Loaded: ")   (princ *MODE*)    (terpri)
    (princ "Domain: ") (princ *domain*) (terpri)
    (princ "AbTweak Random: ") (princ *ab-random*) (terpri)
    (princ "Critical: ") (princ *critical-loaded*) (terpri)
    (princ "Search Type: ") (princ *search*) (terpri)
    (princ "SPP property: ") (princ *SP-property*) (terpri)
    (princ "Debug  Flag:")   (princ *Debug*)    (terpri)
    (princ "A: K levels: ") (princ (find-initial-k-val)) (terpri)
    (princ "A: K setting: ") (princ *k-mode*) (terpri)
    (princ "A: Top-Down Flag: ") (princ *top-down-flag*) (terpri)
    (princ "A: Top-Down pruned: ") (princ *top-down-num*) (terpri)
    (princ "A: MSP: ") (princ *MSP-FLAG*) (terpri)
    (princ "A: Prune: ") (princ *prune-FLAG*) (terpri)
    (princ "A: W-MSP pruned :")  (princ *w-msp-pruned*) (terpri)
    (princ "A: S-MSP pruned :")  (princ *s-msp-pruned*) (terpri)
    (princ "A: Total # ABSTRACT nodes     : ")
    (princ  *ab-count*)   (terpri)
 
    (princ "Total #      nodes expanded: ")(princ numexpanded)   (terpri)
    (princ "Total #      nodes generated: ")(princ numgenerated) (terpri)
 )


(defun show-dom ()
  "AbTweak/abtweak.lsp
   Print out Domain information"
          (princ "DOMAIN DEFINITION FOR: ") (princ *domain*) (terpri) (terpri)
          (princ "Operators: ") (princ *operators*) (terpri)
          (princ "Initial State: ") (princ initial) (terpri)
          (princ "Goal State:    ") (princ goal)  (terpri)
          (princ "Criticalities: ") 
          (princ *critical-list*)  (terpri) 
          (princ "Criticality ID: ") 
          (princ *critical-loaded*)  (terpri) 
          (princ "Top-Down-Levels to eliminate: ") 
          (princ *top-down-levels*) (terpri) 
          (princ "K level List: ") (terpri)
          (princ *k-list*) (terpri)
)


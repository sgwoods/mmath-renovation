; /Tweak/tweak.lsp

; Modified by Qiang Yang, Sept, 1990
;             Steve Woods, Oct, 1990

; Domain definitions for application to GRAPHSEARCH calls

(defun tweak (initial goal)
  "/Tweak/tweak.lsp
   calls the search function, and does a state space search.
   init---set of initial conditions.  goal---set of goal conditions"
  (declare 
        (type list initial)
        (type list goal) )

  (if (eq *mode* 'abtweak) (mode 'tweak))
  
  (let* (
         (initial-state (make-initial-plan initial goal)))
    (declare
         (type plan initial-state))
    (search initial-state) ))
; *** make-initial-plan

(defun make-initial-plan (initial goal)
  "/Tweak/tweak.lsp
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
	   :b '(( I G))) ))


; *** search functions.

(defun goal-p (state)
  "/Tweak/tweak.lsp
    termination condition."
  (declare 
      (type plan state) )
  (mtc state) ))

(defun which-pri-function ()
  "/Tweak/tweak.lsp
   Priority calculation - heuristic"
 `(lambda (state)   (- (num-of-ops state)
		       (num-of-sat-goals state))) )

(defun num-of-ops (plan)
 "/Tweak/tweak.lsp
   returns the number of operators in plan"
 (declare 
      (type plan plan) )
 (length (get-opids-from-plan plan)))

(defun num-of-sat-goals (plan)
  "/Tweak/tweak.lsp B
   returns the total number of satisfied goals."
  (declare 
      (type plan plan) )
  (count-if 
	    #'(lambda (ith-goal)
		      (hold-p plan 'g ith-goal))
 	        (get-preconditions-of-opid 'g plan)))

(defun successors&costs (plan)
  "/Tweak/tweak.lsp
   returns a list of successor states and costs."
  (declare
      (type plan plan) )

     (mapcar #'(lambda (state) (list state 0))
          (successors plan)) )


(defun print-state (state)
  "/Tweak/tweak.lsp
   Print out TWEAK or ABTWEAK search state (plan)
   Note: (show plan) displays all info including ID, Cost, Kval, CR"
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
  "Tweak/tweak.lsp
   Print out RUN statistics - in TWEAK domain"
    (if (null numexpanded)
        (setq numexpanded 0))
    (if (null numgenerated)
        (setq numgenerated 0))
    (princ "TWEAK PLANNER RUN STATISTICS")  (terpri)
    (princ "Planner Mode Loaded: ")   (princ *MODE*)    (terpri)
    (princ "Domain : ") (princ *domain*) (terpri)
    (princ "Tweak Random: ") (princ *tw-random*) (terpri)
    (princ "Search Type: ") (princ *search*) (terpri)
    (princ "SPP property: ") (princ *SP-property*) (terpri)
    (princ "Debug  Flag:")   (princ *Debug*)    (terpri)
    (princ "Total #      nodes expanded: ")(princ numexpanded)   (terpri)
    (princ "Total #      nodes generated: ")(princ numgenerated) (terpri)
    (terpri) )

(defun show-dom ()
  "Tweak/tweak.lsp
   Print out Domain information"
          (princ "DOMAIN DEFINITION FOR: ") (princ *domain*) (terpri) (terpri)
          (princ "Operators: ") (princ *operators*) (terpri)
          (princ "Initial State: ") (princ initial) (terpri)
          (princ "Goal State:    ") (princ goal)  (terpri)
  )

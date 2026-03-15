; /planner/planner.lsp

; writen by   steve woods, oct, 1990
; domain definitions for application to graphsearch calls
; tweak and abtweak implemented as 1 planner

; GRAPHSEARCH RELATED FlAGS
(defvar *ck-line*  0)  ; controls output of lines indicating numexp , numgen
  (setq *ck-line*   20)  
(defvar *ck-cur*   0)  ; controls output of CUR report ongoing 
  (setq *ck-cur*   200)  

(defvar *max-exp*  0)  ; controls maximum number of expansions allowed till quit
(defvar *max-gen*  0)  ; controls maximum number of generations allowed till quit
(defvar *max-open*  0) ; controls maximum size of open list allowed till quit

; DOMAIN RELATED FLAGS
(defvar *domain*           nil  "domain name = abtweak/tweak ")
(defvar *critical-loaded*  nil  "criticality list name")
(defvar *k-list*           nil  "criticality depth list")

; PLANNER RUN COUNTERS
(defvar *numexpanded*      0    "global number of nodes expanded total")
(defvar *numgenerated*     0    "global number of nodes generated total")
(defvar *count*            0    "maximum node successors")
(defvar *confl-count*      0    "maximum u p- conflicts")
(defvar *k-branching*      nil  "record branching values in a list")
(defvar *ab-count*         0    "number abstract nodes generated")
(defvar *top-down-number*  0    "number nodes pruned via tdp")
(defvar *w-msp-pruned*     0    "number nodes pruned via w-msp")
(defvar *s-msp-pruned*     0    "number nodes pruned via s-msp")

; PLANNER SETTABLE FLAGS
(defvar *mode*             nil  "planner mode = tweak or abtweak")
(defvar *msp-mode*         nil  "mono. sol. prop. = nil/weak/strong")
(defvar *msp-weak-mode*    nil  "weak msp clobbering = nec/pos")
(defvar *abs-goal*         nil  "do not abstract goal preconditions")
(defvar *td-mode*          nil  "top down mode = t / nil")
(defvar *crit-depth-mode*  nil  "critical depth mode (use *k-list*)")
(defvar *determine-mode*   nil  "deter. u and p mode = random / tree / stack")
(defvar *backwards*        nil  "revers tweak opid select in a-list (det-u-p)")
(defvar *debug*            nil  "debug mode = t / nil")
(defvar *show-up*          nil  "show u and p selected as planning goes on")
(defvar *heuristic*        nil  "one of : d- default, nsg - no sat goals")

(defun planner (initial goal &key 
                                 (planner-mode 'tweak)
                                 (msp-mode        nil) 
                                 (msp-weak-mode  'nec)
                                 (abs-goal        nil) 
                                 (td-mode         nil)
                                 (crit-depth-mode nil)
                                 (determine-mode  'stack)
                                 (backwards-mode  nil)
                                 (debug-mode      nil)
                                 (heuristic        'd) 
                                 (expand-bound     2000)
                                 (generate-bound   5000)
                                 (open-bound       1000)
               )
  "/planner/planner.lsp
   calls the search function, and does a state space search.
   initial ---set of initial conditions  
   goal    ---set of goal conditions            "

  (declare 
        (type list initial)               
        (type list goal) 
        (type atom planner-mode)             ; tweak / abtweak
        (type atom msp-mode)                 ; weak / strong / nil
        (type atom msp-weak-mode)            ; nec / pos
        (type boolean abs-goal)              ; t / nil
        (type boolean td-mode)               ; t / nil
        (type boolean crit-depth-mode)       ; t / nil
        (type atom determine-mode)           ; random / tree / stack
        (type boolean backwards-mode)        ; t / nil
        (type boolean debug-mode)            ; t / nil
        (type atom    heuristic)             ; id code, default = d
        (type integer expand-bound)
        (type integer generate-bound)
        (type integer open-bound)
   )

  ; set control global flags (default values specified in planner function)

  (setq *mode*            planner-mode)
  (setq *msp-mode*        msp-mode)
  (setq *msp-weak-mode*   msp-weak-mode)
  (setq *abs-goal*        abs-goal)
  (setq *td-mode*         td-mode)
  (setq *crit-depth-mode* crit-depth-mode)
  (setq *determine-mode*  determine-mode)
  (setq *backwards*       backwards-mode)
  (setq *debug*           debug-mode)
  (setq *heuristic*       heuristic)
  (setq *max-exp*         expand-bound)
  (setq *max-gen*         generate-bound)
  (setq *max-open*        open-bound)

  (setq *numexpanded*    0) ; count of total nodes expanded
  (setq *numgenerated*   0) ; count of total nodes generated
  (setq *solution-depth* 0) ; remember search tree depth 
  (setq *count* 0)          ; remember maximum successors at any 1 node
  (setq *confl-count* 0)    ; remember maximum conflicts for any u p
  (setq *k-branching* (init-k-branching))

  (if (eq *mode* 'abtweak)  ; reset counters this run
      (progn
        (setq *ab-count* 0)      ; count of abtweak k level change nodes
        (setq *top-down-num* 0)  ; count top-down nodes purged from open list
        (setq *w-msp-pruned* 0)  ; count weak msp violation nodes discarded
        (setq *s-msp-pruned* 0)  ; count strong msp violation nodes discarded
      ))
  
  (let* (
         (initial-state (make-initial-plan initial goal)))
    (declare (type plan initial-state))

    (search initial-state)

    ))

; planner non specific functions

(defun make-initial-plan (initial goal)
  "/planner/planner.lsp
    returns an initial plan - based on *mode*"
  (declare
        (type list initial)
        (type list goal) )
  (if (eq *mode* 'abtweak)
      (ab-make-initial-plan initial goal)
      (tw-make-initial-plan initial goal)))

(defun goal-p (state)
  "/planner/planner.lsp
    planning termination condition."
  (declare 
      (type plan state) )
  (if (eq *mode* 'abtweak)
      (ab-goal-p state)
      (tw-goal-p state)))

(defun which-pri-function ()
  "/planner/planner.lsp
   priority calculation - heuristic"
   (if (eq *mode* 'abtweak)
       (ab-which-pri-function)
       (tw-which-pri-function) ))
      
(defun successors&costs (plan)
  "/planner/planner.lsp
    returns a list of successor states and costs."
  (declare (type plan plan) )

  (if (eq *mode* 'abtweak)
      (ab-successors&costs plan)
      (tw-successors&costs plan)))

(defun print-state (state)
  "/planner/planner.lsp
   print out tweak or abtweak search state = plan
   modified nov 5"
  (declare  (type plan state))
  (let ((plan state))
    (declare (type plan plan))
    (show plan) ))

(defun print-stats ()
  "planner/planner.lsp
   print out run statistics"
   (if (eq *mode* 'abtweak)
       (ab-print-stats)
       (tw-print-stats)))

(defun cur () 
   (print-stats))

(defun show-dom ()
  "planner/planner.lsp
   print out domain information"  
   (if (eq *mode* 'abtweak)
       (ab-show-dom)
       (tw-show-dom)))

; tweak specific functions

(defun tw-make-initial-plan (initial goal)
  "/planner/planner.lsp
    returns an initial tweak plan"
  (declare
        (type list initial)
        (type list goal) )
  (let (
        (i (create-operator-instance
              :opid 'i
              :name '(i)
              :preconditions nil
              :effects initial))
        (g (create-operator-instance
              :opid 'g
              :name '(g)
              :preconditions goal
              :effects nil))
        )
  (declare
       (type operator i)
       (type operator g) )

  (create-plan
	   'initial-plan
	   :a (list i g)
	   :b '(( i g))
           :tree (list 'g) )))

(defun tw-goal-p (state)
  "/planner/planner.lsp
    tweak termination condition."
  (declare 
      (type plan state) )
  (mtc state) )

(defun tw-which-pri-function ()
   "/planner/planner.lsp
     abtweak priority calculation - heuristic selection"
   (cond ( (eq *heuristic* 'd)   ; default
           (tw-pri-function-1))
         ( (eq *heuristic* 'nsg) ; no use of sat goals
           (tw-pri-function-2))
         ( t
           (progn
               (princ "error - heuristic flag not known")
               (break "break in which-pri-function")))))

(defun tw-pri-function-1 ()
  "/planner/planner.lsp
    (d) default heuristic (case 1) - use sat-goals
        = num-ops - num-sat-goals"
 `(lambda (state)   (- (num-of-ops state)
		       (num-of-sat-goals state))) )

(defun tw-pri-function-2 ()
  "/planner/planner.lsp
    (nsg) default heuristic (case 1) - no use of sat-goals
        = num-ops "
 `(lambda (state) (num-of-ops state) ))

(defun num-of-ops (plan)
 "/planner/planner.lsp
   tweak - returns the number of operators in plan"
 (declare 
      (type plan plan) )
 (length (get-opids-from-plan plan)))

(defun num-of-sat-goals (plan)
  "/planner/planner.lsp b
   tweak - returns the total number of satisfied goals."
  (declare 
      (type plan plan) )
  (count-if 
	    #'(lambda (ith-goal)
		      (hold-p plan 'g ith-goal))
 	        (get-preconditions-of-opid 'g plan)))

(defun tw-successors&costs (plan)
  "/planner/planner.lsp
   tweak - returns a list of successor states and costs."
  (declare (type plan plan) )
  (mapcar #'(lambda (state) (list state 0))
               (successors plan)) )

(defun tw-print-stats ()
  "planner/planner.lsp
   print out run statistics - in tweak domain"
    (princ "tweak planner run statistics")  (terpri)
    (gen-stats))

(defun gen-stats ()
    (princ "planner-mode   : ")   (princ *mode*)    (terpri)
    (princ "debug          : ")   (princ *debug*)   (terpri)
    (princ "determine via  : ")   (princ *determine-mode*)   (terpri)
    (princ "backwards-mode : ")   (princ *backwards*)     (terpri)
    (princ "heuristic      : ")   (princ *heuristic*)     (terpri)
    (princ "nodes expanded : ")   (princ *numexpanded*)    (terpri)
    (princ "nodes generated: ")   (princ *numgenerated*)   (terpri)
    (princ "solution depth : ")   (princ *solution-depth*) (terpri)
    (princ "max node succ  : ")   (princ *count*)   (terpri)
    (princ "max conflicts  : ")   (princ *confl-count*)    (terpri)
    (princ "branch factors : ")   (princ (compute-all-br)) (terpri)
    (terpri) )

(defun tw-show-dom ()
  "planner/planner.lsp
   tweak - print out domain information"
          (princ "domain definition for: ") (princ *domain*) (terpri)
          (princ "operators    : ") (terpri) (pprint *operators*) (terpri)
          (princ "initial state: ")          (pprint initial) (terpri)
          (princ "goal state   : ")          (pprint goal)  (terpri) )

; abtweak

(defun ab-make-initial-plan (initial goal)
  "/planner/planner.lsp
    abtweak - returns a initial plan"
  (declare
        (type list initial)
        (type list goal) )
  (let (
        (i (create-operator-instance
              :opid 'i
              :name '(i)
              :preconditions nil
              :effects initial))
        (g (create-operator-instance
              :opid 'g
              :name '(g)
              :preconditions goal
              :effects nil))
        )
  (declare
       (type operator i)
       (type operator g) )

  (create-plan
	   'initial-plan
	   :a (list i g)
	   :b '(( i g))
           :tree (list 'g)
           :kval  (find-initial-k-val) 
   )))

(defun ab-goal-p (state)
   "planner/planner.lsp
     note :: a tweak plan is correct if prob is nil, default kval is 0
               abtweak plan is correct if prob is nil, and kval = 0"
   (declare 
       (type plan state) )
   (and (ab-mtc state) 
        (eq (plan-kval state) 0)) )

(defun ab-which-pri-function ()
   "/planner/planner.lsp
     abtweak priority calculation - heuristic selection"
   (cond ( (eq *heuristic* 'd)   ; default
           (if *crit-depth-mode* 
               (ab-pri-function-1)
               (ab-pri-function-2)))
         ( (eq *heuristic* 'nsg) ; no use of sat goals
           (if *crit-depth-mode* 
               (ab-pri-function-1a)
               (ab-pri-function-2a)))
         ( t
           (progn
               (princ "error - heuristic flag not known")
               (break "break in ab-which-pri-function")))))

(defun ab-pri-function-1 ()
   "/planner/planner.lsp
    (d) default heuristic (case 1) - use *k-list*, use sat-goals
        = ops - num-sat-goals - *k-list* value "
   `(lambda (state) 
                     (- 
                        (- (num-of-ops state) (num-of-sat-goals state))
                        (nth (get_kval state) (reverse *k-list*)) )) )

(defun ab-pri-function-1a ()
   "/planner/planner.lsp
    (nsg) heuristic (case 1) - use *k-list*, no sat-goals
        = ops - *k-list* value "
   `(lambda (state) 
                     (- 
                        (num-of-ops state)
                        (nth (get_kval state) (reverse *k-list*)) )) )

(defun ab-pri-function-2 ()
   "/planner/planner.lsp
    (d) default heuristic (case 2) f- no *k-list* use sat-goals
        = ops - num-sat-goals "
    `(lambda (state) 
                        (- (num-of-ops state) (num-of-sat-goals state))))

(defun ab-pri-function-2a ()
   "/planner/planner.lsp
    (nsg) default heuristic (case 2) f- no *k-list* no sat-goals
        = ops "
    `(lambda (state) 
                     (num-of-ops state) ))

(defun ab-successors&costs (plan)
  "/planner/planner.lsp
   abtweak - returns a list of successor states and costs."
  (declare (type plan plan) )
  (mapcar #'(lambda (state) (list state 0))
          (ab-successors plan) ))

(defun ab-print-stats ()
  "planner/planner.lsp
   print out run statistics, in abtweak domain"
    (princ "abtweak planner  run statistics")    (terpri)
    (gen-stats)
    (princ "a: criticality levels    : ") (princ (find-initial-k-val)) (terpri)
    (princ "a: criticality depth mode: ") (princ *crit-depth-mode*)    (terpri)
    (princ "a: top-down flag         : ") (princ *td-mode*)            (terpri)
    (princ "a: top-down pruned       : ") (princ *top-down-num*)       (terpri)
    (princ "a: abs goal mode         : ") (princ *abs-goal*)           (terpri)
    (princ "a: monotonic sol property: ") (princ *msp-mode*)           (terpri)
    (princ "a: msp weak mode         : ") (princ *msp-weak-mode*)      (terpri)
    (princ "a: weak msp   pruned     : ") (princ *w-msp-pruned*)       (terpri)
    (princ "a: strong msp pruned     : ") (princ *s-msp-pruned*)       (terpri)
    (princ "a: abstract nodes gen    : ") (princ  *ab-count*)          (terpri)
 )

(defun ab-show-dom ()
  "planner/planner.lsp
   print out domain information"
     (tw-show-dom)
     (princ "a: criticalities      : ") (pprint *critical-list*)   (terpri) 
     (princ "a: criticality id     : ") (pprint *critical-loaded*) (terpri) 
     (princ "a: eliminate td levels: ") (pprint *top-down-levels*) (terpri) 
     (princ "a: critcal depth modes: ") (pprint *k-list*)          (terpri)
     (terpri) )

; *** abtweak specific functions

(defun find-initial-k-val ()
  "/planner/planner.lsp
   determine initial value of abstraction level, tweak => 0"
    ; abtweak initial k is the maximum criticality value defined
       (maxint (get-k-vals *critical-list* nil) 0) )

(defun get-k-vals (c-list ints)
  "/planner/planner.lsp
   return a list of integers, the kvals in c-list"
  (if (eq (car c-list) nil)
      ints
      (get-k-vals (cdr c-list) (cons (first (car c-list)) ints)) ))

(defun maxint (intlist prev)
  "/planner/planner.lsp
   return the largest integer in list"
  (if (eq (car intlist) nil)
      prev
      (if (> (car intlist) prev)
          (maxint (cdr intlist) (car intlist))
          (maxint (cdr intlist) prev))) )

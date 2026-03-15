; this file contains initialization of global variables.

; Search Related Variables

(defvar *expand-bound*  0)  ; controls maximum number of expansions allowed till quit
(defvar *generate-bound*  0)  ; controls maximum number of generations allowed till quit
(defvar *open-bound*  0) ; controls maximum size of open list allowed till quit

; DOMAIN RELATED Variables
(defvar *domain*           nil  "domain name = abtweak/tweak ")
(defvar *left-wedge-list*  nil  "left wedge list")
(defvar *tc-mode*         nil  "temporal coherence = t/nil")

; Planner Counter Variables

(defvar *num-expanded*      0    "global number of nodes expanded total")
(defvar *num-generated*     0    "global number of nodes generated total")
(defvar *max-succ-count*            0    "maximum node successors")
(defvar *max-confl-count*      0    "maximum u p conflicts")
(defvar *abs-node-count*         0    "number abstract nodes generated")
(defvar *mp-pruned*     0    "number nodes pruned via monotonic property.")

; Planner Choice Variables.

(defvar *planner-mode*             nil  "planner mode = tweak or abtweak")
(defvar *mp-mode*         nil  "mono. prop. = t/nil")
(defvar *abstract-goal-p*  nil  "nil if do not abstract goal conditions")
(defvar *drp-mode*          nil  "downward refinement mode = t / nil")
(defvar *left-wedge-mode*  nil  "left-wedge mode (use *lw-list*)")
(defvar *subgoal-determine-mode*   
  nil  "determine user and precond in which way,  random / tree / stack/ highest")
(defvar *debug-mode*         nil  "debug mode = t / nil")
(defvar *heuristic*        nil  "nil if no heuristic used.")
(defvar *use-primary-effect-p*   nil  "t if use primary effect of operators")
(defvar *abs-branching-limit* 0 "the maximum number of refinements each
abstract plan can have.")

(defun initialize-global-variables (

   planner-mode continue-p mp-mode abstract-goal-mode
   drp-mode left-wedge-mode subgoal-determine-mode debug-mode
   heuristic-mode use-primary-effect-p expand-bound
   generate-bound open-bound output-file cpu-sec-limit drp-debug-mode
   control-strategy existing-only abs-branching-limit
   tc-mode)

  "initialize global variables."
  
  (setq *control-strategy* control-strategy)
  (setq *planner-mode*      planner-mode)
  (setq *mp-mode*        mp-mode)
  (setq *abstract-goal-mode*        abstract-goal-mode)
  (setq *drp-mode*         drp-mode)
  (setq *left-wedge-mode* left-wedge-mode)
  (setq *subgoal-determine-mode*  subgoal-determine-mode)
  (setq *debug-mode*           debug-mode)
  (setq *heuristic-mode*       heuristic-mode)
  (setq *use-primary-effect-p* use-primary-effect-p)
  (setq *drp-stack* nil)

  (setq *continue-p* continue-p)

  (setq *expand-bound*         expand-bound)
  (setq *generate-bound*         generate-bound)
  (setq *open-bound*        open-bound)

  (setq *max-succ-count* 0)          ; remember maximum successors at any 1 node
  (setq *confl-count* 0)    ; remember maximum conflicts for any u p
  (setq *abs-node-count* 0)      ; count of abtweak k level change nodes
  (setq *mp-pruned* 0)  ; count weak msp violation nodes discarded
  (setq *existing-only* existing-only)
  (setq *output-stream* 
	(cond ((or (eq output-file t) (null output-file)) 
	       *standard-output*)
	      ((eq output-file 'no-output) nil)
	      (t 
	       (open output-file 
		     :direction :output :if-exists 
		     :append :if-does-not-exist :create))))
  (setq *cpu-sec-limit* cpu-sec-limit)
  (setq *drp-debug-mode* drp-debug-mode)
  (setq *tc-mode*        tc-mode)
  (initialize-abs-branching-counts)
  (initialize-success-ref-counts)
  (initialize-abs-ref-counts )
  (if (or (equal *planner-mode* 'abtweak)
	  (equal *planner-mode* 'mr-crit))
      (setq *curr-level* (length *critical-list*)))
  (setq *abs-branching-limit* abs-branching-limit)
  (setq *abs-backtracking-flag* nil)

)

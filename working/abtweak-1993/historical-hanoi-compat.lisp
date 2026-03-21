; Historical Hanoi compatibility helpers for the SBCL working port.
;
; These helpers do not try to recreate the full 1991 planner. They provide a
; small compatibility surface for the published/archived Hanoi experiments on
; top of the preserved 1993 baseline.

(defun historical-hanoi2-hierarchy-symbol (hierarchy)
  (case hierarchy
    ((ibs) '*ibs*)
    ((sib) '*sib*)
    ((bsi) '*bsi*)
    ((bis) '*bis*)
    ((sbi) '*sbi*)
    ((isb) '*isb*)
    (t
     (error "Unknown hanoi-2 hierarchy ~S" hierarchy))))

(defun historical-hanoi2-left-wedge-list (hierarchy)
  (case hierarchy
    ((ibs) *ibs-k-list*)
    ((sib) *sib-k-list*)
    ((bsi) *bsi-k-list*)
    ((bis) *bis-k-list*)
    ((sbi) *sbi-k-list*)
    ((isb) *isb-k-list*)
    (t
     (error "Unknown hanoi-2 hierarchy ~S" hierarchy))))

(defun configure-historical-hanoi2 (hierarchy)
  "Select the requested historical hanoi-2 hierarchy and its k-list analogue."
  (let ((hierarchy-symbol (historical-hanoi2-hierarchy-symbol hierarchy)))
    (setq *critical-list* (symbol-value hierarchy-symbol))
    (setq *critical-loaded* hierarchy)
    (setq *left-wedge-list* (historical-hanoi2-left-wedge-list hierarchy))
    hierarchy-symbol))

(defun historical-msp->mp-mode (msp-mode)
  "Map the older 1991 MSP selector onto the 1993 boolean MP flag."
  (cond ((null msp-mode) nil)
	((eq msp-mode 'weak) t)
	((eq msp-mode 'strong) 'strong)
	(t
	 (error "Unknown historical MSP mode ~S" msp-mode))))

(defun historical-hanoi2-plan
    (initial goal &key
		   (hierarchy 'ibs)
		   (planner-mode 'abtweak)
		   (msp-mode nil)
		   (msp-weak-mode 'nec)
		   (crit-depth-mode nil)
		   (determine-mode 'stack)
		   (left-wedge-mode nil)
		   (output-file 'no-output)
		   (expand-bound 2000)
		   (generate-bound 8000)
		   (open-bound 8000)
		   (cpu-sec-limit 15))
  "Run a hanoi-2 plan using the archived 1990 experiment-style controls."
  (configure-historical-hanoi2 hierarchy)
  (plan initial goal
	:planner-mode planner-mode
	:mp-mode (historical-msp->mp-mode msp-mode)
	:mp-weak-mode msp-weak-mode
	:subgoal-determine-mode determine-mode
	:left-wedge-mode (or left-wedge-mode crit-depth-mode)
	:output-file output-file
	:expand-bound expand-bound
	:generate-bound generate-bound
	:open-bound open-bound
	:cpu-sec-limit cpu-sec-limit))

(defun historical-hanoi3-hierarchy-symbol (hierarchy)
  (case hierarchy
    ((critical-list-1) '*critical-list-1*)
    ((critical-list-2) '*critical-list-2*)
    ((ismb) '*ismb*)
    ((imbs) '*imbs*)
    ((imsb) '*imsb*)
    ((ibsm) '*ibsm*)
    ((isbm) '*isbm*)
    ((sbim) '*sbim*)
    ((sbmi) '*sbmi*)
    ((simb) '*simb*)
    ((sibm) '*sibm*)
    ((smib) '*smib*)
    ((smbi) '*smbi*)
    ((misb) '*misb*)
    ((msbi) '*msbi*)
    ((msib) '*msib*)
    (t
     (error "Unknown hanoi-3 hierarchy ~S" hierarchy))))

(defun historical-hanoi3-left-wedge-list (hierarchy)
  (case hierarchy
    ((critical-list-2) *k-list-2*)
    ((sbim) *sbim-k-list*)
    ((sbmi) *sbmi-k-list*)
    ((simb) *simb-k-list*)
    ((sibm) *sibm-k-list*)
    ((smib) *smib-k-list*)
    ((smbi) *smbi-k-list*)
    ((misb) *misb-k-list*)
    ((msbi) *msbi-k-list*)
    ((msib) *msib-k-list*)
    (t *k-list-1*)))

(defun configure-historical-hanoi3 (hierarchy)
  "Select the requested historical hanoi-3 hierarchy and its k-list analogue."
  (let ((hierarchy-symbol (historical-hanoi3-hierarchy-symbol hierarchy)))
    (setq *critical-list* (symbol-value hierarchy-symbol))
    (setq *critical-loaded* hierarchy)
    (setq *left-wedge-list* (historical-hanoi3-left-wedge-list hierarchy))
    hierarchy-symbol))

(defun historical-hanoi3-plan
    (initial goal &key
		   (hierarchy 'critical-list-1)
		   (planner-mode 'abtweak)
		   (msp-mode nil)
		   (msp-weak-mode 'nec)
		   (crit-depth-mode nil)
		   (determine-mode 'stack)
		   (left-wedge-mode nil)
		   (output-file 'no-output)
		   (expand-bound 20000)
		   (generate-bound 80000)
		   (open-bound 80000)
		   (cpu-sec-limit 30))
  "Run a hanoi-3 plan using the older 1991 experiment-style control names."
  (configure-historical-hanoi3 hierarchy)
  (plan initial goal
	:planner-mode planner-mode
	:mp-mode (historical-msp->mp-mode msp-mode)
	:mp-weak-mode msp-weak-mode
	:subgoal-determine-mode determine-mode
	:left-wedge-mode (or left-wedge-mode crit-depth-mode)
	:output-file output-file
	:expand-bound expand-bound
	:generate-bound generate-bound
	:open-bound open-bound
	:cpu-sec-limit cpu-sec-limit))

(defun historical-hanoi4-hierarchy-symbol (hierarchy)
  (case hierarchy
    ((legacy-1991-default) '*legacy-1991-default*)
    ((critical-list-1) '*critical-list-1*)
    ((critical-list-2) '*critical-list-2*)
    ((ismb) '*ismb*)
    ((imbs) '*imbs*)
    ((imbs-h1) '*imbs-h1*)
    ((imbs-hb) '*imbs-hb*)
    ((ibsm) '*ibsm*)
    ((isbm) '*isbm*)
    ((isbm-h1) '*isbm-h1*)
    ((isbm-hb) '*isbm-hb*)
    (t
     (error "Unknown hanoi-4 hierarchy ~S" hierarchy))))

(defun historical-hanoi4-left-wedge-list (hierarchy)
  (case hierarchy
    ((legacy-1991-default) *legacy-1991-k-list*)
    ((critical-list-2) *k-list-2*)
    (t *k-list-1*)))

(defun configure-historical-hanoi4 (hierarchy)
  "Select the requested historical hanoi-4 hierarchy and its k-list analogue."
  (let ((hierarchy-symbol (historical-hanoi4-hierarchy-symbol hierarchy)))
    (setq *critical-list* (symbol-value hierarchy-symbol))
    (setq *critical-loaded* hierarchy)
    (setq *left-wedge-list* (historical-hanoi4-left-wedge-list hierarchy))
    hierarchy-symbol))

(defun historical-hanoi4-plan
    (initial goal &key
		   (hierarchy 'legacy-1991-default)
		   (planner-mode 'abtweak)
		   (msp-mode nil)
		   (msp-weak-mode 'nec)
		   (crit-depth-mode nil)
		   (determine-mode 'stack)
		   (left-wedge-mode nil)
		   (output-file 'no-output)
		   (expand-bound 20000)
		   (generate-bound 80000)
		   (open-bound 80000)
		   (cpu-sec-limit 30))
  "Run a hanoi-4 plan using the older experiment-style control names."
  (configure-historical-hanoi4 hierarchy)
  (plan initial goal
	:planner-mode planner-mode
	:mp-mode (historical-msp->mp-mode msp-mode)
	:mp-weak-mode msp-weak-mode
	:subgoal-determine-mode determine-mode
	:left-wedge-mode (or left-wedge-mode crit-depth-mode)
	:output-file output-file
	:expand-bound expand-bound
	:generate-bound generate-bound
	:open-bound open-bound
	:cpu-sec-limit cpu-sec-limit))

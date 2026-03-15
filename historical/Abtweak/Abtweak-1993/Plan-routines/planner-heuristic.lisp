(defun which-heuristic-function ()
  "/planner/planner.lsp
   priority calculation - heuristic"
   (if (or (equal *planner-mode* 'abtweak)
	   (equal *planner-mode* 'mr-crit))
       (ab-which-heuristic-function)
       (tw-which-heuristic-function) ))




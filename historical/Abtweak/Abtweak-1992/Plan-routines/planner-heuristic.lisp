(defun which-heuristic-function ()
  "/planner/planner.lsp
   priority calculation - heuristic"
   (if (equal *planner-mode* 'abtweak)
       (ab-which-heuristic-function)
       (tw-which-heuristic-function) ))




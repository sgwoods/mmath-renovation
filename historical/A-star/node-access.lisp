; node access routines
; a node is implemented as a list (priority state cost parent-node).
          
;****************************************************************************
;* GET PRIORITY value from the node structure
;****************************************************************************
(defun get-priority (node)
    (car node))

;****************************************************************************
;* GET STATE value from the node structure
;****************************************************************************
(defun get-state (node)
    (cadr node))

;****************************************************************************
;* GET COST value from the node structure
;****************************************************************************
(defun get-cost (node)
    (car (cddr node)))

;****************************************************************************
;* MAKE NODE structure from the basic elements of a node
;****************************************************************************
(defun make-node (priority state cost parent-node)
"makes a node as a list of (priority state cost parent-node)"
     (list priority state cost parent-node))


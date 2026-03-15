; /planner/search/node-access.lsp
;
; node access routines
; a node is implemented as a list (priority state cost parent-node).
;
          
;****************************************************************************
;* get priority value from the node structure
;****************************************************************************
(defun get-priority (node)
   "planner/search/node-access"
    (declare 
        (type list node))
    (car node))

;****************************************************************************
;* get state value from the node structure
;****************************************************************************
(defun get-state (node)
   "planner/search/node-access"
    (declare 
        (type list node))
    (cadr node))

;****************************************************************************
;* get cost value from the node structure
;****************************************************************************
(defun get-cost (node)
   "planner/search/node-access"
    (declare 
        (type list node))
    (car (cddr node)))

;****************************************************************************
;* get solution depth value from the node structure
;  (ie depth from root in successor generation)
;****************************************************************************

(defun get-solution-depth (node)
  "planner/search/node-access"
   (declare 
       (type list node))
   (if (null node)  ; initial/root - no parent exists
       0
       (fourth node)) )

(defun make-node (priority state cost parent-node)
"planner/search/node-access
 makes a node as a list of (priority state cost solution-depth)"
    (declare 
        (type integer priority)
        (type plan state)
        (type integer cost)
        (type list parent-node))
    (list priority state cost (1+ (get-solution-depth parent-node))) )




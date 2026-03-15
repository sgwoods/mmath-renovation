; /planner/search/node-access.lsp
;
; node access routines
; a node is implemented as a list (priority state cost parent-node).
;
; note this version of gs has been modified via declarations to be 
; planning structure specific, and references are made to 
; state as an instance of type plan
; in order to speed up the compiled version of this code
;   sgw oct 2, 1990

; written by steve woods, april 1990
; modified by steve woods oct  1990

          
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

;****************************************************************************
;* make node structure from the basic elements of a node
;
; modified sept 22/90 to include present solution depth instead
;  of parent-node within each node ...
;  ie utilizing parent node information, extract parent node
;     solution depth and increment it by 1
;
;****************************************************************************
(defun make-node (priority state cost parent-node)
"planner/search/node-access
 makes a node as a list of (priority state cost solution-depth)"
    (declare 
        (type integer priority)
        (type plan state)
        (type integer cost)
        (type list parent-node))
    (list priority state cost (1+ (get-solution-depth parent-node))) )




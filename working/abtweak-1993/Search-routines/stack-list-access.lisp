; /Tw-routines/search/stack-list-access.lsp

; open and closed list rountines
; both open and closed are implemented as stacks.
;
; an open list is a list of sorted sublists.  each sublist is
; of the form: (priority (node1 node2 ...)).

(defun stack-initialize-open (node)
   "Tw-routines/search/stack-list-access."
   (declare
       (type list node))
   (setq *open* 
	 (list node)))
	  

(defun stack-get-next-open-node ()
   "tweak/search/list-access
    returns the node on open with the least cost"
   (car *open*))

(defun stack-remove-first-node (list)
   "tweak/search/list-access"
   (declare
       (type list list) )
   (setq list (rest list)))

(defun stack-insert-node (node open-list)
   "tweak/search/list-access
    inserts node into list-of-nodes either by 
       bfs - least   cost first only. "
   (declare
       (type list node)
       (type (list list) list-of-nodes) )
   (setq open-list (cons node open-list)))


;******************* peek open functions.

(defun stack-length-of-open ()
   "tweak/search/list-access"
   (length *open*))




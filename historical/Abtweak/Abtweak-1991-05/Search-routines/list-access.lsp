; /tweak/search/list-access.lsp

; open and closed list rountines
; both open and closed are implemented using priority lists
;
; an open list is a list of sorted sublists.  each sublist is
; of the form: (priority (node1 node2 ...)).

(defun initialize-open (node)
   "tweak/search/list-access"
   (declare
       (type list node))
   (setq *open* (list 
		 (list (get-priority node)
		      (list node)))))

(defun initialize-closed ()
   "tweak/search/list-access"
   (setq *closed* nil))

(defun list-empty-p (list)
   "tweak/search/list-access"
   (declare 
       (type list list))
   (null list))

(defun get-next-open-node ()
   "tweak/search/list-access
    returns the node on open with the least cost"
   (car (second (car *open*))))

(defun remove-first-node (list)
   "tweak/search/list-access"
   (declare
       (type list list) )
   (let* ((first-sub-list (car *open*))
	  (sub-list-of-nodes 
	   (cdr (second first-sub-list))))
     (if (null sub-list-of-nodes)
	 (cdr *open*)
       (cons (list (first first-sub-list)
		   sub-list-of-nodes)
	     (cdr *open*)))))

(defun insert-node (node open-list)
   "tweak/search/list-access
    inserts node into list-of-nodes either by 
       bfs - least   cost first only. "
   (declare
       (type list node)
       (type (list list) list-of-nodes) )
   (let ((first-sub-list
	  (car open-list)))

   (cond ((null open-list)
	  (list (list
		 (get-priority node)
		      (list node))))

	 ((= (car first-sub-list)
	     (get-priority node))
	  (cons (list (car first-sub-list)
		      (cons node (second first-sub-list)))
		(cdr open-list)))

	 ((> (car first-sub-list)
	     (get-priority node)) 
	  (cons (list (get-priority node)
		      (list node))
		open-list))

	 (t (cons
	     first-sub-list
	     (insert-node  node (cdr open-list)))))) )

(defun get-node-from-list (state list-of-nodes)
   "tweak/search/list-access
    get node with state from list"
   nil)

(defun state-isin-p (state list-of-nodes)
  "tweak/search/list-access 
   true if state is in list-of-nodes"
  nil)

(defun remove-state (state list-of-nodes)
   "tweak/search/list-access
    removes state from list-of-nodes"
   list-of-nodes)

;******************* peek open functions.

(defun length-of-open ()
   "tweak/search/list-access"
  (apply '+ 
	 (mapcar 'length 
		 (mapcar 'second *open*))))

(defun first-of-open ()
   "tweak/search/list-access"
  (first (second (first *open*))))

(defun last-of-open ()
   "tweak/search/list-access"
 (first (second (car (last *open*)))))



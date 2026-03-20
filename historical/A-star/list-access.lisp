; OPEN and CLOSED list rountines
; both OPEN and CLOSED are implemented using priority lists

(defun initialize-open (node)
   (setq *open* (list node)))

(defun initialize-closed ()
   (setq *closed* nil))

(defun list-empty-p (list)
   (null list))

(defun get-next-open-node ()
   "returns the node on open with the least cost"
   (car *open*))

(defun remove-first-node (list)
   (setq list (cdr list)))

(defun get-node-from-list (state list-of-nodes)
   "get node with state from list"
   (car (member state list-of-nodes :test 
      #'(lambda (state node) (equal state (get-state node))))))

(defun state-isin-p (state list-of-nodes)
  "true if state is in list-of-nodes"
  (member state list-of-nodes :test #'(lambda (state node) 
        (equal state (get-state node)))))

(defun remove-state (state list-of-nodes)
   "removes state from list-of-nodes"
  (set-difference list-of-nodes (list state) 
     :test #'(lambda(node state) (equal (get-state node) state))))
         
(defun insert-node (node list-of-nodes)
   "inserts node into list-of-nodes after all nodes having
  priority less than or equal to node's priority."
   (do ((remaining-nodes list-of-nodes (cdr remaining-nodes))
         (result nil (append result (list (car remaining-nodes)) )))
      ((or (null remaining-nodes) 
           (> (get-priority (car remaining-nodes)) (get-priority node)))
        (append result (list node) remaining-nodes))))
                
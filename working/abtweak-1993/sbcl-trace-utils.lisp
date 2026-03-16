;;; Helpers for writing post-run search traces under SBCL.

(defun trace-control-strategy ()
  *control-strategy*)

(defun flatten-open-nodes ()
  "Return the current OPEN frontier as a plain node list."
  (cond
   ((null *open*) nil)
   ((equal (trace-control-strategy) 'bfs)
    (apply #'append
           (mapcar #'second *open*)))
   (t
    *open*)))

(defun open-priority-buckets ()
  "Return ((priority count) ...) for the current OPEN list."
  (cond
   ((null *open*) nil)
   ((equal (trace-control-strategy) 'bfs)
    (mapcar #'(lambda (bucket)
                (list (first bucket)
                      (length (second bucket))))
            *open*))
   (t
    (list (list 'stack (length *open*))))))

(defun node-state-summary (node)
  (let* ((plan (get-state node))
         (up (ignore-errors
               (when (and (typep plan 'plan)
                          (not (goal-p plan)))
                 (if (eq *planner-mode* 'abtweak)
                     (ab-determine-u-and-p plan)
                   nil)))))
    (list
     :priority (get-priority node)
     :search-cost (get-cost node)
     :solution-depth (get-solution-depth node)
     :plan-id (when (typep plan 'plan) (plan-id plan))
     :plan-cost (when (typep plan 'plan) (plan-cost plan))
     :plan-kval (when (typep plan 'plan) (plan-kval plan))
     :plan-length (when (typep plan 'plan) (length (plan-a plan)))
     :num-orders (when (typep plan 'plan) (length (plan-b plan)))
     :num-causal-relations (when (typep plan 'plan) (length (plan-cr plan)))
     :num-conflicts (when (typep plan 'plan) (length (plan-conflicts plan)))
     :invalid (when (typep plan 'plan) (plan-invalid plan))
     :next-user-precond up)))

(defun plan-unsat-user-precond-pairs (plan)
  "Return all currently unsatisfied user/precondition pairs for PLAN."
  (cond
   ((not (typep plan 'plan)) nil)
   ((eq *planner-mode* 'abtweak)
    (ignore-errors (ab-unsat-up-pairs plan)))
   (t
    (ignore-errors (unsat-user-precond-pairs plan)))))

(defun frontier-node-quality-summary (node)
  (let* ((plan (get-state node))
         (unsat-pairs (plan-unsat-user-precond-pairs plan)))
    (list
     :priority (get-priority node)
     :search-cost (get-cost node)
     :heuristic-component (- (get-priority node) (get-cost node))
     :solution-depth (get-solution-depth node)
     :plan-id (when (typep plan 'plan) (plan-id plan))
     :plan-cost (when (typep plan 'plan) (plan-cost plan))
     :plan-kval (when (typep plan 'plan) (plan-kval plan))
     :plan-length (when (typep plan 'plan) (length (plan-a plan)))
     :unsat-count (if unsat-pairs (length unsat-pairs) 0)
     :first-unsat (first unsat-pairs)
     :next-user-precond (ignore-errors
                          (when (and (typep plan 'plan)
                                     (not (goal-p plan))
                                     (eq *planner-mode* 'abtweak))
                            (ab-determine-u-and-p plan))))))

(defun frontier-best-unsat-count (nodes)
  (let ((counts
         (remove nil
                 (mapcar #'(lambda (node)
                             (let ((plan (get-state node)))
                               (when (typep plan 'plan)
                                 (length (plan-unsat-user-precond-pairs plan)))))
                         nodes))))
    (when counts
      (apply #'min counts))))

(defun frontier-sort-by-priority (nodes)
  (sort (copy-list nodes) #'< :key #'get-priority))

(defun frontier-sort-by-unsat-count (nodes)
  (sort (copy-list nodes)
        #'(lambda (node1 node2)
            (let* ((summary1 (frontier-node-quality-summary node1))
                   (summary2 (frontier-node-quality-summary node2))
                   (unsat1 (getf summary1 :unsat-count))
                   (unsat2 (getf summary2 :unsat-count))
                   (priority1 (getf summary1 :priority))
	                   (priority2 (getf summary2 :priority)))
	              (if (= unsat1 unsat2)
	                  (< priority1 priority2)
	                (< unsat1 unsat2))))))

(defun write-frontier-quality-snapshot (pathname &key (limit 50))
  (with-open-file (stream pathname
                          :direction :output
                          :if-exists :supersede
                          :if-does-not-exist :create)
    (let* ((nodes (flatten-open-nodes))
           (priority-sorted (frontier-sort-by-priority nodes))
           (unsat-sorted (frontier-sort-by-unsat-count nodes))
           (best-unsat (frontier-best-unsat-count nodes)))
      (format stream "Open node count: ~S~%" (length nodes))
      (format stream "Best unsatisfied-pair count in OPEN: ~S~%~%" best-unsat)

      (format stream "Top nodes by priority:~%")
      (loop for node in priority-sorted
            for rank from 1
            while (<= rank limit) do
              (format stream "~&===== PRIORITY RANK ~D =====~%" rank)
              (format stream "~S~%~%" (frontier-node-quality-summary node)))

      (format stream "~%Top nodes by unsatisfied-pair count:~%")
      (loop for node in unsat-sorted
            for rank from 1
            while (<= rank limit) do
              (format stream "~&===== UNSAT RANK ~D =====~%" rank)
              (format stream "~S~%~%" (frontier-node-quality-summary node))))))

(defun write-plan-snapshot (plan stream)
  (format stream "Plan id: ~S~%" (plan-id plan))
  (format stream "Plan cost: ~S~%" (plan-cost plan))
  (format stream "Plan kval: ~S~%" (plan-kval plan))
  (format stream "Plan length: ~S~%" (length (plan-a plan)))
  (format stream "Order count: ~S~%" (length (plan-b plan)))
  (format stream "CR count: ~S~%" (length (plan-cr plan)))
  (format stream "Conflict count: ~S~%" (length (plan-conflicts plan)))
  (format stream "Invalid: ~S~%" (plan-invalid plan))
  (format stream "~%Orders:~%")
  (dolist (order (sort-orders '(i) (plan-b plan)))
    (let ((op1-id (first order))
          (op2-id (second order)))
      (format stream "  ~S~%"
              (list (replace-by-op-name op1-id (plan-a plan))
                    (replace-by-op-name op2-id (plan-a plan))))))
  (format stream "~%Causal relations:~%")
  (dolist (cr (plan-cr plan))
    (let ((producer-list (get-producer-list-in-cr cr))
          (condition (get-condition-in-cr cr))
          (user (get-user-in-cr cr)))
      (format stream "  ~S~%"
              (list user condition producer-list))))
  (format stream "~%Operators:~%")
  (dolist (op (plan-a plan))
    (format stream "  ~S~%" (operator-name op)))
  (format stream "~%Non-codesignations: ~S~%" (plan-nc plan)))

(defun write-trace-summary (stream)
  (format stream "Planner mode: ~S~%" *planner-mode*)
  (format stream "Control strategy: ~S~%" *control-strategy*)
  (format stream "Solution value: ~S~%" *solution*)
  (format stream "Solution type: ~S~%" (type-of *solution*))
  (format stream "Expanded: ~S~%" *num-expanded*)
  (format stream "Generated: ~S~%" *num-generated*)
  (format stream "MP pruned: ~S~%" *mp-pruned*)
  (format stream "Open length: ~S~%" (if (equal *control-strategy* 'bfs)
                                         (length-of-open)
                                       (stack-length-of-open)))
  (format stream "Closed length: ~S~%" (length *closed*))
  (format stream "Abs node count: ~S~%" *abs-node-count*)
  (format stream "DRP stack depth: ~S~%" (length *drp-stack*))
  (format stream "Current level: ~S~%" *curr-level*)
  (format stream "Abs branching counts: ~S~%" *abs-branching-counts*)
  (format stream "Open priority buckets:~%")
  (dolist (bucket (open-priority-buckets))
    (format stream "  ~S~%" bucket)))

(defun write-open-frontier-snapshot (pathname &key (limit 200))
  (with-open-file (stream pathname
                          :direction :output
                          :if-exists :supersede
                          :if-does-not-exist :create)
    (let ((nodes (flatten-open-nodes))
          (count 0))
      (dolist (node nodes)
        (when (>= count limit)
          (return))
        (incf count)
        (format stream "~&===== OPEN NODE ~D =====~%" count)
        (format stream "~S~%~%" (node-state-summary node))
        (let ((plan (get-state node)))
          (when (typep plan 'plan)
            (write-plan-snapshot plan stream)
            (format stream "~%")))))))

(defun write-solution-snapshot (pathname)
  (with-open-file (stream pathname
                          :direction :output
                          :if-exists :supersede
                          :if-does-not-exist :create)
    (format stream "Solution value: ~S~%~%" *solution*)
    (when (typep *solution* 'plan)
      (write-plan-snapshot *solution* stream))))

(defun write-drp-stack-snapshot (pathname &key (limit 50))
  (with-open-file (stream pathname
                          :direction :output
                          :if-exists :supersede
                          :if-does-not-exist :create)
    (format stream "DRP stack depth: ~D~%~%" (length *drp-stack*))
    (let ((count 0))
      (dolist (open-list *drp-stack*)
        (when (>= count limit)
          (return))
        (incf count)
        (format stream "===== DRP ENTRY ~D =====~%" count)
        (format stream "Open length: ~S~%" (length open-list))
        (when open-list
          (let ((node (car open-list)))
            (format stream "~S~%~%" (node-state-summary node))))))))

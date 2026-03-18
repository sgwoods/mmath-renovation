;;; Helpers for writing post-run search traces under SBCL.

(defvar *score-trace-enabled* nil)
(defvar *score-trace-limit* 5000)
(defvar *score-trace-records* nil)

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

(defun trace-base-goal-heuristic (plan)
  "Return the base TWEAK heuristic term used inside both tweak and abtweak."
  (cond
   ((not (typep plan 'plan)) 0)
   ((equal *heuristic-mode* 'num-of-unsat-goals)
    (ignore-errors (or (num-of-unsat-goals plan) 0)))
   ((equal *heuristic-mode* 'user-defined)
    (ignore-errors
      (let ((fn (user-heuristic)))
        (if fn
            (or (funcall fn plan) 0)
          0))))
   (t 0)))

(defun trace-left-wedge-adjustment (plan)
  "Return the left-wedge adjustment term currently applied to PLAN."
  (cond
   ((not (typep plan 'plan)) 0)
   ((not *left-wedge-mode*) 0)
   ((not (eq *planner-mode* 'abtweak)) 0)
   (t
    (ignore-errors
      (let ((fn (left-wedge-function)))
        (if fn
            (or (funcall fn plan) 0)
          0))))))

(defun frontier-node-quality-summary (node)
  (let* ((plan (get-state node))
         (unsat-pairs (plan-unsat-user-precond-pairs plan))
         (base-goal-heuristic (trace-base-goal-heuristic plan))
         (left-wedge-adjustment (trace-left-wedge-adjustment plan)))
    (list
     :priority (get-priority node)
     :search-cost (get-cost node)
     :heuristic-component (- (get-priority node) (get-cost node))
     :base-goal-heuristic base-goal-heuristic
     :left-wedge-adjustment left-wedge-adjustment
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

(defun frontier-no-left-wedge-score (node)
  (let ((summary (frontier-node-quality-summary node)))
    (+ (getf summary :search-cost)
       (getf summary :base-goal-heuristic))))

(defun frontier-unsat-aware-score (node)
  (let ((summary (frontier-node-quality-summary node)))
    (+ (getf summary :search-cost)
       (getf summary :base-goal-heuristic)
       (getf summary :unsat-count))))

(defun reset-score-trace (&key (limit 5000))
  (setq *score-trace-enabled* t)
  (setq *score-trace-limit* limit)
  (setq *score-trace-records* nil))

(defun disable-score-trace ()
  (setq *score-trace-enabled* nil))

(defun score-trace-record-summary (record)
  (list
   :insertion-index (getf record :insertion-index)
   :priority (getf record :priority)
   :no-left-wedge-score (getf record :no-left-wedge-score)
   :unsat-aware-score (getf record :unsat-aware-score)
   :search-cost (getf record :search-cost)
   :base-goal-heuristic (getf record :base-goal-heuristic)
   :left-wedge-adjustment (getf record :left-wedge-adjustment)
   :plan-id (getf record :plan-id)
   :plan-kval (getf record :plan-kval)
   :plan-cost (getf record :plan-cost)
   :plan-length (getf record :plan-length)
   :unsat-count (getf record :unsat-count)
   :parent-plan-id (getf record :parent-plan-id)
   :parent-kval (getf record :parent-kval)
   :parent-cost (getf record :parent-cost)
   :parent-length (getf record :parent-length)
   :parent-unsat-count (getf record :parent-unsat-count)
   :first-unsat (getf record :first-unsat)))

(defun record-score-trace-node (node parent-state)
  (when (and *score-trace-enabled*
             (< (length *score-trace-records*) *score-trace-limit*))
    (let* ((summary (frontier-node-quality-summary node))
           (plan (get-state node))
           (parent-unsat (if (typep parent-state 'plan)
                             (plan-unsat-user-precond-pairs parent-state)
                           nil)))
      (push
       (list
        :insertion-index (1+ *num-generated*)
        :priority (getf summary :priority)
        :no-left-wedge-score (frontier-no-left-wedge-score node)
        :unsat-aware-score (frontier-unsat-aware-score node)
        :search-cost (getf summary :search-cost)
        :base-goal-heuristic (getf summary :base-goal-heuristic)
        :left-wedge-adjustment (getf summary :left-wedge-adjustment)
        :plan-id (when (typep plan 'plan) (plan-id plan))
        :plan-kval (getf summary :plan-kval)
        :plan-cost (getf summary :plan-cost)
        :plan-length (getf summary :plan-length)
        :unsat-count (getf summary :unsat-count)
        :first-unsat (getf summary :first-unsat)
        :parent-plan-id (when (typep parent-state 'plan)
                          (plan-id parent-state))
        :parent-kval (when (typep parent-state 'plan)
                       (plan-kval parent-state))
        :parent-cost (when (typep parent-state 'plan)
                       (plan-cost parent-state))
        :parent-length (when (typep parent-state 'plan)
                         (length (plan-a parent-state)))
        :parent-unsat-count (if parent-unsat (length parent-unsat) 0))
       *score-trace-records*))))

(defun score-trace-records ()
  (reverse *score-trace-records*))

(defun sort-score-trace-records (records key)
  (sort (copy-list records)
        #'(lambda (rec1 rec2)
            (let ((score1 (getf rec1 key))
                  (score2 (getf rec2 key)))
              (if (= score1 score2)
                  (< (getf rec1 :insertion-index)
                     (getf rec2 :insertion-index))
                (< score1 score2))))))

(defun score-trace-rank-of-plan-id (records plan-id key)
  (let ((rank 0)
        (found nil))
    (dolist (record (sort-score-trace-records records key) (and found rank))
      (incf rank)
      (when (equal (getf record :plan-id) plan-id)
        (setq found t)
        (return rank)))))

(defun write-score-trace-snapshot (pathname &key (limit 50))
  (with-open-file (stream pathname
                          :direction :output
                          :if-exists :supersede
                          :if-does-not-exist :create)
    (let* ((records (score-trace-records))
           (actual (sort-score-trace-records records :priority))
           (no-lw (sort-score-trace-records records :no-left-wedge-score))
           (unsat-aware (sort-score-trace-records records :unsat-aware-score)))
      (format stream "Recorded insertions: ~S~%~%" (length records))
      (format stream "Top inserted nodes by actual score:~%")
      (loop for record in actual
            for rank from 1
            while (<= rank limit) do
              (format stream "~&===== ACTUAL INSERTION RANK ~D =====~%" rank)
              (format stream "~S~%~%" (score-trace-record-summary record)))
      (format stream "~%Top inserted nodes by no-left-wedge score:~%")
      (loop for record in no-lw
            for rank from 1
            while (<= rank limit) do
              (format stream "~&===== NO-LW INSERTION RANK ~D =====~%" rank)
              (format stream "~S~%~%" (score-trace-record-summary record)))
      (format stream "~%Top inserted nodes by unsat-aware score:~%")
      (loop for record in unsat-aware
            for rank from 1
            while (<= rank limit) do
              (format stream "~&===== UNSAT-AWARE INSERTION RANK ~D =====~%" rank)
              (format stream "~S~%~%" (score-trace-record-summary record))))))

(defun write-score-trace-report (pathname)
  (with-open-file (stream pathname
                          :direction :output
                          :if-exists :supersede
                          :if-does-not-exist :create)
    (let* ((records (score-trace-records))
           (actual (sort-score-trace-records records :priority))
           (closure (sort-score-trace-records records :unsat-count))
           (actual-top (first actual))
           (closure-top (first closure)))
      (format stream "# Hanoi-4 Insertion Score Trace~%~%")
      (format stream "- Recorded inserted nodes: `~S`~%~%" (length records))
      (when actual-top
        (format stream "## Actual Top Inserted Node~%~%")
        (format stream "- Plan id: `~S`~%" (getf actual-top :plan-id))
        (format stream "- Insertion index: `~S`~%" (getf actual-top :insertion-index))
        (format stream "- Actual score: `~S`~%" (getf actual-top :priority))
        (format stream "- No-left-wedge score: `~S`~%" (getf actual-top :no-left-wedge-score))
        (format stream "- Unsat-aware score: `~S`~%" (getf actual-top :unsat-aware-score))
        (format stream "- Kval: `~S`~%" (getf actual-top :plan-kval))
        (format stream "- Cost: `~S`~%" (getf actual-top :plan-cost))
        (format stream "- Length: `~S`~%" (getf actual-top :plan-length))
        (format stream "- Unsatisfied pairs: `~S`~%" (getf actual-top :unsat-count))
        (format stream "- Base heuristic: `~S`~%" (getf actual-top :base-goal-heuristic))
        (format stream "- Left-wedge adjustment: `~S`~%" (getf actual-top :left-wedge-adjustment))
        (format stream "- Rank without left-wedge: `~S`~%" (score-trace-rank-of-plan-id records (getf actual-top :plan-id) :no-left-wedge-score))
        (format stream "- Rank under unsat-aware score: `~S`~%~%"
                (score-trace-rank-of-plan-id records (getf actual-top :plan-id) :unsat-aware-score)))
      (when closure-top
        (format stream "## Best Closure-Oriented Inserted Node~%~%")
        (format stream "- Plan id: `~S`~%" (getf closure-top :plan-id))
        (format stream "- Insertion index: `~S`~%" (getf closure-top :insertion-index))
        (format stream "- Actual score: `~S`~%" (getf closure-top :priority))
        (format stream "- No-left-wedge score: `~S`~%" (getf closure-top :no-left-wedge-score))
        (format stream "- Unsat-aware score: `~S`~%" (getf closure-top :unsat-aware-score))
        (format stream "- Kval: `~S`~%" (getf closure-top :plan-kval))
        (format stream "- Cost: `~S`~%" (getf closure-top :plan-cost))
        (format stream "- Length: `~S`~%" (getf closure-top :plan-length))
        (format stream "- Unsatisfied pairs: `~S`~%" (getf closure-top :unsat-count))
        (format stream "- Base heuristic: `~S`~%" (getf closure-top :base-goal-heuristic))
        (format stream "- Left-wedge adjustment: `~S`~%" (getf closure-top :left-wedge-adjustment))
        (format stream "- Rank under actual score: `~S`~%" (score-trace-rank-of-plan-id records (getf closure-top :plan-id) :priority))
        (format stream "- Rank without left-wedge: `~S`~%" (score-trace-rank-of-plan-id records (getf closure-top :plan-id) :no-left-wedge-score))
        (format stream "- Rank under unsat-aware score: `~S`~%~%"
                (score-trace-rank-of-plan-id records (getf closure-top :plan-id) :unsat-aware-score)))
      (format stream "## Interpretation~%~%")
      (format stream "- This report captures the score shape at insertion time, before OPEN ordering and later pruning distort the picture further.~%")
      (format stream "- Large rank shifts here indicate the ranking bias is already present when nodes are created, not only after they accumulate in the frontier.~%"))))

(defun frontier-sort-by-score (nodes score-fn)
  (sort (copy-list nodes)
        #'(lambda (node1 node2)
            (let ((score1 (funcall score-fn node1))
                  (score2 (funcall score-fn node2)))
              (if (= score1 score2)
                  (< (get-priority node1) (get-priority node2))
                (< score1 score2))))))

(defun frontier-rank-of-plan-id (nodes plan-id)
  (let ((rank 0)
        (found nil))
    (dolist (node nodes (and found rank))
      (incf rank)
      (when (equal (frontier-plan-id node) plan-id)
        (setq found t)
        (return rank)))))

(defun frontier-top-n-summaries (nodes sort-fn count)
  (mapcar #'frontier-node-quality-summary
          (frontier-top-distinct-nodes nodes sort-fn count)))

(defun average-of-key (records key)
  (if (null records)
      0
    (/ (apply #'+ (mapcar #'(lambda (record) (getf record key)) records))
       (length records))))

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

(defun make-replay-copy-of-plan (plan)
  "Return a replay-safe copy of PLAN for diagnostic restarts."
  (declare (type plan plan))
  (remove-constant-nonco
   (make-plan
    :id        (create-planid)
    :a         (make-copy-of-op-list (plan-a plan))
    :b         (copy-tree (plan-b plan))
    :nc        (copy-tree (plan-nc plan))
    :cr        (copy-tree (plan-cr plan))
    :var       (copy-tree (plan-var plan))
    :cost      (plan-cost plan)
    :kval      (plan-kval plan)
    :conflicts (copy-tree (plan-conflicts plan))
    :op-count  (copy-tree (plan-op-count plan))
    :invalid   (plan-invalid plan))))

(defun frontier-plan-id (node)
  (let ((plan (get-state node)))
    (when (typep plan 'plan)
      (plan-id plan))))

(defun frontier-top-distinct-nodes (nodes sort-fn count)
  "Return up to COUNT nodes from NODES after SORT-FN, distinct by plan id."
  (let ((sorted (funcall sort-fn nodes))
        (seen nil)
        (result nil))
    (dolist (node sorted (nreverse result))
      (when (< (length result) count)
        (let ((plan-id (frontier-plan-id node)))
          (when (and plan-id
                     (not (member plan-id seen :test 'equal)))
            (push node result)
            (push plan-id seen)))))))

(defun replay-frontier-node
    (node &key
          (planner-mode *planner-mode*)
          (mp-mode *mp-mode*)
          (mp-weak-mode *mp-weak-mode*)
          (abstract-goal-mode *abstract-goal-mode*)
          (left-wedge-mode nil)
          (drp-mode nil)
          (heuristic-mode 'user-defined)
          (use-primary-effect-p *use-primary-effect-p*)
          (control-strategy 'bfs)
          (existing-only nil)
          (solution-limit 100)
          (expand-bound 10000)
          (generate-bound 50000)
          (open-bound 50000)
          (cpu-sec-limit 30))
  "Restart search from NODE's plan under a simpler diagnostic continuation."
  (let* ((plan (get-state node))
         (replay-plan (and (typep plan 'plan)
                           (make-replay-copy-of-plan plan)))
         (result (and replay-plan
                      (plan initial goal
                            :planner-mode planner-mode
                            :mp-mode mp-mode
                            :mp-weak-mode mp-weak-mode
                            :abstract-goal-mode abstract-goal-mode
                            :left-wedge-mode left-wedge-mode
                            :drp-mode drp-mode
                            :heuristic-mode heuristic-mode
                            :use-primary-effect-p use-primary-effect-p
                            :control-strategy control-strategy
                            :existing-only existing-only
                            :solution-limit solution-limit
                            :expand-bound expand-bound
                            :generate-bound generate-bound
                            :open-bound open-bound
                            :cpu-sec-limit cpu-sec-limit
                            :output-file 'no-output
                            :init-plan replay-plan))))
    (list
     :result result
     :solution *solution*
     :solution-type (type-of *solution*)
     :solution-cost (when (typep *solution* 'plan) (plan-cost *solution*))
     :solution-kval (when (typep *solution* 'plan) (plan-kval *solution*))
     :solution-length (when (typep *solution* 'plan)
                        (length (plan-a *solution*)))
     :num-expanded *num-expanded*
     :num-generated *num-generated*
     :mp-pruned *mp-pruned*)))

(defun frontier-replay-record
    (node cohort rank &key
          (planner-mode *planner-mode*)
          (mp-mode *mp-mode*)
          (mp-weak-mode *mp-weak-mode*)
          (abstract-goal-mode *abstract-goal-mode*)
          (left-wedge-mode nil)
          (drp-mode nil)
          (heuristic-mode 'user-defined)
          (use-primary-effect-p *use-primary-effect-p*)
          (control-strategy 'bfs)
          (existing-only nil)
          (solution-limit 100)
          (expand-bound 10000)
          (generate-bound 50000)
          (open-bound 50000)
          (cpu-sec-limit 30))
  (let ((source-summary (frontier-node-quality-summary node))
        (replay-summary
         (replay-frontier-node
          node
          :planner-mode planner-mode
          :mp-mode mp-mode
          :mp-weak-mode mp-weak-mode
          :abstract-goal-mode abstract-goal-mode
          :left-wedge-mode left-wedge-mode
          :drp-mode drp-mode
          :heuristic-mode heuristic-mode
          :use-primary-effect-p use-primary-effect-p
          :control-strategy control-strategy
          :existing-only existing-only
          :solution-limit solution-limit
          :expand-bound expand-bound
          :generate-bound generate-bound
          :open-bound open-bound
          :cpu-sec-limit cpu-sec-limit)))
    (list
     :cohort cohort
     :source-rank rank
     :source source-summary
     :replay replay-summary)))

(defun frontier-replay-cohort
    (nodes cohort count sort-fn &key
          (planner-mode *planner-mode*)
          (mp-mode *mp-mode*)
          (mp-weak-mode *mp-weak-mode*)
          (abstract-goal-mode *abstract-goal-mode*)
          (left-wedge-mode nil)
          (drp-mode nil)
          (heuristic-mode 'user-defined)
          (use-primary-effect-p *use-primary-effect-p*)
          (control-strategy 'bfs)
          (existing-only nil)
          (solution-limit 100)
          (expand-bound 10000)
          (generate-bound 50000)
          (open-bound 50000)
          (cpu-sec-limit 30))
  (let ((selected (frontier-top-distinct-nodes nodes sort-fn count))
        (records nil)
        (rank 0))
    (dolist (node selected (nreverse records))
      (incf rank)
      (push
       (frontier-replay-record
        node cohort rank
        :planner-mode planner-mode
        :mp-mode mp-mode
        :mp-weak-mode mp-weak-mode
        :abstract-goal-mode abstract-goal-mode
        :left-wedge-mode left-wedge-mode
        :drp-mode drp-mode
        :heuristic-mode heuristic-mode
        :use-primary-effect-p use-primary-effect-p
        :control-strategy control-strategy
        :existing-only existing-only
        :solution-limit solution-limit
        :expand-bound expand-bound
        :generate-bound generate-bound
        :open-bound open-bound
        :cpu-sec-limit cpu-sec-limit)
       records))))

(defun replay-solved-p (record)
  (eq (getf (getf record :replay) :solution-type) 'plan))

(defun replay-best-solution-length (records)
  (let ((lengths
         (remove nil
                 (mapcar #'(lambda (record)
                             (getf (getf record :replay) :solution-length))
                         records))))
    (when lengths
      (apply #'min lengths))))

(defun write-frontier-replay-report
    (pathname title source-summary priority-records closure-records)
  (labels
      ((write-record-line (stream record)
         (let* ((source (getf record :source))
                (replay (getf record :replay))
                (solution-type (getf replay :solution-type))
                (outcome (if (eq solution-type 'plan)
                             'solved
                           (getf replay :solution))))
           (format stream
                   "| ~A | ~D | ~S | ~S | ~S | ~S | ~S | ~S | ~S | ~S |~%"
                   (getf record :cohort)
                   (getf record :source-rank)
                   (getf source :priority)
                   (getf source :plan-kval)
                   (getf source :plan-cost)
                   (getf source :unsat-count)
                   outcome
                   (getf replay :num-expanded)
                   (getf replay :num-generated)
                   (getf replay :solution-length)))))
    (with-open-file (stream pathname
                            :direction :output
                            :if-exists :supersede
                            :if-does-not-exist :create)
      (format stream "# ~A~%~%" title)
      (format stream "## Source Frontier~%~%")
      (format stream "- Open nodes: `~S`~%" (getf source-summary :open-count))
      (format stream "- Best unsatisfied-pair count: `~S`~%"
              (getf source-summary :best-unsat-count))
      (format stream "- Priority bucket leader count: `~S`~%"
              (getf source-summary :top-bucket-count))
      (format stream "- Replay heuristic: `user-defined` (zero)~%")
      (format stream "- Replay left-wedge: `nil`~%")
      (format stream "- Replay control strategy: `bfs`~%~%")
      (format stream "## Replay Outcomes~%~%")
      (format stream
              "| Cohort | Rank | Source priority | Source kval | Source cost | Source unsat | Replay outcome | Replay expanded | Replay generated | Replay solution length |~%")
      (format stream
              "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |~%")
      (dolist (record priority-records)
        (write-record-line stream record))
      (dolist (record closure-records)
        (write-record-line stream record))
      (format stream "~%## Cohort Summary~%~%")
      (format stream "- Priority cohort solved count: `~D`~%"
              (count-if #'replay-solved-p priority-records))
      (format stream "- Closure cohort solved count: `~D`~%"
              (count-if #'replay-solved-p closure-records))
      (format stream "- Priority cohort best replay solution length: `~S`~%"
              (replay-best-solution-length priority-records))
      (format stream "- Closure cohort best replay solution length: `~S`~%"
              (replay-best-solution-length closure-records)))))

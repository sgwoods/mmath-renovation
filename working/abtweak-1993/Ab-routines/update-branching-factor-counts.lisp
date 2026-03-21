;;; this file contains functions that deal with counting the abstract 
;;; branching factors for search across the abstract levels.
;;; The branching factor is kept track of in an array *abs-branching-counts* 
;;; The file also records the total number of consequtive failures in 
;;  refinement, which can be used to estimate the refinment probability.

(defun abstraction-level-count ()
  "Number of addressable abstraction levels for the current hierarchy.
   This is max criticality plus one, not merely the number of critical-list
   entries, because grouped hierarchies can skip numeric levels."
  (1+ (find-initial-k-val)))

(defun dump-drp-stack-till (level)
  "*drp-stack* holds plans at different levels.  Dumps
   all plans on top of the stack till a plan at level 
   appears."
  (do ((rem *drp-stack* (cdr rem)))
      ((null rem) nil)
      (setq *open* (car rem))
      (if (= (plan-kval (get-state (first-of-open ))) level)
	  (return)
	(pop *drp-stack*))))


;; updating abstract branching counts.

(defun get-abs-branching-count (level)
  (aref *abs-branching-counts* level))

(defun increment-abs-branching-count (i)
  "plan has been moved to level i-1.  Increment *Abs-Branching-Counts*
   by 1 at index i."
  (setf (aref *abs-branching-counts* i) 
	(1+ (aref *abs-branching-counts* i))))

(defun reset-abs-branching-counts (level)
  "level is where abstract branching factor meets limit.
   But above level, more levels may also already have 
   met their limit.  This function finds the highest such level,
   then resets all  counts below that level to 0.  Finally, 
   the open list above that level is returned, and with 
   the drp stack updated as well."
  (dotimes (index (1+ level))
	   (setf (aref *abs-branching-counts* index) 0))
  (setq level (1+ level))
  (do ()
      ((or (< (aref *abs-branching-counts* level)
	      *abs-branching-limit*)
	   (null *drp-stack*))
       (pop *drp-stack*))
      (setf (aref *abs-branching-counts* level) 0)
      (pop *drp-stack*)
      (setq level (1+ level))))

(defun initialize-abs-branching-counts ()
  "initialize an array of N levels of abstraction.
   For keeping track of abstract branching factors."
  (let ((total-levels (abstraction-level-count)))
    (setq *abs-branching-counts*
	  (make-array total-levels :initial-element 0))))

;;------------------------------------------------------------
;;   abs failure counts
;;------------------------------------------------------------
(defun initialize-abs-ref-counts ()
  "initialize an array of N levels of abstraction.
   For keeping track of abstract refimenments at level i."
  (let ((total-levels (abstraction-level-count)))
    (setq *abs-ref-counts*
	  (make-array total-levels :initial-element 0))
    (setq *new-refinement-p*
	  (make-array total-levels :initial-element nil))))

(defun update-abs-ref-counts (i)
  "access array of N levels of abstraction.
   For keeping track of abstract refimenments at level i."
  (setf (aref *abs-ref-counts* i)
	  (1+ (aref *abs-ref-counts* i))) )

(defun initialize-success-ref-counts ()
  "initialize an array of N levels of abstraction.
   The array is indentified as *abs-succ-counts*.
   (aref *abs-success-counts* i)=n, if at level
   i, n successful refinements are made."

  (let ((total-levels (abstraction-level-count)))
    (setq *abs-success-counts*
	  (make-array total-levels :initial-element 0))))


(defun update-abs-succ-counts (i)
  "called when a successful refinement is made from level i-1 to 
   level i-2.  That is, when a good node is found on level i-1.
   Then increment (*abs-success-counts* i).

   However, care is taken so the successful refinement is counted once
   under each subtree."

  (if 
      (and
       (< i (abstraction-level-count))
       (aref *new-refinement-p* i))

      (let ()
	(setf (aref *new-refinement-p* i) nil)
	(setf (aref *abs-success-counts* i)
	      (1+ (aref *abs-success-counts* i))))))

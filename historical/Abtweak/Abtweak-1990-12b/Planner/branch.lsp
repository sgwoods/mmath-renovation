; planner/branch

; compute branching factor values
;  (called by ab-successors, successors)
;  
;  *k-branching* '( (max-k total number) ... (0 total number))
;

(defun init-k-branching ()
  "planner/branch "
  (if (eq *mode* 'abtweak)
      (let* ( 
             (rawlist 
               (make-list (1+ (find-initial-k-val)) :initial-element '(0 0 0)))
             (donelist
                (dotimes (k (1+ (find-initial-k-val)) rawlist)
                  (setf (nth k rawlist) 
                        (list k 
                              (second (nth k rawlist)) 
                              (third (nth k rawlist)))))) )
        donelist)
      '( (0 0 0) )))

(defun update-br-factor (kval len)
  "planner/branch " 
   (setf (nth kval *k-branching*)
         (list
              (first (nth kval *k-branching*))
              (+ (second (nth kval *k-branching*)) len)

              (1+ (third (nth kval *k-branching*))) )))

(defun compute-all-br ()
  "planner/branch " 
  (mapcar #'(lambda (element) 
               (list (first element) (avg-br-factor (first element))))
             *k-branching*))

(defun avg-br-factor (kval)
  "planner/branch "   
  (let* (
         (total (* (second (nth kval *k-branching*)) 1.0))
         (i-num (third (nth kval *k-branching*)))
         (num   (if (eq i-num 0) 1 i-num)) )
   (declare
       (type float total)
       (type float i-num)
       (type float num))
   
   (simp (/ total num))))

(defun simp (val)
  (/ (round (* 100 val)) 100.0))




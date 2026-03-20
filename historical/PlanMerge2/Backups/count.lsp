;property list functions for merge algorithm

;put assigns property y to object x with initial value x
(defun putp (x y z)
     (setf (get x y ) z))

;init_count initializes the 'count property of object x to 0
(defun init_count (x)
     (putp x 'count '0))

;inc_count increments the 'count property of object x
(defun inc_count (x)
     (putp x 'count
                    (+ 1 (get x 'count))))

;create unique set (reversed by accident) out of plan actions
(defun unique (p s)
   (if (eq nil (cdr p))                   ;p has only one action
       (xisrt (car p) s)                  ;put single action into s
       (unique (cdr p) (xisrt (car p) s)))) ;put rest of stuff into p

;create set as I want it exactly - kludge routine!!
(defun plan_set (x)
    (reverse (unique x '())))
    
;performs unique insert to the head of a list
(defun xisrt (x y)
    (if (member x y) 
        (values y)
        (append (list x) y)))

;(defun counts (x)   
    (cond ((eq x nil) nil)
          (t (progn
                   (inc_count (car x))
                   (counts (cdr x))))))


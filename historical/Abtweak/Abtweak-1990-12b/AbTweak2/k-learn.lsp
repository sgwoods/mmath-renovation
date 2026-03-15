; abtweak/k-learn.lsp

(not completed -----)

; learning via k-list values...
; if k-mode on, then check the number of (this level = k)
; operators in this plan correct at level k - 1 (new-plan-list)

; k-list defined by criticality:  (@higher ..... @ lowest)
;  so the highest crit is at posn 0 in *k-list*

(defun learn-kmode (lev-k-plan)
   "abtweak/k-learn.lsp
    a correct plan has been found at level k-1"
  (declare (type plan lev-k-plan))
  (let* (
          (lev-k    (1- (get_kval lev-k-plan)))               ; crit level
          (klst-pos (- (length *k-list*) lev-k)               ; k-list position
          (oldval   (get-klist-val ))                         ; old k-list val
          (newval   (get-k-num-ops (get_a lev-k-plan) lev-k)) ; poss. new val
        )

     (if (> newval oldval)   
         (update-klist klst-pos newval)) )))                  ; repl k-list val


(defun update-klist (klst-pos newval)
   "abtweak/k-learn.lsp
    replace the lev-k item of *k-list* with the newval"
    (declare (type integer klst-pos) (type integer newval))
    (setf (nth klist-pos *k-list*) newval))

(defun get-klist-val (klst-pos)
   "abtweak/k-learn.lsp
    return the k-list value for this level of criticality"
 (declare (type integer klst-pos))
 (nth klst-pos *k-list*))
   
;(defun get-k-num-ops (alist kval)
;   "abtweak/k-learn.lsp
;    return the number of ops at this plan's crit val in plan-a"
; (declare (type (list list) alist) (type integer kval))
; (count-if (eq kval (       )  alist))


; *k-learn* vector consists of 1 symbol for each criticality (0 .... max-crit)
;   each item of this vector has the following properties:
;     total  =  the total number of operators at this level seen in plans
;     times  =  the total number of times a correct plan has been seen @ level
;       giving avg = (round-up total / times)  avg depth of a solution @ level

;putp (element property property_value)
;  assigns element the property with property value
(defun putp (x y z)
  " test "
     (setf (get x y ) z))

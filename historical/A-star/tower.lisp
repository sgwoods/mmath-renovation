;;; tower of honoi puzzle, domain dependent part.

;*** state representation:
; A state is represented as a list of 3 pegs, each peg being a stack.
; Initial state:  ((a b c) nil nil),  Goal state: (nil nil (a b c))
; Assumed:  disk a is smaller than b, which is smaller than c.

;**** tower rule access part:

(defun get-precond (rule)
   (second rule))

(defun get-effect (rule)
   (third rule))                    
        
(defun get-rule-cost (rule)
   (fourth rule))


;*** tower rules

(setq *rules* 
   '(
      ;move from si to sj
      (;parameters 
         (i j)
       ;preconditions 
         (lambda (state i j) 
            (let ((pegi (nth i state))   ;peg i
                  (pegj (nth j state)))  ;peg j
               (and (not (null pegi))
                  (smallerp (top pegi) (top pegj)))))
       ;effects
          (lambda (state i j)
            (let ((pegi (nth i state))   ;peg i
                  (pegj (nth j state)))  ;peg j
               (replace-stack (replace-stack state i (cdr pegi))
                  j (cons (top pegi) pegj))))
      ;cost
         (lambda (state i j)
            1))))

;**** rule dependent functions:


(defun top (stack)
   (car stack))

(defun smallerp (diska diskb)
   (or (null diskb)
      (char< (character diska) (character diskb))))

(defun replace-stack (state i stacki)
   "returns state with ith stack replaced with stacki
   the 0th element is the first in the list"
   (let ((segment1 (reverse (nthcdr (- (length state) i) (reverse state))))
         (segment2 (list stacki))
         (segment3 (nthcdr (1+ i) state)))
      (append segment1 segment2 segment3)))



;**** tower rule application part:
; called by state-expansion functions.
;****

(defun get-all-instances (rule state)
   "returns the set of all instances of (successor cost) of rule applicalbe to state"
   (do ((i 0 (1+ i))
        (result nil))
      ((= i (length state)) result)
      (do ((j 0 (1+ j)))
          ((= j (length state)))
           (if (and (/= i j)
                 (applicable-p rule state i j))
              (setq result (cons (list 
                       (funcall (get-effect rule) state i j)
                       (funcall (get-rule-cost rule) state i j))
                                result))))))
                    
(defun applicable-p (rule state i j)
   "T if precondition of rule is satisfied in rule i j"
   (funcall (get-precond rule) state i j))



;******** tower interface part *********

(defun print-state (state)
   "print state on screen"
   (terpri)
   (princ "Peg1: ") (princ (first state))(terpri)
   (princ "Peg2: ") (princ (second state)) (terpri)
   (princ "Peg3: ") (princ (third state)) (terpri))

;****** tower goal checking part: *********

(defun goal-p (state)
   "T if state is a goal"
   (equal state '(nil nil (a b c))))


;******  tower heuristic evaluation part ********

(defun which-pri-function ()
   "returns a priority function:  the num of disks on peg 3"
   '(lambda (state) (length (third state))))
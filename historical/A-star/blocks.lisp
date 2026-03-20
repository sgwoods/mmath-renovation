;;; blocks world, domain dependent part.

;*** state representation:
; A state is represented by a three element list:
;  Element 1 contains a list of blocks on the table
;  Element 2 contains a list of stack pairs - (a b) indicates a is on b
;  Element 3 contains a list of blcoks that are clear
; Initial state:  ( (b c) ( (a b) ) (a c) )      b, c ontable; a on b; a,c clr
; Goal state:     ( (c )  ( (a b) (b c) ) (a) )  c ontable; a on b on c; c clr

(setq tst1  '( (b c) ( (a b) ) (a c) ) )
(setq tst2 '( (a) ( (b c) (c a) ) (b) ))
(setq goal1 '( (c )  ( (a b) (b c) ) (a) ) )

;**** rule access part:

(defun get-precond (rule)
   (second rule))

(defun get-effect (rule)
   (third rule))                    
        
(defun get-rule-cost (rule)
   (fourth rule))

;*** blocks rules
(setq *blocks* '(a b c))

(setq *rules* 
   '(
      ;stack x on y
      (;parameters  - stack
         (x y)
       ;preconditions 
         (lambda (state x y) 
            (let 
                ( (ontable-x (is_ontable-p state x) )
                  (clear-x   (is_clear-p   state x) )
                  (clear-y   (is_clear-p   state y) )
		)
               (and ontable-x clear-x clear-y)
             ))
       ;effects
          (lambda (state x y)
                (list
                    (make-not-ontable (get_ontable state) x)
                    (make-on          (get_stacks  state) x y)
                    (make-not-clear   (get_clear   state) y)
                ))
      ;cost
         (lambda (state x y)
            1))
   ;unstack x from y
      (;parameters - unstack
         (x y)
       ;preconditions 
         (lambda (state x y) 
            (let 
                ( 
                  (clear-x   (is_clear-p   state x) )
                  (on-xy     (is_on-p      state x y ) )
		)
               (and clear-x on-xy)
             ))
       ;effects
          (lambda (state x y)
                (list
                    (make-ontable (get_ontable state) x)
                    (make-not-on  (get_stacks  state) x y)
                    (make-clear   (get_clear   state) y)
                ))
      ;cost
         (lambda (state x y)
            1))
   ))


;**** rule dependent functions:

(defun get_ontable (state)
   (car state))
(defun get_stacks (state)
   (second state))
(defun get_clear (state)
   (third state))

(defun is_ontable-p (state x)
   (if (memb x (get_ontable state))
       t
       nil))

(defun is_clear-p (state x)
   (if (memb x (get_clear state))
       t
       nil))

(defun is_on-p (state x y)
   (if (memb (list x y) (get_stacks state))
       t 
       nil))

(defun make-ontable (table x)
   (if (memb x table)
       table
       (cons x table)))

(defun make-not-ontable (table x)
   (if (not (memb x table))
       table
       (delete x table)))

(defun make-on (stacks x y)
   (if (memb (list x y) stacks)
       stacks
       (cons (list x y) stacks)))

(defun make-not-on (stacks x y)
   (if (not (memb (list x y) stacks))
       stacks
       (delete (list x y) stacks)))

(defun make-clear (clears x)
   (if (memb x clears)
       clears
       (cons x clears)))

(defun make-not-clear (clears x)
   (if (not (memb x clears))
       clears
       (delete x clears)))

(defun memb (e list)
  "Acts like member, but is general over list structures"
  (member e list 
     :test #'(lambda (e element) (equal element e))))

(defun delete (e list)
   "Remove a list or atom from a list"
  (if (eq (car list) nil)
      nil
      (if (equal e (car list))   ; e found in list      
          (delete e (cdr list)) 
          (append (list (car list))
                  (delete e (cdr list))))))

;**** tower rule application part:
; called by state-expansion functions.
;****

(defun get-all-instances (rule state)
   "returns the set of all instances of (successor cost) of rule applicalbe to state"
   (do ((loop1 0 (1+ loop1) )
        ( result nil ))
       ((= loop1 (length *blocks*)) result)
       (do ((loop2 0 (1+ loop2) ))
           ((= loop2 (length *blocks*)))
            (let
              (
                ( x  (nth loop1 *blocks*) )
                ( y  (nth loop2 *blocks*) )
              )
            (if (and (not (equal loop1 loop2))
                     (applicable-p rule state x y))
                 (setq result  (cons (list
                          (funcall (get-effect    rule) state x y)
                          (funcall (get-rule-cost rule) state x y))
				    result)))))))
                  
(defun applicable-p (rule state x y)
   "T if precondition of rule is satisfied in rule i j"
   (funcall (get-precond rule) state x y))


;******** tower interface part *********

(defun print-state (state)
   "print state on screen"
   (terpri)
   (princ "Ontables: ") (princ (get_ontable state))(terpri)
   (princ "Stacks  : ") (princ (get_stacks  state)) (terpri)
   (princ "Clear   : ") (princ (get_clear   state)) (terpri))

;****** tower goal checking part: *********

(defun goal-p (state)
   "T if state is a goal"
   (equal state '( (c) ( (a b) (b c) ) (a) )))

;******  tower heuristic evaluation part ********

(defun which-pri-function ()
   "returns a priority function:  number of stackings done"
   '(lambda (state) (length (get_stacks state))))
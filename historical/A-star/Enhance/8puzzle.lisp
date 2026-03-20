;************************** 8 PUZZLE ROUTINES ******************************

; Note:  a state is represented by a list of 9 elements, representing
; the 9 tiles on board in row order.

(defun get-precond (rule)
   (second rule))

(defun get-effect (rule)
   (third rule))

(defun get-rule-cost (rule)
   (fourth rule))

(setq *rules* '(
      (;rule1: move blank (0) up,
         ;parameters
          (state)
         ;preconditions
          (lambda (state) (member (get-pos-of-0 state) '(3 4 5 6 7 8)))
         ;effects
          (lambda (state) 
             (let ((new-pos-of-0 (- (get-pos-of-0 state) 3)))
                (switch new-pos-of-0 (get-pos-of-0 state) state)))
                   ;cost
           (lambda (state) 1))
       
      (;rule2: move blank (0) left,
         ;parameters
            (state)
         ;preconditions
            (lambda (state) (member (get-pos-of-0 state) '(1 2 4 5 7 8)))
         ;effects
            (lambda (state) 
             (let ((new-pos-of-0 (- (get-pos-of-0 state) 1)))
                (switch new-pos-of-0 (get-pos-of-0 state) state)))
                   ;cost
           (lambda (state) 1))

      (;rule3: move blank (0) right,
         ;parameters
           (state)
         ;preconditions
           (lambda (state) (member (get-pos-of-0 state) '(0 1 3 4 6 7)))
         ;effects
           (lambda (state) 
             (let ((new-pos-of-0 (+ (get-pos-of-0 state) 1)))
                (switch new-pos-of-0 (get-pos-of-0 state) state)))
                   ;cost
           (lambda (state) 1))
       
      (;rule4: move blank (0) down,
         ;parameters
          (state)
         ;preconditions
          (lambda (state) (member (get-pos-of-0 state) '(0 1 2 3 4 5)))
         ;effects
          (lambda (state) 
             (let ((new-pos-of-0 (+ (get-pos-of-0 state) 3)))
                (switch new-pos-of-0 (get-pos-of-0 state) state)))
         ;cost
           (lambda (state) 1))
  ))


(defun get-all-instances (rule state)
   "returns a list of (successor cost) of result of applying rule to state
   if the precondition of rule holds."
   (if (funcall (get-precond rule) state)
      (list (list (funcall (get-effect rule) state)
            (funcall (get-rule-cost rule) state)))))

;*************************************************************************
;* GET POS of 0
;*************************************************************************
(defun get-pos-of-0 (state)  ;where is the hole ?
    (do ((position 0 (+ position 1)))
         ((= (nth position state) 0) position)))

;*************************************************************************
;* SWITCH
;*************************************************************************
(defun switch (new old state &aux newstate counter)
    ; switch the tile in the newth position with the hole located
    ; in the oldth position of state
    (setq tile (nth new state))
    (setq newstate (subst 9 0 state))
    (setq newstate (subst 0 tile newstate))
    (setq newstate (subst tile 9 newstate)))


;*************************************************************************
;* GOAL - determines whether a state is the goal - change this function
;*        if you wish to search for a different goal state
;*************************************************************************
(defun goal-p (state)
    (equal state '(1 2 3 8 0 4 7 6 5)))

(setq tst1 '(1 2 3 8 6 4 7 0 5))
(setq goal '(1 2 3 8 0 4 7 6 5))
;*************************************************************************
;* PRINT STATE - print out a single state in 8 puzzle format
;*************************************************************************
(defun print-state (st8 &aux counter)
    (terpri)
    (do ((counter '0 (+ counter '3)))
         ((> counter '6))
         (princ (nth counter st8))
         (princ (nth (1+ counter) st8))
         (princ (nth (+ 2 counter) st8))
         (terpri)))

;*************************************************************************
;* WHICH PRI FUNCTION - selecting a priority function to use

;*************************************************************************
(defun which-pri-function ()
   "returns a priority function for evaluation purpose" 
    ;The following four heuristic functions were considered :
    ;   1. h(n) = 0
    ;   2. h(n) = w(n)    number of misplaced tiles
    ;   3. h(n) = p(n)    sum of distances from home
    ;   4. h(n) = p(n) + s(n)   sequence score
    (princ "Heuristic Functions: 1. h(n)=0 ")
    (princ "2. W(n) 3. P(n) 4. P(n)+3(s(n)) ")
    (let ((pri-choice (read)))
       (cond
        ((= pri-choice 1)      ;h(n) = 0
         '(lambda (state) 0))
        ((= pri-choice 2)      ;h(n) = w(n)
         'w-of-n)
        ((= pri-choice 3)      ;h(n) = p(n)
         'p-of-n)
        ((= pri-choice 4)      ;h(n) = p(n) + 3s(n)
         '(lambda (state) (+ (p-of-n state) (* 3 (s-of-n state))))))))

   
;*************************************************************************
;* W-OF-N Heuristic (Number of tile out of position)
;*************************************************************************
(defun w-of-n (state &aux counter) ; compute # tiles out of position
   (setq goalstate '(1 2 3 8 0 4 7 6 5))
   (setq badtiles '0)
   (do (( counter 0 (+ counter 1)))
        ((> counter 8) badtiles)
        (cond
             ((= counter 4))  ;don't care about the hole
             (t
              (cond
                  ((/= (nth counter goalstate) (nth counter state))
                   (setq badtiles (+ badtiles 1)))
                  (t))))))

;*************************************************************************
;* P-OF-N Heuristic (Sum of distances from 'home' position)
;*************************************************************************
(defun p-of-n (state)  ; compute sum of distance from home
    (setq p 0)
    (setq homes '((2 2)(1 1)(1 2)(1 3)(2 3)(3 3)(3 2)(3 1)(2 1)))
    (setq counter3 0)
    (do ((counter1 1 (1+ counter1)))        ; counter1 = current row
         ((= counter1 4) p)
         (do ((counter2 1 (1+ counter2)))   ; counter2 = current col
              ((= counter2 4))
              (setq tile (nth counter3 state)) ;counter3 = current tile
              (setq counter3 (1+ counter3))
              (cond
	          ((= tile 0)) ; don't care about blank
                  (t
                   (setq home (nth tile homes))
                   (setq row (nth 0 home))       ; get correct row & col
                   (setq col (nth 1 home))
                   (setq p (+ p (abs(- row counter1))
                                (abs(- col counter2)))))))))

;*************************************************************************
;* S-OF-N Heuristic (Sequence Score)
;*************************************************************************
(defun s-of-n (state)  ; compute sequence score
    ; This proc returns the seq score by checking pairs of tiles
    ;  located around the non central positions of the puzzle.  We first
    ;  find a tile with which to begin (not the hole).  tile1 and tile2
    ;  correspond to the pair of tiles to be checked.  tile2 should be
    ;  tile1 + 1 except when tile1 is 8 in which tile2 should be 1.
    (setq noncentral '(0 1 2 5 8 7 6 3 0 1))
    (setq s 0)
    (setq pos-of-0 (get-pos-of-0 state))
    (cond
         ; determine where to begin searching and when to stop
         ((= pos-of-0 0)
          (setq initcount 1)(setq finalcount 9))
         (t
          (setq initcount 0)(setq finalcount 8)))
    (setq tile1 (nth (nth initcount noncentral) state))
    (do ((counter (1+ initcount) (1+ counter)))
         ((> counter finalcount) s)
         (setq tile2 (nth (nth counter noncentral) state))
         (cond
              ; is tile2 to right tile?
              ((= tile2 0)
               (setq s (1+ s)))   ; add 1 to s it blank found
              (t
               (setq next (if (= tile1 8) 1 (+ tile1 1)))
               (cond
                   ((/= tile2 next)
                    (setq s (+ 2 s)))  ; add 2 to 2 if not right
                   (t))
               (setq tile1 tile2)))))


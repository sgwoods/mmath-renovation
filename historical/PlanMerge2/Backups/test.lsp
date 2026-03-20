;property list

(defun putp (x y z)
     (setf (get x y ) z))

(defun inc_count (x)
     (putp x 'count
                    (+ 1 (get x 'count))))


; simple logic examples

(defun gte (x y) (or (> x y) (= x y)))
(defun gte1  (x y) (if (or (> x y) (= x y)) 'true! 'false!))

; try this example with '(and x y) to see what it does
(defun me (X) (macroexpand x))

;p : progn
;execute several functions, return value of last one as progn value
; here - the assignment of global variables
(defun p () (progn (setq x 10) (setq y 15) 'reset))

;so : when
; if statement formatting - using when, unless
; when condition holds, execute all expressions following
; execute all expressions unless condition holds

(defun so (x) (when (numberp x) (if (= x 0) 'X=0! nil)))
(defun ro (x) (when (not (numberp x)) 'notnum ))
(defun ro1 (x) (unless (numberp x) 'notnum)) 

; choice
; conditional branch implementation

(defun choice (X)
  (cond ( (not (numberp x)) 'other)
	( (= x 1) 'one)
	( (= x 2) 'two)
	( (> x 2) 'big)
        ( (= x 0) 'zero)
        ( t 'negative) ))

;ck
;simple implementation of a case statement with default

(defun ck (X)
  (case x
	( (1 2 3 4) 'one-four)
	( (5 6 7 8) 'five-eight)
	( (9 10)    'nine-ten)
	( t         'more-than-ten)))

;multi
; return more than one value for a function - here square and cube

(defun multi (x)
  ( values (* x x) (* (* x x) x) ))

;multi 2
; y, z local variables
; values returns whatever as all values of the function

(defun multi2 (x)
  (let* ( (y (* x x)) (z (* (* x x) x)) )
        (values y z)) )

; mvs
; a - local 
; x1, x2 global results of (floor x y)

(defun mvs (x y)
  (let* ( (a (multiple-value-setq (x1 x2) (floor x y))) )
        (values a))  )

;compute
;math on pairs

(defun compute (x y)
       (list
             (- x y)
             (+ x y)
             (* x y)
             (/ x y)))

;give values of a list - define a simple term
(defun vl (X) (values-list x))

;compute 2
;math on pairs
;including a binding for global variables 

(defun compute2 (x y)
       (multiple-value-setq
          (sum diff prod quot)
          (vl (compute x y) ) ) )

; solves quadratic equation : ie x^2 + bx + c  = 0
; (qe -3 2) gives 2.0  1.0 as the roots - ie (x-2)(x-1) = x^2 -3x + 2 =0
; based on the formula
; root = b^2 - 4c; if root = 0 then return -b/2, else
;                              else return (root - b)/2 ; (-b - root)/2    

(defun qe (b c)
       (let ((root (sqrt (- (* b b)
                            (* 4 c)))))
            (if (zerop root)
                (/ (- b) 2)
                (values (/ (+ (- b) root) 2)
                        (/ (- (- b) root) 2))))) 

;my own attempt at factorial
(defun f (x)
    (if (= x 1) 1 (* x (f (- x 1)))))

;list length by me
(defun strl (x)
     (if (not (cdr x)) 1 (+ 1 (strl (cdr x)))))

;block controls :
(defun blk (x)
   (block here
      (print "entered a: ") 
      (print x)
      (when (numberp x)
         (print "plus 1 is: ")
         (return-from here (+ 1 x)))
      (print "not a number")
      (list x x)))

;loop construction
(defun loopy (x)
   ( let ((z 1)) )
   (loop
     (setq z (+ 1 z))
     (print "looping")
     (print x)
     (print z)
     (when (> z x) 
        (return-from nil))))
        


    
;ugly, but look at gotos and labels
; a should never be executed
(defun gone (X)
     (if (= x 1) (go b) (go c))
  a  (quote 0)  
  b  (quote 1)
  c  (quote 2)) 

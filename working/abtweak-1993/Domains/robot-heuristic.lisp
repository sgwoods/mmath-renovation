;;; heuristic function that takes into account the total number of 
;;; unachieved preconditions that are above or on 
;;; the current level of abstraction, and removes cycles in the robot domain. 


(defvar *check-loop* t)
(declaim (ftype function goto-twice-p push-twice-p push-door-twice-p
                go-door-twice-p))

(defun user-heuristic ()
 "Returns a heuristic function.
  Num unsatisfied goals +
  100000 if a cycle occurs.
 
  It is in /Abtweak/Domains/simple-robot(1 or 2).lsp"

 #'(lambda (plan)
    (+
     (num-of-unsat-goals plan)
     (if (and *check-loop* 
	      (or (goto-twice-p plan)
		  (push-twice-p plan)
		  (push-door-twice-p plan)
		  (go-door-twice-p plan)))
	 (let () 
	   ;(break "Name1=~S ~% Name2= ~S~%" 
	      ;    (operator-name (first (plan-a plan)))
	       ;   (operator-name (second (plan-a plan))))
	   1000000)
       0))))

(defun goto-twice-p (plan)
  "t iff goto-room-loc twice in a row, in the same room."
  (let* ((ops (plan-a plan))
           (name1 (operator-name (car ops)))
           (name2 (operator-name (car (rest ops)))))
	(and    (eq (first name1) 'goto-room-loc)
		(eq (first name2) 'goto-room-loc))
		(eq (last name1) (last name2)) ))

(defun push-twice-p (plan)
 "t iff push box in same room twice."

  (let* ((ops (plan-a plan))
           (name1 (operator-name (car ops)))
           (name2 (operator-name (car (rest ops)))))
	(and   (eq (first name1) 'push-box)
		(eq (first name2) 'push-box)
		(eq (second name1) (second name2))
		(eq (third name1) (third name2)))))

(defun push-door-twice-p (plan)
 "t iff push box in same door twice."

  (let* ((ops (plan-a plan))
           (name1 (operator-name (car ops)))
           (name2 (operator-name (car (rest ops)))))
	(and   (eq (first name1) 'push-thru-dr)
		(eq (first name2) 'push-thru-dr)
		(eq (second name1) (second name2))
		(eq (third name1) (third name2)))))

(defun go-door-twice-p (plan)
 "t iff go thru in same door twice."

  (let* ((ops (plan-a plan))
           (name1 (operator-name (car ops)))
           (name2 (operator-name (car (rest ops)))))
	(and   (eq (first name1) 'go-thru-dr)
		(eq (first name2) 'go-thru-dr)
		(eq (second name1) (second name2)))))
		

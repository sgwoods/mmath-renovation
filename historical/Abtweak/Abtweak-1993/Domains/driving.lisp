;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; A driving navigation domain (contributed by Mark Peot to illustrate a bug)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun road-operators ()
  (reset-domain)
  (defstep :action '(drive ?vehicle ?location1 ?location2)
    :precond '((at ?vehicle ?location1) (road ?location1 ?location2))
    :dele '((at ?vehicle ?location1))
    :add '((at ?vehicle ?location2)))
  (defstep :action '(cross ?vehicle ?location1 ?location2)
    :precond '((at ?vehicle ?location1) (bridge ?location1 ?location2))
    :dele '((at ?vehicle ?location1))
    :add '((at ?vehicle ?location2))))

(defvar *roads* nil)

(defun add-road (a b)
  (push `(road ,a ,b) *roads*)
  (push `(road ,b ,a) *roads*))

(defun add-bridge (a b)
  (push `(bridge ,a ,b) *roads*)
  (push `(bridge ,b ,a) *roads*))

(defun road-map () *roads*)

(defun find-path (starting-location goal)
  (plan `(,@(road-map) ,@starting-location)
	goal))

(defun test3 ()
  (road-operators)
  (setf *roads* nil)
  (add-bridge 'a 'd)
  (add-road 'd 'g)
  (time (find-path '((at jack a) (at mark a))
                   '((at jack g) (at mark g)))))



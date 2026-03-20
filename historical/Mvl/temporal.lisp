;;; -*- Mode: LISP; Syntax: Common-lisp; Package: MVL; Base: 10 -*-

(in-package "MVL")

(defun time-dag-dot (t1 t2)
  (list (max t1 t2)))

(defvar *active-bilattice*)

(defun time-dag ()
  (first (bilattice-components *active-bilattice*)))

(defparameter *time-dag*
	      (make-dag :root 0 :eq #'= :dot #'time-dag-dot
			:long "Temporal order" :short "Time"))

(defun time-base-bilattice ()
  (second (bilattice-components *active-bilattice*)))

(defparameter *time-base-bilattice*
	      (lattice-to-dag-to-bilattice *first-order-atms-lattice*
					   *first-order-bilattice*))

(defun true-at (time &aux (dag (time-dag)) (b (time-base-bilattice))
			  (ans (make-tv dag b time (bilattice-true b))))
  (add-dag (1+ time) (bilattice-unknown b) ans)
  ans)

(defun delay (time v)
  (dag-change-dag v #'(lambda (x) (+ x time))))

(defparameter *delay*
    (make-modal-operator :name 'delay :function #'delay :parameters '(t)))

(defun propagate (fn)
  (dag-remove-unknown fn))

(defparameter *propagate*
    (make-modal-operator :name 'propagate :function #'propagate))

(defun extract-value (plan fn)
  (make-root (time-dag) (time-base-bilattice) (get-val plan fn)))

(defparameter *extract-value*
    (make-modal-operator :name 'at :function #'extract-value 
			 :parameters '(t)))

(defparameter *time-bilattice* 
    (dag-bilattice *time-dag* *time-base-bilattice*))

(bilattice-has-modal-operator *time-bilattice* *delay*)
(bilattice-has-modal-operator *time-bilattice* *propagate*)
(bilattice-has-modal-operator *time-bilattice* *extract-value*)

(describe-bilattice *time-bilattice* "Temporal reasoning" "Temporal" #\t)

(bilattice *time-bilattice*)

(defparameter *quick-time-bilattice* 
    (dag-bilattice *time-dag* *first-order-bilattice*))

(bilattice-has-modal-operator *quick-time-bilattice* *delay*)
(bilattice-has-modal-operator *quick-time-bilattice* *propagate*)
(bilattice-has-modal-operator *quick-time-bilattice* *extract-value*)

(describe-bilattice *quick-time-bilattice*
		    "Cheap temporal reasoning" "Temporal (quick)" #\q)

(bilattice *quick-time-bilattice*)
;;; -*- Mode: LISP; Syntax: Common-lisp; Package: MVL; Base: 10 -*-

(in-package "MVL")

;; Diagnostic stuff for top-level proving

;; global variables defined:
;; 
;; *bc-trace* *anytime-trace*	control display of diagnostics
;; *show-truth-values*		indicate every time a truth value is recomputed

(defparameter *bc-trace* nil)
(defparameter *anytime-trace* nil)
(defparameter *show-truth-values* t)

;; bc-trace and bc-untrace.  These guys are basically like trace and
;; untrace; they modify *bc-trace* and *anytime-trace*.  The first of
;; these is a list of patterns; any task that deals with an instance of
;; this pattern is displayed.  The second is used only on inference
;; tasks and is more appropriate to see the fashion in which the prover
;; is accumulating answers, as opposed to for debugging purposes.  If
;; invoked with no argument, all of the functions default to tracing or
;; untracing everything.

(defun bc-trace (&optional (pat '(?*)))
  (add-trace '*bc-trace* pat))

(defun add-trace (symbol pat)
  (set symbol (cons pat (remove-trace symbol pat)))
  'done)

(defun remove-trace (symbol pat)
  (set symbol (remove-if #'(lambda (x) (instp pat x)) (eval symbol))))

(defun bc-untrace (&optional (pat '(?*)))
  (remove-trace '*bc-trace* pat))

(defun anytime-trace (&optional (pat '(?*)))
  (add-trace '*anytime-trace* pat)
  'done)

(defun anytime-untrace (&optional (pat '(?*)))
  (remove-trace '*anytime-trace* pat))

;; Output a diagnostic message about a given task.  If the task is
;; traced, call format.

(defconstant *prop* (list nil))
(defconstant *value* (list nil))
(defconstant *task* (list nil)) 

(defun task-diagnostic (task &rest args)
  (setq args (subst (consider-prop task) *prop*
		    (subst (mvl-print (consider-truth-value task)
				      bdg-to-truth-val)
			   *value* 
			   (subst task *task* args))))
  (when (traced-task task)
    (format t #+ANSI "~%~@<~a~1I~{~:_ ~a~}~:>."
	      #-ANSI "~%~a~{~<~%~:; ~a~>~}."
	      (car args) (cdr args))))

;; Is a task traced?  Just use *bc-trace* and *anytime-trace* as above.

(defun traced-task (task &optional (prop (consider-prop task)))
  (or (and *bc-trace* (traced-prop prop *bc-trace*))
      (and *anytime-trace* (inference-p task)
	   (traced-prop prop *anytime-trace*))))

(defun traced-prop (prop trace)
  (some #'(lambda (x) (instp x prop)) trace))

;; Report that a task has had its truth value set to a new value.

(defun show-truth-value (task)
  (when *show-truth-values*
    (task-diagnostic task "Truth value of" *task* "set to" *value*)))


;;; -*- Mode: LISP; Syntax: Common-lisp; Package: MVL; Base: 10 -*-

(in-package "MVL")

;;; Allegro MVL interface 

(defvar *fi-stash-value* nil)
(defvar *fi-stash-function* nil)

;; For state, get a form.  If it's eof, fine.  If :empty, fine.  If
;; :value or :function, set the global variables that are keeping track
;; of tese things to the appropriate values.  Otherwise, just state the
;; given thing with value/function as appropriate.

(defmacro state-hook (&rest args)
  `(state-hook-1 ',args))

(defun state-hook-1 (args)
  (do (ans)
      ((null args) 'done)
    (setq ans (pop args))
    (cond ((eq ans ':empty) (empty))
	  ((eq ans ':value)
	   (if args (setq *fi-stash-value* (pop args) *fi-stash-function* nil)
	     (error "Unexpected end of region during mvl-state")))
	  ((eq ans ':function)
	   (if args (setq *fi-stash-function* (pop args) *fi-stash-value* nil)
	     (error "Unexpected end of region during mvl-state")))
	  (*fi-stash-value* (eval `(state ',ans :value ,*fi-stash-value*)))
	  (t (eval `(state ',ans :function ,*fi-stash-function*))))))

;; unstate is similar, but we ignore :empty (obviously!) and :value and
;; :function (except these last two have to pull a form off the region)

(defmacro unstate-hook (&rest args)
  `(unstate-hook-1 ',args))

(defun unstate-hook-1 (args)
  (do (ans)
      ((null args) 'done)
    (setq ans (pop args))
    (cond ((eq ans ':empty))
	  ((eq ans ':value)
	   (if args (pop args)
	     (error "Unexpected end of region during mvl-unstate")))
	  ((eq ans ':function)
	   (if args (pop args)
	     (error "Unexpected end of region during mvl-unstate")))
	  (t (eval `(unstate ',ans))))))

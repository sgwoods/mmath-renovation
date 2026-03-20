;;; -*- Mode: LISP; Syntax: Zetalisp; Package: ZWEI; Base: 10 -*-

;;; Zwei MVL interface 

(defvar *zweimvl-stash-value* nil)
(defvar *zweimvl-stash-function* nil)

(defcom com-state-mvl
	"States forms in the region, or if no region is defined, the current definition.
It shows the result in the echo area.  " ()
  (compile-definition-internal  (get-buffer-evaluator *interval*)
			   "Evaluating"
			   "evaluated."
			   ':prompt nil #'state-hook)
  dis-none)

(defcom com-unstate-mvl
	"Unstates forms in the region, or if no region is defined, the current definition.
It shows the result in the echo area.  " ()
  (compile-definition-internal  (get-buffer-evaluator *interval*)
			   "Evaluating"
			   "evaluated."
			   ':prompt nil #'unstate-hook)
  dis-none)

(defcom com-fc-mvl
	"Forward chains on forms in the region, or if no region is defined, the current definition.
It shows the result in the echo area.  " ()
  (compile-definition-internal  (get-buffer-evaluator *interval*)
			   "Evaluating"
			   "evaluated."
			   ':prompt nil #'fc-hook)
  dis-none)

(defcom com-erase-mvl
	"Erases forms in  the region, or if no region is defined, the current definition.
It shows the result in the echo area.  " ()
  (compile-definition-internal  (get-buffer-evaluator *interval*)
			   "Evaluating"
			   "evaluated."
			   ':prompt nil #'erase-hook)
  dis-none)

;; For state, get a form.  If it's eof, fine.  If :empty, fine.  If
;; :value or :function, set the global variables that are keeping track
;; of tese things to the appropriate values.  Otherwise, just state the
;; given thing with value/function as appropriate.

(defun state-hook (keyword &optional fn/stream form/eof ignore)
  (cl:ccase keyword
    (:process-form
      (funcall fn/stream form/eof))
    (:read
      (let ((ans (read fn/stream 'eof-flag)))
	(cond ((eq ans 'eof-flag) form/eof)
	      ((eq ans ':empty) '(mvl:empty))
	      ((eq ans ':value) (setq *zweimvl-stash-value* (read fn/stream nil)
				      *zweimvl-stash-function* nil))
	      ((eq ans ':function) (setq *zweimvl-stash-function* (read fn/stream nil)
					 *zweimvl-stash-value* nil))
	      (*zweimvl-stash-value*
	       `(mvl:state (quote ,ans) :value ,*zweimvl-stash-value*))
	      (t `(mvl:state (quote ,ans) :function ,*zweimvl-stash-function*)))))))

;; unstate is similar, but we ignore :empty (obviously!) and :value and
;; :function (except these last two have to pull a form off the region)

(defun unstate-hook (keyword &optional fn/stream form/eof ignore)
  (cl:ccase keyword
    (:process-form
      (funcall fn/stream form/eof))
    (:read
      (let ((ans (read fn/stream 'eof-flag)))
	(cond ((eq ans 'eof-flag) form/eof)
	      ((eq ans ':empty) '(mvl:empty))
	      ((eq ans ':value) (read fn/stream nil) nil)
	      ((eq ans ':function) (read fn/stream nil) nil)
	      (t `(mvl:unstate (quote ,ans))))))))

;; forward chaining.  Ignore :function (but read a form)

(defun fc-hook (keyword &optional fn/stream form/eof ignore)
  (cl:ccase keyword
    (:process-form
      (funcall fn/stream form/eof))
    (:read
      (let ((ans (read fn/stream 'eof-flag)))
	(cond ((eq ans 'eof-flag) form/eof)
	      ((eq ans ':empty) '(mvl:empty))
	      ((eq ans ':value) (setq *zweimvl-stash-value* (read fn/stream nil)))
	      (*zweimvl-stash-value* `(mvl:fc (quote ,ans) :value ,*zweimvl-stash-value*))
	      (t `(mvl:fc (quote ,ans))))))))

;; erase.  Like unstate.

(defun erase-hook (keyword &optional fn/stream form/eof ignore)
  (cl:ccase keyword
    (:process-form
      (funcall fn/stream form/eof))
    (:read
      (let ((ans (read fn/stream 'eof-flag)))
	(cond ((eq ans 'eof-flag) form/eof)
	      ((eq ans ':empty) '(mvl:empty))
	      ((eq ans ':value) (read fn/stream nil) nil)
	      (t `(mvl:erase (quote ,ans))))))))

(defflavor mvl-mode () (lisp-syntax-mode-forms-mixin lisp-language-mixin major-mode))

(defmethod (:mode-forms mvl-mode) ()
  `((set-comtab *mode-comtab*
		'(#\super-s com-state-mvl
		  #\super-u com-unstate-mvl
		  #\super-f com-fc-mvl
		  #\super-e com-erase-mvl
		  ))))

(defmode com-mvl-mode mvl-mode "Sets things up for editing MVL forms." :mvl)

(set-comtab *zmacs-comtab*
	    ()
	    (make-command-alist '(com-mvl-mode)))

(push '(:mvl :mvl) fs:*file-type-mode-alist*)

;;; -*- Syntax: Zetalisp; MODE: Lisp; Package: System-internals; Base: 8 -*-

;; set up super-A to do an MVL "apropos", typing out any information
;; about the current relation.  Kludged together by looking at the
;; symbolics code that handles ctrl-A.

(defun-ie ie-find-predicate (include-package-prefix? barf?)
  (let* ((*syntax-table* 'zwei:*atom-word-syntax-table*))
    (multiple-value-bind (begin found-p)
	(ie-apply-zwei-bp-function #'zwei:forward-up-list-or-string
	      (ieb-typein-pointer) -1)
      (when (and (not found-p) barf?) (ie-barf))
      (setq begin (ie-search-forward-alphabetic begin))
      (unless include-package-prefix?
	(let ((package-index (ie-search-forward (lambda (c) (char-equal c #/:)) begin :nil)))
	  (if package-index (setq begin (1+ package-index)))))
      (values begin (ie-search-forward-non-alphabetic begin)))))

(defun-ie ie-relevant-pred (print-function &rest print-args)
  (multiple-value-bind (begin end)
      (ie-find-predicate t t)
    (let ((symbol
	    (condition-case ()
		(let ((package *input-editor-package*))
		  (ie-read-from-buffer begin end 'intern-soft))
	      (sys:read-error (ie-barf)))))
      (cond ((not (symbolp symbol))
	     (ie-barf))
	    ((null symbol)
	     (setq symbol (ie-read-from-buffer begin end 'make-symbol))
	     (setf (symbol-package symbol) package)))
      (ie-display-info (ignore ignore symbol print-function print-args)
	(lexpr-funcall print-function symbol self print-args)))))

(define-ie-command describe-pred (#\super-shift-a)
  (ie-relevant-pred
    #'(lambda (symbol zwei:*typein-window*)
	(let ((zwei:*typeout-window* zwei:*typein-window*))
	  (dolist (item (mvl:prfacts symbol :stream nil))
	    (when item (zwei:typein-line item))))
	t)))

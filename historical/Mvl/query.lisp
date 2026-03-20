;;; -*- Mode: LISP; Syntax: Common-lisp; Package: MVL; Base: 10 -*-

(in-package "MVL")

;; The function query.

;; This is a Common Lisp implementation of a query function that is
;; similar, but less complex, than the Symbolics Common Lisp function
;; fquery.  Its syntax is as follows:

;; query stream
;;       (&key (:list-choices t) (:fresh-line t) (:clear-input nil))
;;       choices
;;       &optional
;;       prompt
;;       &rest
;;       prompt-args

;; The argument stream must be either t, nil, or a stream.  If t, the
;; value of *query-io* is used; if nil, the value of *terminal-io*.

;; There are three keyword options.

;;   :list-choices -- If non-nil, the default, then the valid inputs
;;   are listed following the prompt (if any); if nil, no list is
;;   supplied.

;;   :fresh-line -- If non-nil, the default, then a fresh-line
;;   operation is performed before issuing the query; if nil, no
;;   fresh-line is performed.

;;   :clear-input -- If non-nil, a clear-input operation is
;;   performed on the chosen stream before issuing the query; if nil,
;;   the default, no such operation is performed.  This option is
;;   useful if the user may not be expecting the query.

;; If the user enters an invalid input, then the query is reissued with
;; all three options set to t.

;; The argument choices is a list, each element of which is called a
;; choice; see below for the format of a choice.  Each choice lists a
;; set of valid inputs and specifies a value to be returned when the
;; user's response matches some element of the set.

;; When supplied, the argument prompt and any prompt-args are passed to
;; the format function to generate the prompt.  If prompt is nil or
;; missing, no prompt is generated, although the choices will still be
;; listed if :list-choices is non-nil.

;; Format of a choice: The user must type one or more characters followed by
;; #\Return.  The response need not be exact, but must only match the
;; initial sequence of characters of some valid input (the match is not
;; case sensitive).  Each choice must have the following format:

;;   (value echo-string &rest string-inputs)

;; where each of the string-inputs is a string.  The optional second
;; argument is echoed when the option is selected.

;; The query macro.

(defmacro query (stream
		 (&key (list-choices t) (fresh-line t) (clear-input nil))
		 choices &optional prompt &rest prompt-args)
  `(query-internal ,(cond ((eq stream t) '*query-io*)
			  ((eq stream nil) '*terminal-io*)
			  (t stream))
		   ,list-choices
		   ,fresh-line
		   ,clear-input
		   ,choices
		   ,prompt
		   ,@prompt-args))

;; Internals.

(defun query-internal (stream list-choices fresh-line clear-input choices 
		       prompt &rest prompt-args)
  (check-type stream stream)
  (check-type prompt (or string null))					
  (multiple-value-bind (primary-choices input-sets echoes values)
      (parse-choices choices)
    (loop
      (when clear-input (clear-input stream))
      (when fresh-line (fresh-line stream))
      (when prompt (apply #'format stream prompt prompt-args))
      (when list-choices (write-string primary-choices stream))
      (multiple-value-bind (successp value)
	  (read-string-response stream input-sets echoes values)
	(when successp (return value)))
      (setq clear-input t fresh-line t list-choices t))))	;re-query

;; Returns four values: the primary inputs, all valid
;; inputs, the echo strings, and the return values.

(defun parse-choices (choices)
  (values (format nil "(~{~#[~;~A~;~A or ~A~:;~A, ~]~}) "
		  (mapcar #'third choices))
	  (mapcar #'cddr choices)
	  (mapcar #'second choices)
	  (mapcar #'first choices)))

(defun read-string-response (stream input-sets echoes values)
  (flet ((initial-subseq-equal-p (sequence-1 sequence-2)
	   (eql 0 (search sequence-1 sequence-2 :test #'char-equal))))
    (let* ((response (read-line stream))
	   (index (dotimes (n (length input-sets) nil)
		    (when (find response (nth n input-sets)
				:test #'initial-subseq-equal-p)
		      (return n)))))
      (when index
	(when (nth index echoes) (write-string (nth index echoes) stream))
	(values t (nth index values))))))

(pushnew :query *features*)
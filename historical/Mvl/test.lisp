;;; -*- Mode: LISP; Syntax: Common-lisp; Package: MVL; Base: 10 -*-

(in-package "MVL")

;;; This function reads forms from the file whose name is in inf and
;;; prints errors on the terminal.  When done, the function returns the
;;; total number of errors and exits.

;; The format of the test file is as follows:
;; 
;; <exp-1>
;; <value-returned-1>
;; 
;; <exp-2>
;; <value-returned-2>
;; 
;; 	.
;; 	.
;; 	.
;; 
;; <exp-n>
;; <value-returned-n>
;; 
;; The expressions are evaluated and the values returned are compared to
;; the <value-returned-i>, where ** is used as a wildcard in
;; <value-returned-i>.
;; 
;; As an example, see the file "mvl:mvl;mvl.test", which is used by the
;; function (test-mvl) to test the entire mvl system.

;; The idea is to use the ANSI form ignore-errors to avoid croaking
;; if an error is encountered.  (And checking the second value to see
;; if an error occurred.)  So we need to define that ...

#-ANSI (defun ignore-errors (value) value)

;; here it is.  Some preliminary junk, then read an expression; if EOF,
;; return the number of errors.  Otherwise, get the next expression; if
;; it's EOF, warn the user about the unexpected EOF and return.

;; If you have an expression and an expected value, evaluate the
;; expression and check to see if the answer is as expected.

(defun mvl-test-file (inf &key description (fail-on-error t)
		      &aux (file (mvl-file inf "test")))
  (when description (format t "~%Testing ~a." description))
  (when file
    (with-open-file (in file)
      (do (test expect actual error match (n 0))
	  (nil)
	(cond ((eq 'stop (setq test (read in nil 'stop)))
	       (return n))
	      ((eq 'stop (setq expect (read in nil 'stop)))
	       (warn "~%Early end of file for ~a.~%" inf)
	       (return n))
	      (t (if fail-on-error (setq actual (eval test))
		   (multiple-value-setq (actual error)
		     (ignore-errors (values (eval test)))))
		 (cond ((or (eq actual '*error*) error)
			(incf n)
			(format t "~%~a - ~s: ERROR" inf test)
			(return '*error*))
		       (t (if fail-on-error
			      (setq match (test-match expect actual))
			    (multiple-value-setq (match error)
			      (ignore-errors (test-match expect actual))))
			  (cond (error
				 (incf n)
				 (format t "~%~a - ~s:~@
                                            Error in match between ~a and ~a"
					 inf test actual expect)
				 (return '*error*))
				((not match)
				 (incf n)
				 (format t "~%~a - ~s~%~a not ~a"
					 inf test actual expect)))))))))))

;; Check to see if two expressions match.  e1 is what you expected; e2
;; is what you computed.

;; If e1 is ** (the wildcard), just succeed.  If the two expressions
;; are equal or equal-answers, you can also succeed.  Finally, if they 
;; are both lists, invoke test-match recursively.

(defun test-match (e1 e2)
  (cond ((eq e1 '**))
	((equalp e1 e2))
	((equal-answer e1 e2))
	((and (listp e1) (listp e2))
	 (and (test-match (car e1) (car e2)) (test-match (cdr e1) (cdr e2))))))

;; test-mvl invokes mvl-test-file on the file "mvl" and returns only the
;; first value (the number of errors).

(defun test-mvl ()
  (with-mvl-invocation ()
    (time (prog1 (mvl-test-file "mvl" :fail-on-error nil)
	    (format t "~2%")))))

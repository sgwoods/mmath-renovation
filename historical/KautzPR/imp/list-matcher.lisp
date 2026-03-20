;;; -*- Syntax: Common-lisp; Package: USER -*-
;;; Copyright 1987 by Henry A. Kautz
;;; No warranty as to the correctness or usefulness of this software
;;; is given or implied.
;;;
;;; The author may be contacted at the following addresses:
;;; :uucp:	allegra!kautz		
;;; :arpa: or :csnet:	kautz@research.att.com
;;; :old style csnet: 	kautz%allegra@btl.csnet
;;; :mail:	AT&T Bell Laboratories	
;;;		Room 2C-407
;;;		600 Mountain Ave.	
;;;		Murray Hill, N.J. 07974	

;; Matcher only works on simple lists; it does not match recursively on elements
;; (must be equalp).
;; Forms of patterns:
;;   ? -- matches any single element
;;   (? variable restrict1 ...) -- matches single element 
;;      on which 0 or more restriction
;;      functions return non-nil, and assigns to variable.
;;   * -- matches subsequence
;;   (* restrict1 ...) -- matches subsequence on
;;      each member of which 0 or more restriction
;;      functions return non-nil
;;   (- term1 term2 ...) -- matches nothing or one of terms
;;       Note that terms are NOT arbitrary patterns!
;;   (+ term1 term2 ...) -- matches one of terms
;;   (+? var term1 term2 ...) -- matches one of terms, assigns to var
;;   (!? var term1 term2 ...) -- matches none of terms, assigns to var
;;   (?= var var ...) -- matches exactly one term, which must be a 
;;       number, and assigns its value to all of the variables.
;;   (!* term1 term2 ...) -- matches any sequence not containing any
;;   of the terms
(defun not-null (e) 
   (not (null e)))

(defun match-list (p d)
   "match pattern p against list d"
   (cond
      ((and (null p) (null d)) t)
      ((null p) nil)
      ((eq (car p) '*)
	 (or
	    (null (cdr p))
	    (match-list (cdr p) d)
	    (and (not-null d) (match-list p (cdr d)))))
      ((eq (car p) '?)
	 (and (not-null d) (match-list (cdr p) (cdr d))))
      ((not (listp (car p)))
	 (and 
	    (not-null d)
	    (eql (car p) (car d))
	    (match-list (cdr p) (cdr d))))
      ((eq (caar p) '!*)
	 (or 
	    (match-list (cdr p) d)
	    (and
	       (not-null d)
	       (not (member (car d) (cdar p)))
	       (match-list p (cdr d)))))
      ((eq (caar p) '-)
	 (or 
	    (and 
	       (not-null d)
	       (some #'(lambda (w) (equalp w (car d))) (cdar p))
	       (match-list (cdr p) (cdr d)))
	    (match-list (cdr p) d)))
      ((equal (caar p) '*)
	 (or 
	    (match-list (cdr p) d)
	    (and 
	       (not-null d)
	       (every #'(lambda (f) (funcall f (car d))) (cdar p))
	       (match-list p (cdr d)))))
      ((null d) nil)
      ((eq (caar p) '+)
	 (and 
	    (some #'(lambda (w) (equalp w (car d))) (cdar p))
	    (match-list (cdr p) (cdr d))))
      ((eq (caar p) '?)
	 (cond ((and 
		   (every #'(lambda (f) (funcall f (car d))) (cddar p))
		   (match-list (cdr p) (cdr d)))
		  (set (cadar p) (car d))
		  t)))
      ((eq (caar p) '?=)
	 (cond ((and (numberp (car d))
		   (match-list (cdr p) (cdr d)))
		  (mapc #'(lambda (v) (set v (car d))) (cdar p))
		  t)))
      ((eq (caar p) '+?)
	 (cond ((and 
		   (member (car d) (cddar p))
		   (match-list (cdr p) (cdr d)))
		  (set (cadar p) (car d))
		  t)))
      ((eq (caar p) '!?)
	 (cond ((and 
		   (not (member (car d) (cddar p)))
		   (match-list (cdr p) (cdr d)))
		  (set (cadar p) (car d))
		  t)))
      ))



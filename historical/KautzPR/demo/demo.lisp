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
 
(defvar *operating-system* 'unix "set to unix, mac, or symbolics")

(defun substitute-string (old new s &aux match)
  "replace first occurrence of substring old by new in s if any"
  (setq match (search old s))
  (if match
    (concatenate 'string (subseq s 0 match) new 
       (subseq s (+ match (length old))))
    s)
  )
  

(defun translate-pathname (filename)
  "Convert a unix-style filename into a path, converting / separators to : on
   the macintosh, and making other adjustments as needed"
  (case *operating-system*
    ((mac)
     (setq filename (substitute-string "/usr/kautz/lisp" 
       "hard disk 40:user:henry:henry's programs:henry's lisp folder"
       filename))
     (setq filename (substitute #\: #\/ filename)))
    )
  (pathname filename))

(defun mac-demo ()
  "(Mac only) Run demo on a file chosen by a dialog box"
  (setq *operating-system* 'mac)
  (demo (choose-file-dialog)))

(defvar exit 'exit)

(defun demo (filename)
   "this program demos files"
  (let (com-string do-this c)
    (with-open-file (file filename)
      (format t "~%")
      (prog ()
	 top-of-loop
	  (do () ((not (member (setq c (peek-char nil file nil 'exit))
			  '(#\space #\return #\newline #\;))))
	    (if (eql c #\;)
		(write-line (read-line file nil #\space))
		(write-char (read-char file))
		)
	    )
	  (if (eql c 'exit) (return-from demo))
	  (setq do-this (read file nil 'exit))
	  (if (eql do-this 'exit) (return-from demo))
	 print-command
	  (format t "~%Command: ~S" do-this)
	  
	  (do () ((member (setq com-string (read-line)) 
		     '("" " " "y" "n" "q" "e") :test #'equal))
	     (format t "Huh? Enter <cr>, y, n, q, or e: "))
	  (cond
	     ((equal com-string "e") 
		(format t "Enter expression: ")
		(format t "~%  ~A" (eval (read)))
		(go print-command))
	     ((member com-string '("" "y") :test #'equal)
		(format t "~%~{  ~A~%~}"
		   (multiple-value-list (eval do-this)))
		)
	    ((equal com-string "n")
		nil
		)
	    ((equal com-string "q")
		(return-from demo)
		)
	    (t
		(error "program error")
		)
	     )
	 (go top-of-loop)
	 )
       )
     )
   )

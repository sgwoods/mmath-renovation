;;; -*- Syntax: Common-lisp; Package: USER -*-
;;; Copyright 1987 by Henry A. Kautz
;;; No warranty as to the correctness or usefulness of this software
;;; is given or implied.
;;;
;;; The author may be contacted at the following addresses:
;;; :uucp:	allegra!kautz		
;;; :arpa: or :csnet:	kautz@allegra.att.com
;;; :old style csnet: 	kautz%allegra@btl.csnet
;;; :mail:	AT&T Bell Laboratories	
;;;		Room 3C-402A
;;;		600 Mountain Ave.	
;;;		Murray Hill, N.J. 07974	


;;;; file system test
;;;;    demonstrates equality constraints and 
;;;;    multiple events

(frame
    '(rename
	 (direct-abstr end)
	 (params old new)
	 (times time)
	 
	 )
    )

(frame
    '(rename-by-move
	 (direct-abstr rename)
	 (params old new)
	 (times time)
	 (steps (move move-step))
	 (eq-constraints
	     (old (move-step old))
	     (new (move-step new))
	     )
	 (time-constraints
	     (time equals (move-step time))
	     )
	 
	 )
    )

(frame
    '(rename-by-copy
	 (direct-abstr rename)
	 (params old new)
	 (times time)
	 (steps (copy copy-orig-step) (delete delete-orig-step))
	 (eq-constraints
	     (old (copy-orig-step old))
	     (new (copy-orig-step new))
	     (old (delete-orig-step file))
	     )
	 (time-constraints
	     (time contains (copy-orig-step time))
	     (time contains (delete-orig-step time))
	     ((copy-orig-step time) beforeMeet (delete-orig-step time))
	     )
	 
	 )
    )

(frame
    '(modify
	 (direct-abstr end)
	 (params file)
	 (times time t1 t2 t3)
	 (steps (copy backup-step) (edit edit-step) (delete delete-backup-step))
	 (eq-constraints
	     ((backup-step old) file)
	     ((edit-step file) file)
	     ((delete-backup-step file) (backup-step new))
	     )
	 (time-constraints
	     (t1 equals (backup-step time))
	     (t2 equals (edit-step time))
	     (t3 equals (delete-backup-step time))
	     (time contains t1)
	     (time contains t2)
	     (time contains t3)
	     (t1 beforeMeet t2)
	     (t2 beforeMeet t3)
	     )
	 
	 )
    )

(frame
    '(copy
	 (direct-abstr any)
	 (params old new)
	 (times time)
	 )
    )

(frame
    '(delete
	 (direct-abstr any)
	 (params file)
	 (times time)
	 )
    )

(frame
    '(move
	 (direct-abstr any)
	 (params old new)
	 (times time)
	 )
    )

(frame
    '(edit
	 (direct-abstr any)
	 (params file)
	 (times time)
	 )
    )

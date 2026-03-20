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


;;;; hunt rob test
;;;;    demonstrates event minimization
;;;;    example from chapter 1 introduction

(frame
   '(any
       (params agent)
       )
   )

(frame
   '(end
       (direct-abstr any)
       (eq-constraints
	  (agent (s1 agent))
	  (agent (s2 agent)))
       )
   )

(frame
    '(hunt
	(direct-abstr end)
	(steps (go-to-woods s2) (get-gun s1))
	)
    )

(frame
    '(rob-bank
	(direct-abstr end)
	(steps (go-to-bank s2) (get-gun s1))
	 )
    )

(frame
    '(cash-check
	(direct-abstr end)
	(steps (stand-in-line s2) (go-to-bank s1))
	 )
    )

(frame
    '(go-to-woods
	 (direct-abstr any)
	 )
    )

(frame
    '(get-gun
	 (direct-abstr any)
	 )
    )

(frame
    '(go-to-bank
	 (direct-abstr any)
	 )
    )

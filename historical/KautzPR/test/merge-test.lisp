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


;;;; test two-level merge in upward inference and matching

(frame
    `(A
	(direct-abstr end)
	
	)
    )

(frame
    `(B
	(direct-abstr A)
	
	(steps (D s1))
	)
    )

(frame
    `(C
	(direct-abstr A)
	
	(steps (D s1))
	)
    )

(frame
    `(D
	(direct-abstr any)
	)
    )

(frame
    `(E
	(direct-abstr D)
	
	(steps (H s1))
	)
    )

(frame
    `(F
	(direct-abstr D)
	
	(steps (H s1) (K s2))
	)
    )

(frame
    `(G
	(direct-abstr D)
	
	(steps (K s2))
	)
    )

(frame
    `(H
	(direct-abstr any)
	)
    )

(frame
    `(K
	 (direct-abstr any)
	 )
    )

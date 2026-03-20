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


;;;; cook test 2
;;;;    more complete cooking hierarchy
;;;;    as described in chapters 2 and 3

(frame
    '(non-end
	 (params agent)
	 (times time)
	 )
    )

(frame
   '(prepare-meal
	(direct-abstr end)
	(params agent)
	(times time)
	(fact-constraints
	    (inKitchen time agent)
	    )
	)
   )

(frame
   '(make-pasta-dish
       (direct-abstr prepare-meal)
       (steps (make-noodles s1) (make-sauce s2) (boil s3))
       (eq-constraints
	  (agent (s1 agent))
	  (agent (s2 agent))
	  (agent (s3 agent))
	  ((s1 result) (s2 input))
	  )
       (time-constraints
	  ((s1 time) during time)
	  ((s2 time) during time)
	  ((s3 time) during time)
	  ((s1 time) beforeMeet (s3 time))
	  )
       (fact-constraints
	  (italian agent)
	  )
       )
   )

(frame
    '(make-spaghetti-marinara
	 (direct-abstr make-pasta-dish)
	 (steps (make-spaghetti s1) (make-marinara s2))
	 )
    )

(frame
    '(make-spaghetti-pesto
	 (direct-abstr make-pasta-dish)
	 (steps (make-spaghetti s1) (make-pesto s2))
	 )
    )


(frame
    '(make-fettucini-alfredo
	 (direct-abstr make-pasta-dish)
	 (steps (make-fettucini s1) (make-alfredo s2))
	 )
    )

(frame
    '(make-meat-dish
	 (direct-abstr prepare-meal)
	 )
    )

(frame
    '(make-chicken-marinara
	 (direct-abstr make-meat-dish)
	 (steps (make-marinara s5))
	 (eq-constraints
	     (agent (s5 agent))
	     )
	 (time-constraints
	     (time contains (s5 time))
	     )
	 )
    )

(frame
   '(make-sauce
       (direct-abstr non-end)
       )
   )

(frame
    '(make-marinara
	 (direct-abstr make-sauce)
	 )
    )

(frame
    '(make-alfredo
	 (direct-abstr make-sauce)
	 )
    )

(frame
    '(make-pesto
	 (direct-abstr make-sauce)
	 )
    )

(frame
    '(make-noodles
	 (params result)
	 (direct-abstr non-end)
	 )
    )

(frame
    '(make-spaghetti
	 (direct-abstr make-noodles)
	 )
    )

(frame
    '(make-fettucini
	 (direct-abstr make-noodles)
	 )
    )

(frame
    '(boil
	 (direct-abstr non-end)
	 (params input)
	 )
    )


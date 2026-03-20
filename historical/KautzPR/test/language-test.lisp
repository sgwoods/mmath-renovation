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


;;; An attempt to encode the speech act example without extending system


(frame
    '(end
	 '()
	 )
    )

(frame
    '(obtain
	 (direct-abstr end)
	 (times time preTime)
	 (params agent object)
	 (time-constraints
	     (preTime overlaps time)
	     )
	 (fact-constraints
	     (never preTime 'have agent object)
	     )
	 )
    )

(frame
    '(findout
	 (direct-abstr end)
	 (times time preTime)
	 (params agent info)
	 (time-constraints
	     (preTime overlaps time)
	     )
	 (fact-constraints
	     (never preTime 'knowif agent info)
	     )
	 )
    )

(frame
    '(obtain-by-asking
	 (direct-abstr obtain)
	 (steps (request s1) (give s2))
	 (time-constraints
	     (time contains (s1 time))
	     )
	 (eq-constraints
	     (agent (s1 speaker))
	     ((s1 reqGoal) (^ list 'gave (s1 hearer) agent object))
	     ('gave (^ car (s1 reqGoal)))
	     ((s1 hearer) (^ cadr (s1 reqGoal)))
	     (agent (^ caddr (s1 reqGoal)))
	     (object (^ cadddr (s1 reqGoal)))
	     )
	 )
    )

(frame
    '(findout-by-asking
	 (direct-abstr findout)
	 (steps (request s1) (informif s2))
	 (time-constraints
	     (time contains (s1 time))
	     )
	 (eq-constraints
	     (agent (s1 speaker))
	     ((s1 reqGoal) (^ list 'informedif (s1 hearer) agent info))
	     ('informedif (^ car (s1 reqGoal)))
	     ((s1 hearer) (^ cadr (s1 reqGoal)))
	     (agent (^ caddr (s1 reqGoal)))
	     (info (^ cadddr (s1 reqGoal)))
	     )
	 )
    )



(frame
    '(two-party-action
	 (params speaker hearer)
	 (times time)
	 (fact-constraints
	     (not-same speaker hearer)
	     )
	 )
    )


(frame
    '(speech-act
	 (direct-abstr two-party-action)
	 )
    )

(frame
    '(utterance-act
	 (direct-abstr two-party-action)
	 )
    )

(frame
    '(request
	 (direct-abstr speech-act)
	 (params reqGoal)
	 )
    )

(frame
    '(direct-request
	 (direct-abstr request)
	 (steps (surface-question s))
	 (time-constraints
	     (time equals (s time))
	     )
	 (eq-constraints
	     (speaker (s speaker))
	     (hearer (s hearer))
	     (reqGoal (^ list 'informedIf hearer speaker (s content)))
	     )
	 )
    )

(frame
    '(indirect-request
	 (direct-abstr request)
	 (steps (surface-question s))
	 (time-constraints
	     (time equals (s time))
	     )
	 (eq-constraints
	     (speaker (s speaker))
	     (hearer (s hearer))
	     (reqGoal (^ caddr (s content)))
	     ('can (^ car (s content)))
	     (hearer (^ cadr (s content)))
	     ((s content) (^ list 'can hearer reqGoal))
	     )
	 )
    )

(frame
    '(surface-question
	 (direct-abstr utterance-act)
	 (params content)
	 )
    )


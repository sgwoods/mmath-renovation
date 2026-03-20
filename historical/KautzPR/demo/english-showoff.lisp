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

;; Trace the inference process.
;; Turn this off by skipping this command (hit "n"), or later by entering
;; the immediate command (ee "Don't trace.").
(ee "Don't Trace.")

(ee "Clear the database.")

;****************************************************
;* Hunt-rob-test                                    *
;*    demonstrates upward inference and matching,   *
;*    without parameters.                           *
;****************************************************
(ee "Load file hunt-rob-test.")
;;
;; Multiple-Grouping Example.  Incremental algorithm finds one
;; solution, but the non-dichronic algorithm will find two.
;;
;;  INCREMENTAL version
;;
(ee "Perform incremental updates.")
(ee "Initialize the hypothesis set.")

(ee "Joe gets a gun.")
(ee "Show the hypothesis set in detail.")
(ee "Someone goes to the bank.")
(ee "Show the hypothesis set in detail.")
(ee "Someone goes to the woods.")
(ee "Show all in detail.")
;;
;;  NON-DICHRONIC version
;;
(ee "Perform non-dichronic updates.")
(ee "Initialize the hypothesis set.")

(ee "Joe gets a gun.")
(ee "Show the hypothesis set in detail.")
(ee "Someone goes to the bank.")
(ee "Show the hypothesis set in detail.")
(ee "Someone goes to the woods.")
(ee "Show all in detail.")



;******************************************************
;* Cooking hierarchy tests                            *
;*   Demonstrates multi-level hierarchy & constraints *
;*   This section also demonstrates explicit control  *
;*   of the matching process.                         *
;******************************************************

(ee "Clear.")
(ee "Load file cook-hierarchy-test.")

;; Notice that the hierarchy has the constraint that the agent of make-pasta-dish
;; must be Italian.  Let's assume that a person is only Italian if we know he is.
(negation-by-failure 'italian)
;;
;; First observation is make-sauce(obs-sauce), with agent Joe, during
;; time interval beginning between 4 and 5, and ending before 7.
;; Note that times are represented by VECTORS with 'time as first element.
;; The parameters of the observation are specified by a list of (role value) pairs.
;; The first use of the symbol "time" below refers to the role Time, while the second
;; merely identifies the vector value as a time.

(ee "Let g1 explain why Joe makes sauce, starting between times 4 and 5 and ending before 7.")

(ee "Show graph g1 in detail.")

;; Notice that we eliminated the possibility of make-pasta-dish.
;; Therefore the observation had to be of make-marinara.

;; Now lets add the fact that Joe is Italian.  This fact does not take a temporal index.
(add-fact '(italian joe))

;; Try the observation of make-sauce again.  Use a different graph and
;; starting node name to avoid conflicts.

(ee "Let g2 explain that from 4 5 to before 7 Joe cooks sauce.")

(ee "Show g2 in detail.")

;; This time make-pasta-dish WAS considered.  

;; The second observation is making noodles.

(ee "Let g3 explain why Joe makes noodles from 6 to between 7 and 9.")

(ee "show g3 in detail.")

;; We can merge g2 and g3 together: they can be steps of the same
;; action, a make-pasta-dish.

(ee "Match g2 and g3.")

(ee "Show the result in detail.")

;; Now consider an observation of make-noodles with a different agent.
;; Constants like agent are considered unique names, and all all
;; unequal.

(add-fact '(italian sally))

(ee "Let g4 explain why Sally makes noodles from 7 to 9.")

;; Try to match this with the original make-sauce.  It will fail,
;; because agent roles differ.

(ee "Match g2 and g4.")

(ee "Show the result.")

;; Lets check out the temporal constraints, now.  We'll observe a
;; boiling event, but the time we be BEFORE the make-noodles event.
;; This conflict will prevent a match.

(ee "Let g5 explain why somebody boils noodles from time 1 to time 2.")

(ee "Show the result in detail.")

;; Try to match this with g2 and g3

(ee "Match g2+g3 and g5 giving g2+g3+g5.")

(ee "Show graph g2+g3+g5.")

;; Now lets find a LATER boiling event.  It should match okay.

(ee "Let g6 explain why from 10 to 12 somebody boils noodles.")

(ee "Match graphs g2+g3 and g6.")

(ee "Show result in detail.")

;; End of cooking examples

;;; File System Example:  demonstrates multiple simultaneous plans.

(ee "Clear.")
(ee "Load file-system-test.")
(ee "Initialize.")
(ee "Incremental update.")
(ee "user copies file foo to file bar")
;; Could be part of rename by copy, or of modify file
(ee "Show last graph in detail.")
(ee "cp jack sprat")
(ee "Show hypotheses in detail.")
;; So, there must be two different plans going on.
(ee "User deletes foo.")
;; This delete can unify with command 1, but not command 2
(ee "Show hypotheses in detail.")

;; End of file system tests


;******************************************************
;* Language Test                                      *
;*    Demonstrates inference up 2 levels of step      *
;*    hierarchy before alternatives are eliminated,   *
;*    and the use of temporally-dependent constraints.*
;******************************************************
;;    
;; The parser is not powerful enough to handle embedded sentences such
;; as "Joe said to Sally, 'Can you give me the salt?'", so the
;; routines which take the logical form as input are called directly.
;;

(clear-all-mappings)
(load (merge-pathnames "language-test" *test-dir*))

;;  Look at the source for the hierarchy here.  Note that we constrain
;; the speaker and hearer of two-agent acts to be different, using the
;; predicate "not-same".  The function call 
;;            (to-disprove 'not-same 'equalp) 
;; says that we can disprove two things are NOT the same by
;; proving they are equalp.  The function "disprove-never" is a way to
;; disprove a constraint of the form 
;;            (never time1 predicate arg1 arg2 ...)
;; It does so by finding a time2 such that (predicate time2
;; arg1 arg2 ...) and time1 and t2 must intersect.  Then we assign
;; disprove-never to the predicate never.

;; Also note the use of the "^" escape function is the hierarchy.
;; This is used to call lisp functions to construct data structures
;; representing beliefs.

;; Joe says to Sally:  Can you give me the salt?
(explain-observation '(surface-question (speaker joe) 
			 (hearer sally) 
			 (time #(time 4 4 5 5))
			 (content (can sally (gave sally joe salt)))) 'utter1)
;; The statement is ambiguous, as we see:
(draw-graph)
;; The more detailed version of the previous graph:
(draw-graph t)

;; There are 2 (of 4) alternatives not eliminated: an attempt to find
;; out if Sally can give Joe the salt, or an attempt to obtain the
;; salt.

;; Now lets add the fact that at all times, Joe knows if  Sally can give him the salt.
(add-fact '(knowif #(time :-inf :-inf :+inf :+inf) 
	      joe (can sally (gave sally joe salt))))
;; Try again, Joe says to Sally: Can you give me the salt?
(explain-observation '(surface-question (speaker joe) 
			 (hearer sally) 
			 (time #(time 4 4 5 5))
			 (content (can sally (gave sally joe salt)))) 'utter2)
;; The only interpretation is the indirect request.
(draw-graph )
;; The more detailed version of the previous graph:
(draw-graph t)
;; You can try the other combinations!
;; End of language test.


;*******************************************************
;* Merge test: Demonstrates "collapsing" of search     *
;*    graph, during matching.  To understand this test,*
;*    try drawing the graphs. You will see a double    *
;*    diamond.  We can retain uncertainty in the top   *
;*    of the graph, even as lower level steps are      *
;*    disambiguated.                                   *
;*******************************************************

(clear-all-mappings)
(load (merge-pathnames "merge-test" *test-dir*))
(explain-observation '(H) 'g1)
(draw-graph t)
;; Note the little ^ signs in the graph.  They indicate a reference to graph structure
;; which has been printed on a previous line.
(explain-observation '(K) 'g2)
(draw-graph t)
;; Now matching g1 and g2 yields decision on F, but retains ambiguity between B and C
(match-graphs 'g1 'g2 'g1+g2)
(draw-graph t)
;; end of merge test

exit

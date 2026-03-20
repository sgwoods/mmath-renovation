;;; -*- Syntax: Common-lisp; Package: USER -*-
;;; Copyright 1987 by Henry A. Kautz

;;; You are running the demo program.  Hit <space> or y after each command
;; is printed to execute that command.  Hit n to skip that command, or q to quit.
;; You may also enter an expression in ()'s for immediate evaluation.  Do this
;; to turn tracing flags on and off.

;; Setting *noisy* to non-nil causes inference process to be traced.
;; Turn this off by skipping this command (hit "n"), or later by entering
;; the immediate command (setq *noisy* nil).
(setq *noisy* t)

;; Clear the database.
(clear-all-mappings)

;;;; Hunt-rob-test : demonstrates upward inference and matching, without parameters.
;; Load the hierarchy.
(load (merge-pathnames "hunt-rob-test" test-dir))
;; First observation:  get-gun(c1).  Builds graph named g1.
(explain-observation '( get-gun) 'g1)
;; Show the graph g1 (defaults to last graph used, if none specified).
;; There are two alternatives, with c1 as component of rob-bank or of hunt.
(draw-graph)
;; Another way to look at the graph is longer but more detailed.
(display-graph)
;; Second observation: go-to-bank(c2), in graph g2.
(explain-observation '( go-to-bank) 'g2)
;; Show g2, again two alternatives:  rob-bank or cash-check.
(draw-graph)
;; Matching the graphs yields just the rob-bank alternative.
(match-graphs 'g1 'g2 'g1+g2)
(draw-graph)



;;;; Cooking hierarchy tests : demonstrates multi-level hierarchy & constraints.
(clear-all-mappings)
(load (merge-pathnames "cook-hierarchy-test" test-dir))
;; Notice that the hierarchy has the constraint that the agent of make-pasta-dish
;; must be Italian.  Let's assume that a person is only Italian if we know he is.
(negation-by-failure 'italian)
;; First observation is make-sauce(obs-sauce), with agent Joe, during
;; time interval beginning between 4 and 5, and ending between 6 and 7.
;; Note that times are represented by VECTORS with 'time as first element.
;; The parameters of the observation are specified by a list of (role value) pairs.
;; The first use of the symbol "time" below refers to the role Time, while the second
;; merely identifies the vector value as a time.
(explain-observation '(make-sauce (agent Joe) (time #(time 4 5 6 7))) 'g1)
;; View the graph.  Including the parameter t means to show the parameters of each event.
(draw-graph t)
;; Notice that we eliminated the possibility of make-pasta-dish.  Therefore the observation
;; had to be of make-marinara.
;; Now lets add the fact that Joe is Italian.  This fact does not take a temporal index.
(add-fact '(italian joe))
;; Try the observation of make-sauce again.  Use a different graph and starting node name
;; to avoid conflicts.
(explain-observation '(make-sauce (agent Joe) (time #(time 4 5 6 7))) 'g2)
(draw-graph t)
;; This time make-pasta-dish WAS considered.  
;; The second observation is making making noodles.
(explain-observation '(make-noodles (agent Joe) (time #(time 6 8 7 9))) 'g3)
(draw-graph t)
;; We can merge g2 and g3 together: they can be steps of the same action, a make-pasta-dish
(match-graphs 'g2 'g3 'g2+g3)
(draw-graph t)
;; Now consider an observation of make-noodles with a different agent.  Constants like agent
;; are considered unique names, and all all unequal.
(add-fact '(italian sally))
(explain-observation '(make-noodles (agent Sally) (time #(time 6 8 7 9))) 'g4)
;; Try to match this with the original make-sauce.  It will fail, because agent roles differ.
(match-graphs 'g2 'g4 'g2+g4)
(draw-graph t)
;; Lets check out the temporal constraints, now.  We'll observe a boiling event, but the time
;; we be BEFORE the make-noodles event.  This conflict will prevent a match.
(explain-observation '(boil  (time #(time 1 1 2 2))) 'g5)
(draw-graph t)
;; Try to match this with g2 and g3
(match-graphs 'g2+g3 'g5 'g2+g3+g5)
(draw-graph t)
;; Now lets find a LATER boiling event.  It should match okay.
(explain-observation '(boil  (time #(time 9 10 11 12))) 'g6)
(match-graphs 'g2+g3 'g6 'g2+g3+g6)
(draw-graph t)

;; End of cooking examples

;;; File System Example:  demonstrates multiple end events.
(clear-all-mappings)
(load (merge-pathnames "file-system-test" test-dir))
;; User enters:  copy foo bar.
(explain-observation '(copy (old foo) (new bar)) 'c1)
;; Could be part of rename by copy, or of modify file
(draw-graph t)
;; User enters: copy jack sprat.
(explain-observation '(copy (old jack) (new sprat)) 'c2)
;; Try (and fail) to unify these commands.
(match-graphs 'c1 'c2 'c1+c2)
(draw-graph t)
;; So, there must be two different plans going on.
;; User enters: delete foo
(explain-observation '(delete (file foo)) 'c3)
(draw-graph t)
;; This delete can unify with command 1, but not command 2
(match-graphs 'c1 'c3 'c1+c3)
(draw-graph t)
(match-graphs 'c2 'c3 'c2+c3)
(draw-graph t)

;; End of file system tests

;;; Merge test: Demonstrates "collapsing" of search graph, during matching
;;    To understand this test, try drawing the graphs. You will see a double
;;    diamond.  We can retain uncertainty in the top of the graph, even as lower
;;    level steps are disambiguated.
(clear-all-mappings)
(load (merge-pathnames "merge-test" test-dir))
(explain-observation '(H) 'g1)
(draw-graph t)
;; Note the little ^ signs in the graph.  They indicate a reference to graph structure
;; which has been printed on a previous line.
(explain-observation '(K) 'g2)
(draw-graph t)
;; Now matching g1 and g2 yields decision on F, but retains ambiguity between B and C
(match-graphs 'g1 'g2 'g1+g2)
(draw-graph t)

;; End of Graph Test

;;; Language Test : Shows inference up 2 levels of step hierarchy before alternatives are
;;  eliminated, and the use of temporally-dependent constraints.
;;
(clear-all-mappings)
(load (merge-pathnames "language-test" test-dir))
;;  Look at the source for the hierarchy here.   Note that we constrain the speaker and hearer
;; of two-agent acts to be different, using the predicate "not-same".  The function call
;; (to-disprove 'not-same 'equalp) says that we can disprove two things are NOT the same by
;; proving they are equalp.  
;;    The function "disprove-never" is a way to disprove a constraint of the form
;;   (never time1 predicate arg1 arg2 ...).  It does so by finding a time2 such that
;;   (predicate time2 arg1 arg2 ...) and time1 and t2 must intersect.
;;  Then we assign disprove-never to the predicate never.

;;  Also note the use of the "^" escape function is the hierarchy.  This is used to call lisp
;;  functions to construct data structures representing beliefs.

;; Joe says to Sally:  Can you give me the salt?
(explain-observation '(surface-question (speaker joe) (hearer sally) (time #(time 4 4 5 5))
			 (content (can sally (gave sally joe salt)))) 'utter1)
;; The statement is ambiguous, as we see:
(draw-graph)
;; The more detailed version of the previous graph:
(draw-graph t)
;; There are 2 (of 4) alternatives not eliminated:  an attempt to find out if Sally can give Joe
;; the salt, or an attempt to obtain the salt.

;; Now lets add the fact that at all times, Joe knows if  Sally can give him the salt.
(add-fact '(knowif #(time :-inf :-inf :+inf :+inf) joe (can sally (gave sally joe salt))))
;; Try again, Joe says to Sally: Can you give me the salt?
(explain-observation '(surface-question (speaker joe) (hearer sally) (time #(time 4 4 5 5))
			 (content (can sally (gave sally joe salt)))) 'utter2)
;; The only interpretation is the indirect request.
(draw-graph )
;; The more detailed version of the previous graph:
(draw-graph t)
;; You can try the other combinations!
;; End of language test.
exit

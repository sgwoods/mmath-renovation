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

;;; Demonstrates UPDATE and PARSE-ENGLISH

;; Trace the inference process.
;; Turn this off by skipping this command (hit "n"), or later by entering
;; the immediate command (ee "Don't trace.").
(ee "Trace.")

(ee "Clear the database.")

;;;; Hunt-rob-test : demonstrates upward inference and matching, without parameters.
(ee "Load file hunt-rob-test.")
;;
;; Simple INCREMENTAL example
;;
(ee "Perform incremental updates.")
(ee "Initialize hypothesis set.")
;; First observation
(ee "Agent gets a gun.")
(ee "show the explanation.")
(ee "Show the hypothesis set.")
;; Second observation
(ee "Agent goes to the bank.")

(ee "Show all.")
;;
;; NON-DICHRONIC Solution for this example is exactly the same
;;
(ee "Perform non-dichronic updates.")
(ee "Initialize hypothesis set.")
;; First observation
(ee "Agent gets a gun.")
(ee "show the explanation.")
(ee "Show the hypothesis set.")
;; Second observation
(ee "Agent goes to the bank.")

(ee "Show all.")
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


;;; Merge test: Demonstrates "collapsing" of search graph, during matching
;;    To understand this test, try drawing the graphs. You will see a double
;;    diamond.  We can retain uncertainty in the top of the graph, even as lower
;;    level steps are disambiguated.

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

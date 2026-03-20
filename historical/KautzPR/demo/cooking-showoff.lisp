;;  Cooking hierarchy tests
;;
;;  Demonstrates multi-level hierarchy & constraints.
;;  This section also demonstrates explicit control of the matching
;;  process.

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

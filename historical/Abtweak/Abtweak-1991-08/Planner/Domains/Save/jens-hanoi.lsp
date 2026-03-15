;***************************************************************************
; tower of hanoi (3) domain definition
; 
;***************************************************************************
(setq *domain* 'hanoi-3-jens)

(setq a (create-operator-instance
	 :opid 'move-big
	 :name '(move-big big-disk $from $to)
	 :preconditions '((smaller big-disk $to)
                          (clear big-disk) 
                          (clear $to) 
                         )
	 :effects '((not on big-disk $from)
                    (not clear $to)
                    (on big-disk $to)
                    (clear big-disk))))

(setq a (create-operator-instance
	 :opid 'move-medium
	 :name '(move-medium medium-disk $from $to)
	 :preconditions '((smaller medium-disk $to)
                          (clear medium-disk) 
                          (clear $to) 
                         )
	 :effects '((not on medium-disk $from)
                    (not clear $to)
                    (on medium-disk $to)
                    (clear medium-disk))))

(setq a (create-operator-instance
	 :opid 'move-small
	 :name '(move-small small-disk $from $to)
	 :preconditions '((smaller small-disk $to)
                          (clear small-disk) 
                          (clear $to) 
                         )
	 :effects '((not on small-disk $from)
                    (not clear $to)
                    (on small-disk $to)
                    (clear small-disk))))

(setq *operators* (list a b c))

; initial state
;
(setq initial '(
                (smaller small-disk big-disk)
                (smaller small-disk medium-disk)
                (smaller medium-disk big-disk)

                (smaller big-disk peg1)
                (smaller big-disk peg2)
                (smaller big-disk peg3)
                (smaller medium-disk peg1)
                (smaller medium-disk peg2)
                (smaller medium-disk peg3)
                (smaller small-disk peg1)
                (smaller small-disk peg2)
                (smaller small-disk peg3)

                (on small-disk medium-disk) 
                (on medium-disk big-disk)
                (on big-disk peg1)
               
                (clear small-disk)
                (clear peg2)
                (clear peg3)
               ))

;goal state
;
(setq goal '( (on big-disk peg3) (on medium-disk big-disk) (on small-disk medium-disk)))

;***************************************************************************
; abtweak domain part - refered to only in abtweak
;***************************************************************************

; default criticality list
;
; see others in:
; /u/sgwoods/plan/tweak2/examples/hanoi-3/

(setq *move-big-clear-criticality*     5)
(setq *move-medium-clear-criticality*  4)
(setq *move-small-clear-criticality*   3)
(setq *default-clear-criticality*      0)

; not completed - left as is (see qiang/steve nov 1990
; making clear criticality different for operator type
; refer to changes in jens-ab-succ.lsp also w.r.t
; changing function find-crit (pname &key operator)

(setq *critical-list* '(
   (5  (smaller $ $) )
   (4  (clear peg1) (clear peg2) (clear peg3) )
   (3  (clear big-disk) )
   (2  (clear medium-disk) )
   (1  (clear small-disk) )
   (0  (on $ $) )
))
(setq *critical-loaded* 'trial)

; preference values for each successive level of abstraction
;  - related to top down property
;  this value is factored into the heuristic for preference of
;  plans - essentially preferdisk level k over level k+1 by a
;  depth-factor as indicated in *k-list* at this k
;
(setq *k-list* '(0 1 3 7))

(setq *top-down-levels*     
'(
   9999999
))

; load testing criticality definition load routines (hanoi3)
;
;(load "/u/sgwoods/plan/planner/domains/hanoi-3/load-tests")

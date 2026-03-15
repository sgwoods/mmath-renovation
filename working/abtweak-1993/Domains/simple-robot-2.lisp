;***************************************************************************
; Modified AbStrips ROBOT domain definition---version 2
;***************************************************************************

;;; For a picture of the domain, check out Sacerdoti's paper on 
;;; Abstrips, AIJ.

;;; Note:  version 2 has all locations within rooms, that are not 
;;; next to doors, removed.  So it is a simpler version. 

;;; Note:  make sure that when (plan initial goal ..)is called, 
;;; turn the following flags on:
;;; 1) load "robot-heuristic"
;;; 2) :use-primary-effect-p t
;;; 3) :heuristic-mode 'user-defined.
;;;
;;; The user defined heuristic checks loops for the robot domain.


(setq *domain* 'robot)
 
; operators

;---------- Go within Room Operators. ----------------------

; Go to Location within room
(setq o3 (make-operator
	 :opid 'goto-room-loc
	 :name '(goto-room-loc $from $to $room)
	 :cost 1
	 :preconditions '(
                          (location-inroom  $to    $room)
                          (location-inroom  $from  $room)
			  (robot-inroom $room)  
                          (robot-at $from)
			 )
	 :effects '(
                    (not robot-at $from)
                    (robot-at $to))
	 :primary-effects '(
			    (not robot-at $from)
			    (robot-at $to))
	 ))
                   


; Push boxect between locations within one room
;
(setq o4 (make-operator
	 :opid 'push-box

	 :name '(push-box $box $room $box-from-loc $box-to-loc robot)
	 :cost 1
	 :preconditions '(
                          (pushable   $box)
                          (location-inroom     $box-to-loc   $room)
                          (location-inroom     $box-from-loc $room)
			  (box-inroom $box $room) 
			  (robot-inroom $room)
                          (box-at $box  $box-from-loc)
                          (robot-at $box-from-loc)
			 )
	 :effects '(
                    (not robot-at $box-from-loc)
                    (not box-at $box  $box-from-loc)
                    (robot-at $box-to-loc)
                    (box-at $box $box-to-loc))
	 :primary-effects '(
			    (not box-at $box  $box-from-loc)
			    (box-at $box $box-to-loc))
	 ))



;------------------- Between Rooms --------------------

; Push BOX through DOOR between 2 rooms
(setq o6 (make-operator
	 :opid 'push-thru-dr
	 :name '(push-thru-dr $box $door-nm $from-room $to-room 
                              $door-loc-from $door-loc-to robot)
	 :cost 1
	 :preconditions '(
                          (is-door  $door-nm $from-room $to-room $door-loc-from
				    $door-loc-to)
                          (pushable $box)
			  (box-inroom $box $from-room)
                          (robot-inroom $from-room)
  		          (box-at $box   $door-loc-from)
  		          (robot-at  $door-loc-from)
                          (open     $door-nm)
			 )
	 :effects '(
                    (not robot-inroom $from-room)
                    (robot-inroom $to-room)
                    (not box-inroom $box  $from-room)
                    (box-inroom $box  $to-room)
		    (robot-at $door-loc-to)
		    (box-at $box $door-loc-to)
		    (not robot-at $door-loc-from)
		    (not box-at $box $door-loc-from))
	 :primary-effects '(
                    (not box-inroom $box  $from-room)
                    (box-inroom $box  $to-room)
		    (box-at $box $door-loc-to)
		    (not box-at $box $door-loc-from))
	 ))


; GO through door from room2 to room1

(setq o7 (make-operator
	 :opid 'go-thru-dr
	 :name '(go-thru-dr $door-nm $from-room $to-room 
                            $door-loc-from $door-loc-to )
	 :cost 1
	 :preconditions '(
                          (is-door  $door-nm $from-room $to-room $door-loc-from
				    $door-loc-to)
                          (robot-inroom $from-room)
  		          (robot-at     $door-loc-from)
                          (open     $door-nm)

			 )
	 :effects '(
		    (robot-at $door-loc-to)
		    (not robot-at $door-loc-from)
                    (not robot-inroom $from-room)
                    (robot-inroom $to-room))
	 :primary-effects '(
		    (robot-at $door-loc-to)
		    (not robot-at $door-loc-from)
                    (not robot-inroom $from-room)
                    (robot-inroom $to-room))
))




;---------------------- Door Operators -------------------------

; Open door

(setq o9 (make-operator
	 :opid 'open
	 :name '(open $door-nm $from-room $to-room $door-loc-from $door-loc-to)
	 :cost 1
	 :preconditions '(
                          (is-door  $door-nm $from-room $to-room $door-loc-from
				    $door-loc-to)
                          (not open $door-nm)
                          (robot-at $door-loc-from)       
			 )
	 :effects '(
                    (open $door-nm))
	 :primary-effects '(
                    (open $door-nm))
                   ))

; Close door
(setq o10 (make-operator
	 :opid 'close
	 :name '(close $door-nm $from-room $to-room $door-loc-from $door-loc-to)
 	 :cost 1
	 :preconditions '(
                          (is-door  $door-nm $from-room $to-room $door-loc-from
				    $door-loc-to)
                          (open $door-nm)
                          (robot-at $door-loc-from)       
			 )
	 :effects '(
                    (not open $door-nm))
	 :primary-effects '(
                    (not open $door-nm))
	 ))

(setq *operators* (list o3 o4 o6 o7 o9 o10 ))

; initial state
;
;Notes:
;carriable or pushable apply only to BOXES (implied)
;

(setq initial-fixed
'(
    (pushable box1)
    (pushable box2)
    (pushable box3)  

;    (is-location loc1 )
;    (location-inroom loc1 room1)
;    (is-location loc2 )
;    (location-inroom loc2 room1)

    (is-location loc3-1)
    (is-location loc3-2)
    (location-inroom loc3-1 room1)
 
   (location-inroom loc3-2 room2)
    (is-door door1-2 room1 room2 loc3-1 loc3-2)
    (is-door door1-2 room2 room1 loc3-2 loc3-1)


 ;   (is-location loc4 )
;    (location-inroom loc4 room2)
;    (is-location loc5 )
;    (location-inroom loc5 room2)

    (is-location loc6-2)
    (is-location loc6-6)
    (location-inroom loc6-2 room2)
    (location-inroom loc6-6 room6)
    (is-door door2-6 room2 room6 loc6-2 loc6-6)
    (is-door door2-6 room6 room2 loc6-6 loc6-2)


    (is-location loc7-2)
    (is-location loc7-5)
    (location-inroom loc7-2 room2)
    (location-inroom loc7-5 room5)
    (is-door door2-5 room2 room5 loc7-2 loc7-5)
    (is-door door2-5 room5 room2 loc7-5 loc7-2)


    (is-location loc8-2)
    (is-location loc8-3)
    (location-inroom loc8-2 room2)
    (location-inroom loc8-3 room3)

    (is-door door2-3 room2 room3 loc8-2 loc8-3)
    (is-door door2-3 room3 room2 loc8-3 loc8-2)


 ;   (is-location loc9 )
;    (location-inroom loc9 room3)
;    (is-location loc10)
;    (location-inroom loc9 room3)

    (is-location loc11-3)
    (is-location loc11-5)
    (location-inroom loc11-3 room3)
    (location-inroom loc11-5 room5)

    (is-door door3-5 room3 room5 loc11-3 loc11-5)
    (is-door door3-5 room5 room3 loc11-5 loc11-3)


 ;   (is-location loc13)
;    (location-inroom loc13 room6)
;    (is-location loc14)
;    (location-inroom loc14 room6)

    (is-location loc15-5)
    (is-location loc15-6)
    (location-inroom loc15-5 room5)
    (location-inroom loc15-6 room6)

    (is-door door5-6 room5 room6 loc15-5 loc15-6)
    (is-door door5-6 room6 room5 loc15-6 loc15-5)


 ;   (is-location loc16)
;    (location-inroom loc16 room5)

    (is-location loc17-4)
    (is-location loc17-5)
    (location-inroom loc17-4 room4)
    (location-inroom loc17-5 room5)

    (is-door door4-5 room4 room5 loc17-4 loc17-5)
    (is-door door4-5 room5 room4 loc17-5 loc17-4)))


 ;   (is-location loc18)
;    (location-inroom loc18 room4)
;    (is-location loc19)
;    (location-inroom loc19 room4)
;    (is-location loc20)
;    (location-inroom loc20 room5)))

(setq 
 initial 
 (append
  '((not open door1-2)
    (not open door2-6)
    (not open door2-5)
    (not open door2-3)
    (not open door3-5)
    (not open door5-6)
    (not open door4-5)

    (robot-at loc17-4)
    (robot-inroom room4)

    (box-at box1 loc6-6)
    (box-inroom box1 room6)

    (box-at box2 loc7-2)
    (box-inroom box2 room2)

    (box-at box3 loc15-6)
    (box-inroom box3 room6))
  initial-fixed))



;goal state
;
(setq goal '(
 (robot-inroom room2)
 (box-inroom box1 room3)
 (box-at box1 loc8-3)
            ))

;***************************************************************************
; abtweak domain part - refered to only in abtweak
;***************************************************************************


(setq *critical-list* '(
   (5  (location-inroom $ $)  (is-door $ $ $ $ $) (isa-door $ $)
    (is-location $) (pushable $) (carriable $))
   (4 (box-inroom $ $) )
   (3  (robot-inroom $) )
   (2  (box-at $ $))
   (1  (robot-at $) )
   (0  (open $) (not open $)))

)

(setq *left-wedge-list* '(0 1 20 30 40 50))  ; simple default


; Other initial states---depending on in which room the robot is.

(setq 
 initial4  initial)
 
(setq initial6
 (append
  '((not open door1-2)
    (not open door2-6)
    (not open door2-5)
    (not open door2-3)
    (not open door3-5)
    (not open door5-6)
    (not open door4-5)

    (robot-at loc15-6)
    (robot-inroom room6)

    (box-at box1 loc6-6)
    (box-inroom box1 room6)

    (box-at box2 loc7-2)
    (box-inroom box2 room2)

    (box-at box3 loc15-6)
    (box-inroom box3 room6))
  initial-fixed))

(setq initial5
 (append
  '((not open door1-2)
    (not open door2-6)
    (not open door2-5)
    (not open door2-3)
    (not open door3-5)
    (not open door5-6)
    (not open door4-5)


    (robot-at loc11-5)
    (robot-inroom room5)

    (box-at box1 loc6-6)
    (box-inroom box1 room6)

    (box-at box2 loc7-2)
    (box-inroom box2 room2)

    (box-at box3 loc15-6)
    (box-inroom box3 room6))

  initial-fixed))


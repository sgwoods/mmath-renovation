`;***************************************************************************
; Strips ROBOT domain definition
;***************************************************************************
(setq *domain* 'robot)
 
; operators

; Pickup  OBJ when robot next to OBJ and OBJ can be carried
(setq o1 (make-operator
	 :opid 'pickup-obj
	 :name '(pickup-obj $obj $loc robot)
	 :preconditions '(
			  (armempty)                          
			  (carriable   $obj)
			  (at $obj     $loc)
			  (at robot    $loc)
                          (is-location $loc)
			 )
	 :effects '(
                    (not armempty)
		    (holding $obj)
                    (not at  $obj $loc)
                   )))

; Putdown  OBJ next-to robot 
;   Note object has an effect of inroom
; 
(setq o2 (make-operator
	 :opid 'putdown
	 :name '(putdown $obj $loc robot)
	 :preconditions '(
                          (holding $obj)
                          (at  robot $loc)
			 )
	 :effects '(
                    (not holding   $obj)
                    (at  $obj  $loc)
                    (armempty)
                   )))

; Go to Location within room
(setq o3 (make-operator
	 :opid 'goto-room-loc
	 :name '(goto-room-loc $from $to $room)
	 :preconditions '(
                          (location-inroom  $to    $room)
                          (location-inroom  $from  $room)
                          (inroom robot $room)
                          (at robot $from)
			 )
	 :effects '(
                    (not at robot $from)
                    (at robot $to)
                   )))

; Push OBJ through DOOR between 2 rooms
(setq o5 (make-operator
	 :opid 'push-thru-dr
	 :name '(push-thru-dr $obj $door-nm $from-room $to-room 
                              $door-loc robot)
	 :preconditions '(
                          (pushable $obj)
                          (is-door  $door-nm $from-room $to-room $door-loc)
                          (location-inroom $door-loc $to-room)
                          (location-inroom $door-loc $from-room)
                          (open     $door-nm)
                          (inroom   $obj  $from-room)
                          (inroom   robot $from-room)
  		          (at $obj   $door-loc)
  		          (at robot  $door-loc)
			 )
	 :effects '(
                    (not inroom robot $from-room)
                    (inroom robot $to-room)
                    (not inroom $obj $from-room)
                    (inroom $obj $to-room)
                   )))

; GO through door from room2 to room1
(setq o6 (make-operator
	 :opid 'go-thru-dr
	 :name '(go-thru-dr $door-nm $from-room $to-room 
                            $door-loc )
	 :preconditions '(
                          (armempty)
                          (is-door  $door-nm $from-room $to-room $door-loc)
                          (location-inroom $door-loc $to-room)
                          (location-inroom $door-loc $from-room)
                          (open     $door-nm)
                          (inroom robot $from-room)
  		          (at robot     $door-loc)
			 )
	 :effects '(
                    (not inroom robot $from-room)
                    (inroom robot $to-room)
                   )))

; Carry object through door-nm from from-room to to-room
(setq o7 (make-operator
	 :opid 'carry-thru-dr
	 :name '(carry-thru-dr $obj $door-nm $from-room $to-room 
                               $door-loc robot)
	 :preconditions '(
                          (carriable $obj)
  		          (holding   $obj)
                          (is-door  $door-nm $from-room $to-room $door-loc)
                          (location-inroom $door-loc $to-room)
                          (location-inroom $door-loc $from-room)
                          (open     $door-nm)
                          (inroom   robot $from-room)
                          (inroom   $obj  $from-room)
  		          (at robot  $door-loc)
			 )
	 :effects '(
                    (not inroom robot $from-room)
                    (inroom robot $to-room)
                    (not inroom $obj $from-room)
                    (inroom $obj $to-room)
                   )))

; Push object between locations within one room
;
(setq o8 (make-operator
	 :opid 'push-obj
	 :name '(push-obj $obj $room $obj-from-loc $obj-to-loc robot)
	 :preconditions '(
                          (pushable   $obj)
                          (location-inroom     $obj-to-loc   $room)
                          (location-inroom     $obj-from-loc $room)
                          (at $obj  $obj-from-loc)
                          (at robot $obj-from-loc)
                          (inroom     robot $room)
                          (inroom     $obj  $room)
			 )
	 :effects '(
                    (not at robot $obj-from-loc)
                    (not at $obj  $obj-from-loc)
                    (at robot $obj-to-loc)
                    (at $obj1 $obj-to-loc)
                   )))

; Open door
(setq o9 (make-operator
	 :opid 'open
	 :name '(open $door-nm $door-loc)
	 :preconditions '(
                          (isa-door  $door-nm $door-loc)
                          (not open $door-nm)
                          (at robot $door-loc)       
			 )
	 :effects '(
                    (open $door-nm)
                   )))

; Close door
(setq o10 (make-operator
	 :opid 'close
	 :name '(close $door-nm $door-loc)
	 :preconditions '(
                          (isa-door  $door-nm $door-loc)
                          (open $door-nm)
                          (at robot $door-loc)       
			 )
	 :effects '(
                    (not open $door-nm)
                   )))

(setq *operators* (list o1 o2 o3 o5 o6 o7 o8 o9 o10 ))

; initial state
;
; notes
;   carriable or pushable apply only to OBJECTS (implied)
;
(setq initial 
'(
    (armempty)
    
    (carriable obj1)
    (not carriable obj2)
    (carriable obj3)
    
    (pushable obj1)
    (pushable obj2)
    (not pushable obj3)  

    (is-location loc1 )
    (location-inroom loc1 room1)
    (is-location loc2 )
    (location-inroom loc2 room1)

    (is-location loc3)
    (location-inroom loc3 room1)
    (location-inroom loc3 room2)
    (isa-door door1-2 loc3)
    (is-door door1-2 room1 room2 loc3)
    (is-door door1-2 room2 room1 loc3)
    (not open door1-2)

    (is-location loc4 )
    (location-inroom loc4 room2)
    (is-location loc5 )
    (location-inroom loc5 room2)

    (is-location loc6)
    (location-inroom loc6 room2)
    (location-inroom loc6 room6)
    (isa-door door2-6 loc6)
    (is-door door2-6 room2 room6 loc6)
    (is-door door2-6 room6 room2 loc6)
    (open door2-6)

    (is-location loc7)
    (location-inroom loc7 room2)
    (location-inroom loc7 room5)
    (isa-door door2-5 loc7)
    (is-door door2-5 room2 room5 loc7)
    (is-door door2-5 room5 room2 loc7)
    (open door2-5)

    (is-location loc8)
    (location-inroom loc8 room2)
    (location-inroom loc8 room3)
    (isa-door door2-3 loc8)
    (is-door door2-3 room2 room3 loc8)
    (is-door door2-3 room3 room2 loc8)
    (open door2-3)

    (is-location loc9 )
    (location-inroom loc9 room3)
    (is-location loc10)
    (location-inroom loc9 room3)

    (is-location loc11)
    (location-inroom loc11 room3)
    (location-inroom loc11 room5)
    (isa-door door3-5 loc11)
    (is-door door3-5 room3 room5 loc11)
    (is-door door3-5 room5 room3 loc11)
    (open door3-5)

    (is-location loc12)
    (location-inroom loc12 room6)
    (is-location loc13)
    (location-inroom loc13 room6)
    (is-location loc14)
    (location-inroom loc14 room6)

    (is-location loc15)
    (location-inroom loc15 room5)
    (location-inroom loc15 room6)
    (isa-door door5-6 loc15)
    (is-door door5-6 room5 room6 loc15)
    (is-door door5-6 room6 room5 loc15)
    (open door5-6)

    (is-location loc16)
    (location-inroom loc16 room5)

    (is-location loc17)
    (location-inroom loc17 room4)
    (location-inroom loc17 room5)
    (isa-door door4-5 loc17)
    (is-door door4-5 room4 room5 loc17)
    (is-door door4-5 room5 room4 loc17)
    (not open door4-5)

    (is-location loc18)
    (location-inroom loc18 room4)
    (is-location loc19)
    (location-inroom loc19 room4)
    (is-location loc20)
    (location-inroom loc20 room5)

    (at robot loc1)
    (inroom robot room1)

    (at obj1 loc13)
    (inroom obj1 room6)

    (at obj2 loc5)
    (inroom obj2 room2)

    (at obj3 loc1)
    (inroom obj3 room1)
))

;goal state
;
(setq goal '(
 (inroom robot room1)
            ))

;***************************************************************************
; abtweak domain part - refered to only in abtweak
;***************************************************************************

(setq *critical-list* '(
   (5  (location-inroom $ $)  (is-door $ $ $ $) (isa-door $ $) )
   (4  (armempty) (is-location $) (pushable $) (carriable $) )
   (3  (inroom $ $) )
   (2  (at     $ $) )
   (1  (open $) (not open $) )
   (0  (holding $) )
))

(setq *k-list* '(0 0 1 2 3 4))  ; simple default


; for ( (at robot loc20) (holding box3) )
;    pickup box3   :: holding @ 0 
;    goto loc17    :: at      @ 2
;    open door     :: open    @ 1
;    carry-thru    :: inroom  @ 3
;    goto loc20    :: at      @ 2
; no ops @ 5,4 =>
;                 (setq *k-list* '(0 0 1 3 4 5))  

(setq *top-down-levels*     
'( 5 4 3 2 1 0  ))

;******** NEW OPERATOR MOTIVATION LISTS **********
;
; invoke via switch :motive-discard t
;
; How SHOULD we NOT achieve each goal (via new establishers) ?

(setq *not-motive* '(
( (inroom robot $) ( push-thru-dr carry-thru-dr ) )
( (at     robot $) ( push-obj ) )
))


; goal/operator list for this domain / branching factor in brackets
;
;                                    New           Existing
;                                    Establisher   Establisher
;
; Note improper formulation of goals will result in an incomplete planner
;  due to restricting addition of operators in general
;  note that if we DO NOT restrict addition of operators for the top-leve 
;  preconditions, .... ???
;
;  ie if we have (at robot loc20) (holding obj3) at top level Goals
;   and loc20 is in a dif room that in I,
;    then the problem is that we will want to carry obj3 thru a door, but
;    we wbat to ignore carry-thry door for getting the robot to loc20.
;    We will lose the motivation for carry-thry early, and will never be
;    able to get it back.  
;

; Goal = (inroom robot ? )  [3] 
;  push-thru-dr                   ignore
;  go-thru-dr
;  carry-thru-dr                  ignore

; Goal = (inroom ? ? )      [2]
;  push-thru-dr             
;  carry-thru-dr           

;Goal = ( at robot ? )      [2]
;  goto-room-loc
;  push-obj                       ignore

; Goal = (at ? ?)           [3]
;  putdown (via a carry)
;  push-obj

; Goal = (holding  $)       [1]
;  pickup

; Goal = (open $)           [1]
;  open

; Goal = (not open $)       [1]
;  close
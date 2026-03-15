;***************************************************************************
; Strips ROBOT domain definition
;***************************************************************************
(setq *domain* 'robot)

; operators

; Pickup  OBJ when robot next to OBJ and OBJ can be carried
(setq o1 (make-operator
	 :opid 'pickup-obj
	 :name '(pickup-obj $obj $loc $room)
	 :preconditions '(
			  (armempty)
                          (is-location $loc)
                          (location-inroom $loc $room)
                          (inroom $robot $room)
			  (at robot    $loc)
			  (at $obj     $loc)
			  (carriable $obj)
			 )
	 :effects '(
                    (not armempty)
		    (holding $obj)
                    (not at $obj $loc)
                   )))

; Putdown  OBJ next-to robot 
(setq o2 (make-operator
	 :opid 'putdown
	 :name '(putdown $obj $loc $room)
	 :preconditions '(
                          (holding $obj)
                          (inroom robot $room)
                          (location-inroom $loc  $room)
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
                          (is-location $from)
                          (is-location $to)
                          (location-inroom  $from  $room)
                          (location-inroom  $to    $room)
                          (inroom robot $room)
                          (at robot $from)
			 )
	 :effects '(
                    (not at $robot $from)
                    (at $robot $to)
                   )))

; Push box to door leading to room
(setq o4 (make-operator
	 :opid 'push-to-dr
	 :name '(push-to-dr $door $room $box $door-strt-loc $door-end-loc $box-loc)
	 :preconditions '(
                          (is-object $box)
                          (pushable $box)
                          (is-door  $door $door-strt-loc $door-end-loc)
                          (dr-to-rm  $door $room)
                          (is-location $door-strt-loc)
                          (is-location $door-end-loc)
                          (is-location $box-loc)
                          (location-inroom  $box-loc       $room)
                          (location-inroom  $door-strt-loc $room)
                          (inroom  $robot         $room)
                          (at $box  $box-loc)
                          (at $door $door-strt-loc)
  		          (at robot $box-loc)
			 )
	 :effects '(
                    (not at robot $box-loc)
                    (not at $box  $box-loc)
                    (at $box  $door-strt-loc)
                    (at robot $door-strt-loc)
                   )))

; Push BOX through DOOR from ROOM2 to ROOM1
(setq o5 (make-operator
	 :opid 'push-thru-dr
	 :name '(push-thru-dr $box $door $room1 $room2 
                              $door-strt-loc $door-end-loc)
	 :preconditions '(
                          (is-room  $room1)
                          (pushable $box)
                          (is-door  $door $door-strt-loc $door-end-loc)
                          (dr-to-rm $door   $room1)                 
                          (open     $door)
                          (is-location $door-strt-loc)
                          (is-location $door-end-loc)
                          (location-inroom $door-strt-loc $room2)
                          (location-inroom $door-end-loc  $room1)
                          (inroom $robot $room2)
                          (inroom $box $room2)
                          (is-object $box)
  		          (at $box   $door-strt-loc)
  		          (at robot   $door-strt-loc)
                          (connects $door   $room1  $room2)
			 )
	 :effects '(
                    (not at $robot $door-loc)
                    (at robot $door-end-loc)
      		    (not at $box  $door-loc)
                    (at $box $door-end-loc)
                    (not inroom robot $room1)
                    (inroom robot $room2)
                    (not inroom $box $room1)
                    (inroom $box $room2)
                   )))

; GO through door from room2 to room1
(setq o6 (make-operator
	 :opid 'go-thru-dr
	 :name '(go-thru-dr $door $room1 $room2 $door-strt-loc $door-end-loc)
	 :preconditions '(
                          (armempty)
                          (is-room  $room1)
                          (dr-to-rm $door   $room1)                 
                          (is-door  $door $door-strt-loc $door-end-loc)
                          (open     $door)
                          (is-location $door-strt-loc)
                          (is-location $door-end-loc)
                          (location-inroom $door-strt-loc $room2)
                          (location-inroom $door-end-loc  $room1)
                          (inroom robot $room2)
  		          (at robot   $door-strt-loc)
                          (connects $door   $room1  $room2)
			 )
	 :effects '(
                    (not at robot $door-strt-loc)
                    (at robot $door-end-loc)           
                    (not inroom robot $room2)
                    (inroom robot $room1)
                   )))

; Carry B1 through door1 from room2 to room1
(setq o7 (make-operator
	 :opid 'carry-thru-dr
	 :name '(carry-thru-dr $box $door $room1 $room2 
                               $door-strt-loc $door-end-loc)
	 :preconditions '(
                          (is-room  $room1)
                          (dr-to-rm $door   $room1)                 
                          (is-door  $door $door-strt-loc $door-end-loc)
                          (open     $door)
                          (is-object $box)
                          (is-location $door-strt-loc)
                          (is-location $door-end-loc)
                          (connects $door   $room1  $room2)
                          (location-inroom $door-strt-loc $room2)
                          (location-inroom $door-end-loc  $room1)
  		          (holding $box)
                          (inroom robot $room2)
  		          (at robot   $door-strt-loc)
			 )
	 :effects '(
                    (not inroom robot $room1)
                    (inroom robot $room2)
                    (not inroom $box $room1)
                    (inroom $box $room2)
                    (not at $box $room2)
                    (at  $box $room1)           
                    (not at robot $room2)
                    (at  robot $room1)           
                   )))

; Go to Door D1 (in Room 1)
(setq o8 (make-operator
	 :opid 'goto-dr
	 :name '(goto-dr $door $room 
                         $door-strt-loc $door-end-loc $robot-strt-loc)
	 :preconditions '(
                          (is-door  $door $door-strt-loc $door-end-loc)
                          (is-location $door-strt-loc)
                          (is-location $door-end-loc)
                          (dr-to-rm $door $room)
                          (at robot $robot-strt-loc)
                          (location-inroom  $robot-strt-loc $room)
                          (location-inroom  $door-strt-loc  $room)
                          (inroom  robot $room)
			 )
	 :effects '(
                    (not at $robot $robot-strt-loc)
                    (at $robot $door-strt-loc)
                   )))

; Push B1 to B2 (in Room 1)
;
(setq o9 (make-operator
	 :opid 'push-box
	 :name '(push-box $box1 $box2 $room
                          $box-loc1 $box-loc2)
	 :preconditions '(
                          (is-object  $box1)
                          (is-object  $box2)
                          (at $box1 $box-loc1)
                          (at $box1 $box-loc2)
                          (is-location $box-loc1)
                          (is-location $box-loc2)
                          (at robot $box-loc1)
                          (location-inroom     $box-loc1 $room)
                          (location-inroom     $box-loc2 $room)
                          (inroom     robot $room)
                          (inroom     $box1 $room)
                          (inroom     $box2 $room)
                          (pushable   $box1)
			 )
	 :effects '(
                    (not at $robot $box-loc1)
                    (not at $box1  $box-loc1)
                    (at robot $box-loc2)
                    (at $box1 $box-loc2)
                   )))

; Go to Object B in ROOM
(setq o10 (make-operator
	 :opid 'goto-obj
	 :name '(goto-obj $obj $room $obj-loc $r-loc)
	 :preconditions '(
                          (is-object $obj)
                          (at $obj $obj-loc)
                          (at robot $r-loc)
                          (is-location $obj-loc)
                          (is-location $r-loc)
                          (location-inroom  $obj-loc  $room)
                          (location-inroom  $r-loc  $room)
                          (inroom robot $room)
                          (inroom $obj  $room)
			 )
	 :effects '(
                    (not at $robot $r-loc)
                    (at  robot $obj-loc)       
                   )))

; Open door
(setq o11 (make-operator
	 :opid 'open
	 :name '(open $door $door-strt-loc $door-end-loc $room)
	 :preconditions '(
                          (is-door  $door $door-strt-loc $door-end-loc)
                          (is-location $door-strt-loc)
                          (is-location $door-end-loc)
                          (at $door $door-strt-loc)
                          (location-inroom $door-strt-loc $room)
                          (inroom robot $room)
                          (is-location $door-strt-loc)
                          (at robot $door-strt-loc)       
                          (not open $door)
                          (not locked $door)
			 )
	 :effects '(
                    (open $door)
                   )))

; Close door
(setq o12 (make-operator
	 :opid 'close
	 :name '(close $door $door-strt-loc $door-end-loc $room)
	 :preconditions '(
                          (is-door  $door $door-strt-loc $door-end-loc)
                          (is-location $door-strt-loc)
                          (is-location $door-end-loc)
                          (location-inroom $door-strt-loc $room)
                          (inroom robot $room)
                          (at robot $door-strt-loc)       
                          (open $door)
			 )
	 :effects '(
                    (not open $door)
                   )))

; Lock door from Room  with Key1
(setq o13 (make-operator
	 :opid 'lock
	 :name '(lock $door $key1 $room $door-strt-loc $door-end-loc)
	 :preconditions '(
                          (is-door  $door $door-strt-loc $door-end-loc)
                          (is-location $door-strt-loc)
                          (is-location $door-end-loc)
                          (location-inroom $door-strt-loc $room)
                          (inroom robot $room)                        
                          (at robot $door-strt-loc)       
                          (is-key  $door $key1)
                          (holding $key1)
                          (door-to-rm $door $room)
                          (not open door)
                          (not locked $door)
			 )
	 :effects '(
                    (locked $door)
                   )))

; UnLock door from Room 1 with Key 1
(setq o14 (make-operator
	 :opid 'unlock
	 :name '(unlock $door $key1 $room)
	 :preconditions '(
                          (is-door  $door $door-strt-loc $door-end-loc)
                          (is-location $door-strt-loc)
                          (is-location $door-end-loc)
                          (at robot $door-strt-loc)       
                          (is-location $door-strt-loc)
                          (location-inroom $door-strt-loc   $room)
                          (inroom robot   $room)
                          (is-key  $door $key1)
                          (holding $key1)
                          (door-to-rm $door $room)
                          (locked $door)
			 )
	 :effects '(
                    (not locked $door)
                   )))

(setq *operators* (list o1 o2 o3 o4 o5 o6 o7 o8 o9 o10 o11 o12 o13 o14))

; initial state
;
(setq initial 
'(
    (armempty)
    
    (is-object block1)
    (is-object block2)
    (is-object key1)
    
    (is-door door1-2 p1 p4)
    (is-door door1-2 p4 p1)
    (dr-to-rm door1-2 room1)
    (dr-to-rm door1-2 room2)
    (connects door1-2 room1 room2)
    (connects door1-2 room2 room1)
    
    (is-room room1)
    (is-room room2)
    
    (carriable block1)
    (not carriable block2)
    (carriable key1)
    
    (not pushable block1)
    (pushable block2)
    (not pushable key1)    

    (is-key door1-2 key1)
    
    (open door1-2)
    (not locked door1-2)

    (is-location p1)
    (is-location p2)
    (is-location p3)
    (is-location p4)
    (is-location p5)
    (is-location p6)

    (location-inroom p1 room1)
    (location-inroom p2 room1)
    (location-inroom p3 room1)

    (location-inroom p4 room2)
    (location-inroom p5 room2)
    (location-inroom p6 room2)
    
    (at robot p5)
    (inroom robot room2)
    (at block1 p2)
    (inroom block1 room1)
    (at block2 p6)
    (inroom block2 room2)
    (at key1   p6)
    (inroom key1   room2)
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
   (5  (armempty) (not armempty) 
       (is-location $) (carriable $) (is-door $ $ $) (dr-to-rm $ $)
       (is-room $) (pushable $) (carriable $) (connects $ $ $) (is-object $)
       (is-key $ $) (location-inroom $ $) )
   (4  (inroom $ $) )
   (3  (at     $ $) )
   (2  (locked $) (not locked $) )
   (1  (open $) (not open $) )
   (0  (holding $) )
))

(setq *top-down-levels*     
'(
  3
  2
  1
))

;******** NEW OPERATOR MOTIVATION LISTS **********
;
; Unused as of Dec 11/1990
;
; How SHOULD we achieve each goal (via new establishers) ?

(setq *motive* '(
((armempty)      ( putdown ))
((not armempty)  ( pickup-obj ))
((holding)       ( pickup-obj ))
((at)            ( putdown  goto-room-loc push-to-dr push-thru-dr go-thru-dr 
                   carry-thru-dr goto-dr push-box goto-obj ))
((open)          ( open     ))
((not open)      ( close    ))
((locked)        ( lock     ))
((not locked)    ( unlock   ))
))

;***************************************************************************
; Strips ROBOT domain definition
;***************************************************************************
(setq *domain* 'robot)

; operators

; Pickup  OBJ when robot next to OBJ and OBJ can be carried
(setq o1 (make-operator
	 :opid 'pickup-obj
	 :name '(pickup-obj $obj $loc)
	 :preconditions '(
			  (armempty)
                          (is-location $loc)
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
	 :name '(putdown $obj $loc)
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
	 :name '(goto-room-loc $from $to)
	 :preconditions '(
                          (is-location $from)
                          (is-location $to)
                          (inroom  $from  $room1)
                          (inroom  $to    $room1)
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
                          (is-door  $door $door-strt-loc $door-end-loc)
                          (dr-to-rm  $door $room)
                          (is-location $door-strt-loc)
                          (is-location $door-end-loc)
                          (is-location $box-loc)
                          (inroom  $box-loc       $room)
                          (inroom  $door-strt-loc $room)
                          (is-object $box)
                          (at $box  $box-loc)
  		          (at robot $box-loc)
                          (at $door $door-strt-loc)
                          (pushable $box)
			 )
	 :effects '(
                    (not at robot $box-loc)
                    (not at $box  $box-loc)
                    (at $box  $door-strt-loc)
                    (at robot $door-strt-loc)
                   )))

; Push BOX1 through DOOR from ROOM2 to ROOM1
(setq o5 (make-operator
	 :opid 'push-thru-dr
	 :name '(push-thru-dr $box1 $door $room1 $room2 
                              $door-strt-loc $door-end-loc)
	 :preconditions '(
                          (is-room  $room1)
                          (dr-to-rm $door   $room1)                 
                          (is-door  $door $door-strt-loc $door-end-loc)
                          (open     $door)
                          (is-location $door-strt-loc)
                          (is-location $door-end-loc)
                          (inroom $door-strt-loc $room2)
                          (inroom $door-end-loc  $room1)
                          (is-object $box1)
  		          (at $box1   $door-strt-loc)
  		          (at robot   $door-strt-loc)
                          (pushable $box1)
                          (connects $door   $room1  $room2)
			 )
	 :effects '(
                    (not at $robot $door-loc)
      		    (not at $box1  $door-loc)
                    (at robot $door-end-loc)
                    (at $box1 $door-end-loc)
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
                          (inroom $door-strt-loc $room2)
                          (inroom $door-end-loc  $room1)
  		          (at robot   $door-strt-loc)
                          (connects $door   $room1  $room2)
			 )
	 :effects '(
                    (not at robot $door-strt-loc)
                    (at robot $door-end-loc)           
                   )))

; Carry B1 through door1 from room2 to room1
(setq o7 (make-operator
	 :opid 'carry-thru-dr
	 :name '(carry-thru-dr $box1 $door $room1 $room2 
                               $door-strt-loc $door-end-loc)
	 :preconditions '(
                          (is-room  $room1)
                          (dr-to-rm $door   $room1)                 
                          (is-door  $door $door-strt-loc $door-end-loc)
                          (open     $door)
                          (is-object $box1)
                          (is-location $door-strt-loc)
                          (is-location $door-end-loc)
                          (connects $door   $room1  $room2)
                          (inroom $door-strt-loc $room2)
                          (inroom $door-end-loc  $room1)
  		          (holding $box1)
  		          (at robot   $door-strt-loc)
			 )
	 :effects '(
                    (not at robot $room2)
                    (not at $box1 $room2)
                    (at  robot $room1)           
                    (at  $box1 $room1)           
                   )))

; Go to Door D1 (in Room 1)
(setq o8 (make-operator
	 :opid 'goto-dr
	 :name '(goto-dr $door $room1 
                         $door-strt-loc $door-end-loc $robot-strt-loc)
	 :preconditions '(
                          (is-door  $door $door-strt-loc $door-end-loc)
                          (is-location $door-strt-loc)
                          (is-location $door-end-loc)
                          (dr-to-rm $door $room1)
                          (inroom  $door-strt-loc  $room1)
                          (inroom  $robot-strt-loc $room1)
                          (at robot $robot-strt-loc)
			 )
	 :effects '(
                    (not at $robot $robot-strt-loc)
                    (at $robot $door-strt-loc)
                   )))

; Push B1 to B2 (in Room 1)
(setq o9 (make-operator
	 :opid 'push-box
	 :name '(push-box $box1 $box2 $room1
                          $box1-loc $box2-loc)
	 :preconditions '(
                          (is-object  $box1)
                          (is-object  $box2)
                          (at $box1 $box1-loc)
                          (at $box1 $box2-loc)
                          (is-location $box1-loc)
                          (is-location $box2-loc)
                          (inroom     $box1-loc $room1)
                          (inroom     $box2-loc $room1)
                          (pushable   $box1)
                          (at robot $box1-loc)
			 )
	 :effects '(
                    (not at $robot $box1-loc)
                    (not at $box1  $box1-loc)
                    (at robot $box2-loc)
                    (at $box1 $box2-loc)
                   )))

; Go to Object B in RM
(setq o10 (make-operator
	 :opid 'goto-obj
	 :name '(goto-obj $obj $rm $obj-loc $r-loc)
	 :preconditions '(
                          (is-object $obj)
                          (at $obj $obj-loc)
                          (at robot $r-loc)
                          (is-location $obj-loc)
                          (is-location $r-loc)
                          (inroom  $obj-loc  $rm)
                          (inroom  $r-loc  $rm)
			 )
	 :effects '(
                    (not at $robot $r-loc)
                    (at  robot $obj-loc)       
                   )))

; Open door
(setq o11 (make-operator
	 :opid 'open
	 :name '(open $door $door-strt-loc $door-end--loc)
	 :preconditions '(
                          (is-door  $door $door-strt-loc $door-end-loc)
                          (is-location $door-strt-loc)
                          (is-location $door-end-loc)
                          (not locked $door)
                          (at $door $door-strt-loc)
                          (is-location $door-strt-loc)
                          (at robot $door-strt-loc)       
                          (not open $door)
			 )
	 :effects '(
                    (open $door)
                   )))

; Close door
(setq o12 (make-operator
	 :opid 'close
	 :name '(close $door $door-strt-loc $door-end--loc)
	 :preconditions '(
                          (is-door  $door $door-strt-loc $door-end-loc)
                          (is-location $door-strt-loc)
                          (is-location $door-end-loc)
                          (at robot $door-strt-loc)       
                          (open $door)
			 )
	 :effects '(
                    (not open $door)
                   )))

; Lock door from Room 1 with Key 1
(setq o13 (make-operator
	 :opid 'lock
	 :name '(lock $door $key1 $room1 $door-strt-loc $door-end-loc)
	 :preconditions '(
                          (is-door  $door $door-strt-loc $door-end-loc)
                          (is-location $door-strt-loc)
                          (is-location $door-end-loc)
                          (at robot $door-strt-loc)       
                          (inroom $door-strt-loc   $room1)
                          (is-key  $door $key1)
                          (holding $key1)
                          (door-to-rm $door $room1)
                          (not locked $door)
			 )
	 :effects '(
                    (locked $door)
                   )))

; UnLock door from Room 1 with Key 1
(setq o14 (make-operator
	 :opid 'unlock
	 :name '(unlock $door $key1 $room1)
	 :preconditions '(
                          (is-door  $door $door-strt-loc $door-end-loc)
                          (is-location $door-strt-loc)
                          (is-location $door-end-loc)
                          (at robot $door-strt-loc)       
                          (is-location $door-strt-loc)
                          (inroom $door-strt-loc   $room1)
                          (is-key  $door $key1)
                          (holding $key1)
                          (door-to-rm $door $room1)
                          (locked $door)
			 )
	 :effects '(
                    (not locked $door)
                   )))

(setq *operators* (list o1 o2 o4 o5 o6 o7 o8 o9 o10 o11 o12 o13 o14))

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
    (not pushable key11)    

    (is-key door1-2 key1)
    
    (open door1-2)
    (not locked door1-2)

    (is-location p1)
    (is-location p2)
    (is-location p3)
    (is-location p4)
    (is-location p5)
    (is-location p6)

    (inroom p1 room1)
    (inroom p2 room1)
    (inroom p3 room1)

    (inroom p4 room2)
    (inroom p5 room2)
    (inroom p6 room2)
    
    (at robot p5)
    (at block1 p2)
    (at block2 p6)
    (at key1   p6)
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
   (2  (armempty) (not armempty) 
       (is-location $) (carriable $) (is-door $ $ $) (dr-to-rm $ $)
       (is-room $) (pushable $) (carriable $) (connects $ $ $) (is-object $)
       (is-key $ $) )
   (1  (at $ $) )
   (0  (holding $) (open $) (not open $) (locked $) (not locked $) (inroom $ $))
))

(setq *top-down-levels*     
'(
  2
  1
))

;******** NEW OPERATOR MOTIVATION LISTS **********
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

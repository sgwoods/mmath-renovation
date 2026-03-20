;PLANS - global variable used for testing
(setq plans '((a b c f g a)(a e f g a e r)(a b c d e f z)))
(setq ex2   '((a b c)(a c d e b)(b e f b c f b)))
(setq ex1   '((a b c a z)(a c d e b)(b e f b c f b)))

;PUTP (element property property_value)
;  assigns element the property with property value
(defun putp (x y z)
     (setf (get x y ) z))

;INIT_COUNT (element)
;  initializes the count property of element to value 0
(defun init_count (x)
     (putp x 'count '0))

;INC_COUNT (element)
;  increments the count property of element to previous value plus 1
(defun inc_count (x)
     (putp x 'count (+ 1 (get x 'count))))

;FRONT (element list)
;  adds element to the front of list (opposite of cons)
(defun front (e list)
    (reverse (cons e (reverse list))))

; PLAN_SET  (plan)
;   Return a unique action list given a plan as input
(defun plan_set (x)                            
    (unique x '()))
(defun unique (p s)
   (if (eq nil (cdr p))                        ;p has only one action
       (xisrt (car p) s)                       ;put single action into s
       (unique (cdr p) (xisrt (car p) s))))    ;put rest of stuff into p

;XISRT (element list)
;  Add element to a list only if element is not in list, return new list    
;  add to RIGHT end
(defun xisrt (x y)
    (if (member x y) 
        y                                      ;element already in list
        (front x y)))                          ;add element to front of list
;YISRT (element list)
;  add to LEFT end
(defun yisrt (x y)
    (if (member x y) 
        y                                      ;element already in list
        (cons x y)))                           ;add element to front of list
;UAPPEND (list1 list2)
;  Return the result of appending both lists, discarding unique elements
(defun uappend( list1 list2)
  (if (eq (car list1) nil) 
      list2
      (if (member (car list1) list2)
          (uappend (cdr list1) list2) 
          (uappend (cdr list1) (cons (car list1) list2))  )))

;COUNT_LIST (list of lists)
;  Calculate occurence of elements in lists, place results in
;  'count property of element, return action list from ALL plans
(defun count_list (x)
    (cond ((eq x nil) nil)                       
          (t (progn                            
                   (uappend (count (car x)) (count_list (cdr x)))))))
;COUNT (list)
;  Calculate occurence of elements in a list, place result in
;  'count property of element
;  As a side result, return the action_list: unique actions encountered
(defun count (x)   
   (cond ((eq x nil) nil)                       
         (t (progn
                   (if (eq nil (get (car x) 'count))  ;first element occurence
                       (init_count (car x))           ;set nil count to zero
                        t )                           ;not first occurence      
                   (inc_count (car x))                ;add 1 to element count
                   (yisrt (car x) (count (cdr x)))))))

;PIVOT (action_list)
;  Return most frequently occuring action as calculated in COUNT_LIST
(defun pivot (action_list)
     (maxi action_list 0 0))  ;initial max = 0, max element = dummy
;MAXI (action_list max_ocurences max_element)
;  Given a list of unique actions, find most frequent occurence in
;  as calculated in COUNT_LIST 
(defun maxi (action_list max maxelement)
     (cond ((eq action_list nil) maxelement)
           (t (progn 
                 (if (> (get (car action_list) 'count) max)
                     (progn 
                        (maxi (cdr action_list) 
                              (get (car action_list) 'count)
                              (car action_list)
                        );of maxi
                      );of progn
                     (maxi (cdr action_list) max maxelement)
                 );of if
               );of progn
            )of t
      );of cond
);of defun

; MAKE_LISTS (list of plans)
;  Given a list of plans, reduces them into a list of unique action lists
;   ie - for each plan gives a corresponding set of actions in that plan
(defun make_lists (p)
     (cond
          ( (eq (cdr p) nil) (list (plan_set (car p)) ) )
          ( t (append (list (plan_set (car p))) (make_lists (cdr p)) ) ) ) )

;THREAD (list of plans)
;  Given a list of plans, selects the action to use as a thread 
;  ie  selects the action occuring in the most plans 
;      (only counting an action once in any given plan)
(defun thread1 (plans)
   (progn
       (setq act_list (count_list (make_lists plans)))
       (setq thread (pivot act_list))
       thread
   ))
(defun thread2 (element)
   (progn
       (setq val (get thread 'count))
       (clear act_list)
       (setq act_list nil)
       val
   ))
(defun clear (list)
    (if (eq (cdr list) nil)
        (putp (car list) 'count '0)
        (progn 
              (putp (car list) 'count '0)
              (clear (cdr list))
        )))

;SPLIT_LEFT (list break)
;  Returns the portion of the list BEFORE the first break element, or
;  returns the whole list if element is not in the list
 (defun split_left (list break)
    (if (member break list)
        (bld '() list break)
        list))
(defun bld (left right break)
   (if (eq right nil)
       nil
       (if (eq (car right) break)
           left
           (bld (front (car right) left) (cdr right) break))))

;SPLIT_RIGHT (list break)
;  Returns the portion of the list AfTER the first break element, or
;  returns the nil list if element is not in list.
(defun split_right (list break)
     (if (eq (car list) break)
         (cdr list)
         (if (eq (car list) nil)
             nil
             (split_right (cdr list) break)  )))

;R_SPLINTER (plans break)
;  Returns the plan list splintered to the right of the first break element
(defun r_splinter (plans break)
    (if (eq (cdr plans) nil)
        (progn
            (setq ck (split_right (car plans) break))
            (if (eq ck nil)
                nil
                (list ck)
            )
         )
        (progn
            (setq ck (split_right (car plans) break))
            (if (eq ck nil)
                (append nil (r_splinter (cdr plans) break))
                (append (list ck) (r_splinter (cdr plans) break))))))

;L_SPLINTER (plans break)
;  Returns the plan list splintered to the left of the first break element
(defun l_splinter (plans break)
    (if (eq (cdr plans) nil)
        (progn
            (setq ck (split_left (car plans) break))
            (if (eq ck nil)
                nil
                (list ck)
            )
         )            
        (progn
            (setq ck (split_left (car plans) break))
            (if (eq ck nil)
                (append nil (l_splinter (cdr plans) break))
                (append (list ck) (l_splinter (cdr plans) break ))
            ) ;of if
         ) ;of progn
      ) ; of if
);of defun

;COLLAPSE (number element)
;  Returns a list containing number of element, if number =1, returns element
(defun collapse (number element)
     (collapse1 number element '()))
(defun collapse1 (number element list)
     (if (= number 0)
         nil
         (if (= number 1)
             element
              (dotimes (count number list)
                   (setq list (cons element list)) ))))

;MERGE (plan_list)
;  Returns the merged plan based on the simple heuristic of most
;  frequent plan action 
(defun merge (plan_list)
    (merge1 (reverse plan_list)))
(defun merge1 (plan_list)
    (progn
         (setq num_plans (length plan_list))
         (cond
              ( (= num_plans 0)  nil)
              ( (= num_plans 1) (car plan_list))
              ( (> num_plans 1) 
                        (progn
                         (let (thr occ) 
                           (setq thr (thread1 plan_list))
                           (setq occ (thread2 thr)) 
                           (append 
;                                   (break "before left_splint" plan_list)
                                   (merge1 (l_splinter plan_list thr))
;                                   (break "before collapse" plan_list)
                                   (list (collapse occ thr))
;                                   (break "before rt_splint" plan_list)
                                   (merge1 (r_splinter plan_list thr))
;                                   (break "after rt_splint" plan_list)
                           ) ;of append
                         ); of let
                        );of progn
              );of case 3
         );of cond
    );of progn
 );of defun

; ********************************************************************
;  THIS SECTION CONTAINS TEST ROUTINES ONLY
; ********************************************************************

;TTHREAD
;  Test thread functions
(defun tthread (plan)
    (progn
          (setq x (thread1 plan))
          (setq val (thread2 x))
          (print x)
          (print val)
          (print (get x 'count))  ; should be zero
          'test_done              ; return test_done when done
    ))

;CK (plan_list)
;  Prints out the most common element in each plan, and occurences
(defun ck (list)
   (if (eq (cdr list) nil)
       (progn  ;CASE 1 - no more elements after current one
           (setq x (thread1 list))
           (setq val (thread2 x))
           (print x)                     ;print element
           (print val)                   ;print count
           'CK_TEST_DONE
       )
       (progn
           (setq x (thread1 list))
           (setq val (thread2 x))
           (print x)                     ;print element
           (print val)                   ;print count
           (ck (cdr list))               ;ck rest of list
       )
    )
)

;THREAD_OLD
;  Previous version of thread which leaves 'count values instantiated
(defun thread_old (plans)
   (pivot (count_list (make_lists plans))))

;OLD_LEFT_SPLINTER
(defun ls (plans break)
    (if (eq (cdr plans) nil)
        (list (split_left (car plans) break))
        (append (list (split_left (car plans) break))
                (ls (cdr plans) break))))

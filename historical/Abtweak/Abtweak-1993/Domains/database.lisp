;***************************************************************************
; SQL world domain definition
;
; f* -- states for field variable.
; t* -- states for table variable.
; s  -- states for string variable.
;
; Implemented by Y.L. Wang.  July, 1991
;
;  Note:  this domain doesn't work with Abtweak.  Use:  
;  (plan init goal :planner-mode 'tweak)
;
;***************************************************************************
(setq *domain* 'SQL-world)

; operators

(setq a1 (make-operator
	 :opid 'project1
	 :name '(project on $f1)
         :cost 1
	 :preconditions '(
                          (not empty RESULT)
                          (contains RESULT $f1)
                          (is-field $f1)
                          (not explicit $f1)
                          (not finished RESULT)
                         )
	 :effects       '(
                          (explicit $f1)
                          (num-explicit 1)
                          (finished RESULT)
                         )))

(setq a2 (make-operator
	 :opid 'project2
	 :name '(project on $f1 $f2)
         :cost 1
	 :preconditions '(
                          (not empty RESULT)
                          (contains RESULT $f1)
                          (contains RESULT $f2)
                          (is-field $f1)
                          (is-field $f2)
                          (not explicit $f1)
                          (not explicit $f2)
                          (not finished RESULT)
                         )
	 :effects       '(
                          (explicit $f1)
                          (explicit $f2)
                          (num-explicit 2)
                          (finished RESULT)
                         )))

(setq a3 (make-operator
	 :opid 'project3
	 :name '(project on $f1 $f2 $f3)
         :cost 1
	 :preconditions '(
                          (not empty RESULT)
                          (contains RESULT $f1)
                          (contains RESULT $f2)
                          (contains RESULT $f3)
                          (is-field $f1)
                          (is-field $f2)
                          (is-field $f3)
                          (not explicit $f1)
                          (not explicit $f2)
                          (not explicit $f3)
                          (not finished RESULT)
                         )
	 :effects       '(
                          (explicit $f1)
                          (explicit $f2)
                          (explicit $f3)
                          (num-explicit 3)
                          (finished RESULT)
                         )))


(setq b1 (make-operator
         :opid 'select1
         :name '(select $t $f1 = $s)
         :cost 1
         :preconditions '(
                          (is-table $t)
                          (is-field $f1)
                          (contains $t $f1)
                          (is-constant $s)
                          (cond-for $t $f1 $s)
                          (num-field $t 1)


                          (not joined $t)
                          (not finished RESULT)
                         )
         :effects '(
                    (not empty RESULT)
                    (contains RESULT $f1)
                    (with-cond $t $f1 $s)
                    (with-cond RESULT $f1 $s)
                   )))

(setq b2 (make-operator
         :opid 'select2
         :name '(select $t $f2 $f1 = $s)
         :cost 1
         :preconditions '(
                          (is-table $t)
                          (is-field $f1)
                          (is-field $f2)
                          (contains $t $f1)
                          (contains $t $f2)
                          (is-constant $s)
                          (cond-for $t $f1 $s)
                          (num-field $t 2)


                          (not joined $t)
                          (not finished RESULT)
                         )
         :effects '(
                    (not empty RESULT)
                    (contains RESULT $f1)
                    (contains RESULT $f2)
                    (with-cond $t $f1 $s)
                    (with-cond RESULT $f1 $s)
                   )))

(setq b3 (make-operator
         :opid 'select3
         :name '(select $t $f2 $f3 $f1 = $s)
         :cost 1
         :preconditions '(
                          (is-table $t)
                          (is-field $f1)
                          (is-field $f2)
                          (is-field $f3)
                          (contains $t $f1)
                          (contains $t $f2)
                          (contains $t $f3)
                          (is-constant $s)
                          (cond-for $t $f1 $s)
                          (num-field $t 3)


                          (not joined $t)
                          (not finished RESULT)
                         )
         :effects '(
                    (not empty RESULT)
                    (contains RESULT $f1)
                    (contains RESULT $f2)
                    (contains RESULT $f3)
                    (with-cond $t $f1 $s)
                    (with-cond RESULT $f1 $s)
                   )))


(setq c3 (make-operator
         :opid 'join1
         :name '(join $t1 $f1-2 $f1-3 < $comm-f > $f2-2 $f2-3 $t2)
         :cost 1
         :preconditions '(
                          (is-table $t1)
                          (contains $t1 $comm-f)
                          (contains $t1 $f1-2)
                          (contains $t1 $f1-3)
                          (is-field $comm-f)
                          (is-field $f1-2)
                          (is-field $f1-3)
                          (num-field $t1 3)
                   
                          (is-table $t2)
                          (contains $t2 $comm-f)
                          (contains $t2 $f2-2)
                          (contains $t2 $f2-3)
                          (is-field $f2-2)
                          (is-field $f2-3)
                          (num-field $t2 3)
                    
                          (not finished RESULT)
                         )
         :effects '(
                          (not empty RESULT)
                          (contains RESULT $comm-f)
                          (contains RESULT $f1-2)
                          (contains RESULT $f1-3)
                          (contains RESULT $f2-2)
                          (contains RESULT $f2-3)

                          (joined $t1)
                          (joined $t2)
                   )))

(setq d3 (make-operator
         :opid 'choose3
         :name '(choose $t $f1 $f2 $f3)
         :cost 1
         :preconditions '(
                          (is-table $t)
                          (empty RESULT)
                          (contains $t $f1)
                          (contains $t $f2)
                          (contains $t $f3)
                          (is-field $f1)
                          (is-field $f2)
                          (is-field $f3)
                          (num-field $t 3)

                          (not joined $t)
                          (not finished RESULT)
                          (just-proj $t)
                         )
         :effects       '(
                          (not empty RESULT)
                          (contains RESULT $f1)
                          (contains RESULT $f2)
                          (contains RESULT $f3)
                         )))

;=======================================================================

(setq *operators* (list  a1 a2 a3 b1 b2 b3 c3 d3))

;=======================================================================




;=======================================================================
; query 0:
;
;SELECT surname, initials
;FROM   STUDENT
;=======================================================================
;
(setq init0   '(
                (is-table STUDENT)
                (not joined STUDENT)

                (is-field studnum)
                (is-field surname)
                (is-field initials)

                (contains STUDENT studnum)
                (contains STUDENT surname)
                (contains STUDENT initials)

                (num-field STUDENT 3)

                (not explicit studnum)
                (not explicit surname)
                (not explicit initials)

                (empty RESULT)
                (not finished RESULT)
                (just-proj STUDENT)
               ))

(setq goal0 '(
             (finished RESULT)
             (not empty RESULT)

             (explicit surname)
             (explicit initials)
             (num-explicit 2)
            ))


;=======================================================================
; query 1:
;
;SELECT surname, initials
;FROM   STUDENT 
;WHERE  surname = 'MILLER'
;=======================================================================
;
(setq init1   '(
                (is-table STUDENT)
                (not joined STUDENT)

                (is-field studnum)
                (is-field surname)
                (is-field initials)

                (contains STUDENT studnum)
                (contains STUDENT surname)
                (contains STUDENT initials)
 
                (num-field STUDENT 3)

                (not explicit studnum)
                (not explicit surname)
                (not explicit initials)

                (empty RESULT)
             
                (is-constant MILLER)
                (cond-for STUDENT surname MILLER)

                (not finished RESULT)
               ))


(setq goal1 '(
             (finished RESULT)
             (not empty RESULT)

             (explicit surname)
             (explicit initials)
             (num-explicit 2)

             (with-cond STUDENT surname MILLER)

             (with-cond RESULT surname MILLER)
            ))



;=======================================================================
; query 2:
;
;SELECT surname, initials
;FROM   STUDENT 
;WHERE  surname = 'MILLER' AND studnum = 'N12345'
;=======================================================================
;
(setq init2   '(
                (is-table STUDENT)
                (not joined STUDENT)

                (is-field studnum)
                (is-field surname)
                (is-field initials)

                (contains STUDENT studnum)
                (contains STUDENT surname)
                (contains STUDENT initials)
 
                (num-field STUDENT 3)

                (not explicit studnum)
                (not explicit surname)
                (not explicit initials)

                (empty RESULT)
             
                (is-constant MILLER)
                (is-constant N12345)
                (cond-for STUDENT surname MILLER)
                (cond-for STUDENT studnum N12345)

                (not finished RESULT)
               ))


(setq goal2 '(
             (finished RESULT)
             (not empty RESULT)

             (explicit surname)
             (explicit initials)
             (num-explicit 2)

             (with-cond STUDENT surname MILLER)
             (with-cond STUDENT studnum N12345)

             (with-cond RESULT surname MILLER)
             (with-cond RESULT studnum N12345)
            ))


;=======================================================================
; query 3:
;
;SELECT surname, course, section
;FROM   STUDENT S, REGISTER R
;WHERE  S.studnum = R.studnum
;=======================================================================
(setq init3 '(
                (is-table STUDENT)
                (is-table REGISTER)
                (not joined STUDENT)
                (not joined REGISTER)

                (is-field studnum)
                (is-field surname)
                (is-field initials)
                (is-field course)
                (is-field section)

                (contains STUDENT studnum)
                (contains STUDENT surname)
                (contains STUDENT initials)
               
                (num-field STUDENT 3)

                (contains REGISTER studnum)
                (contains REGISTER course)
                (contains REGISTER section)
                
                (num-field REGISTER 3)
               
                (not explicit studnum)
                (not explicit surname)
                (not explicit initials)
                (not explicit course)
                (not explicit section)

                (empty RESULT)

                (not finished RESULT)
               ))


(setq goal3 '(
             (finished RESULT)
             (not empty RESULT)

             (contains RESULT studnum)
             (contains RESULT surname)
             (contains RESULT initials)
             (contains RESULT course)
             (contains RESULT section)
 
             (explicit surname)
             (explicit course)
             (explicit section)

             (num-explicit 3)
                          
             (joined STUDENT)
             (joined REGISTER)
            ))


;=======================================================================
; query 4:
;
;SELECT surname, course, section
;FROM   STUDENT S, REGISTER R
;WHERE  S.surname = 'MILLER' and S.studnum = R.studnum
;=======================================================================

(setq init4 '(
                (is-table STUDENT)
                (is-table REGISTER)
                (not joined STUDENT)
                (not joined REGISTER)

                (is-field studnum)
                (is-field surname)
                (is-field initials)
                (is-field course)
                (is-field section)

                (contains STUDENT studnum)
                (contains STUDENT surname)
                (contains STUDENT initials)

                (num-field STUDENT 3)

                (contains REGISTER studnum)
                (contains REGISTER course)
                (contains REGISTER section)

                (num-field REGISTER 3)

                (not explicit studnum)
                (not explicit surname)
                (not explicit initials)
                (not explicit course)
                (not explicit section)

                (empty RESULT)

                (is-constant MILLER)
                (cond-for STUDENT surname MILLER)

                (not finished RESULT)
               ))

(setq goal4 '(
             (finished RESULT)
             (not empty RESULT)

             (contains RESULT studnum)
             (contains RESULT surname)
             (contains RESULT initials)
             (contains RESULT course)
             (contains RESULT section)

             (explicit surname)
             (explicit course)
             (explicit section)

             (num-explicit 3)

             (with-cond STUDENT surname MILLER)
   ;          (with-cond RESULT surname MILLER)

             (joined STUDENT)
             (joined REGISTER)
            ))



;=======================================================================
; query 5:
;
;SELECT surname, course, hours
;FROM   STUDENT == REGISTER == COURSE
;WHERE  surname = 'MILLER' 
;=======================================================================

(setq init5 '(
                (is-table STUDENT)
                (is-table REGISTER)
                (is-table COURSE)
                (not joined STUDENT)
                (not joined REGISTER)
                (not joined COURSE)

                (is-field studnum)
                (is-field surname)
                (is-field initials)
                (is-field course)
                (is-field section)
                (is-field credit)
                (is-field hours)

                (contains STUDENT studnum)
                (contains STUDENT surname)
                (contains STUDENT initials)

                (num-field STUDENT 3)

                (contains REGISTER studnum)
                (contains REGISTER course)
                (contains REGISTER section)

                (num-field REGISTER 3)

                (contains COURSE course)
                (contains COURSE credit)
                (contains COURSE hours)

                (num-field COURSE 3)

                (not explicit studnum)
                (not explicit surname)
                (not explicit initials)
                (not explicit course)
                (not explicit section)
                (not explicit credit)
                (not explicit hours)

                (empty RESULT)

                (is-constant MILLER)
                (cond-for STUDENT surname MILLER)

                (not finished RESULT)
               ))

(setq goal5 '(
             (finished RESULT)
             (not empty RESULT)

             (contains RESULT studnum)
             (contains RESULT surname)
             (contains RESULT initials)
             (contains RESULT course)
             (contains RESULT sect)
             (contains RESULT credit)
             (contains RESULT hours)

             (explicit surname)
             (explicit course)
             (explicit hours)

             (num-explicit 3)

             (with-cond STUDENT surname MILLER)
             (with-cond RESULT surname MILLER)

             (joined STUDENT)
             (joined REGISTER)
             (joined COURSE)
            ))


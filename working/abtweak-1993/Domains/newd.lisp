From josh@cs.rochester.edu Mon Feb  3 17:32:02 1992
Received: from watdragon.waterloo.edu by logos.waterloo.edu with SMTP
	id <AA00359>; Mon, 3 Feb 92 17:32:01 -0500
Received: from cayuga.cs.rochester.edu by watdragon.waterloo.edu with SMTP
	id <AA19794>; Mon, 3 Feb 92 17:31:36 -0500
Received: from sol.cs.rochester.edu by cayuga.cs.rochester.edu (5.61/w) id AA11726; Mon, 3 Feb 92 17:30:21 -0500
Received: from teak.cs.rochester.edu by sol.cs.rochester.edu (4.1/w) id AA08041; Mon, 3 Feb 92 17:30:15 EST
Message-Id: <9202032230.AA08041@sol.cs.rochester.edu>
To: qyang@watdragon, knoblock@isi.edu
Subject: [barrett@cs.washington.edu: ] Domains!
Date: Mon, 03 Feb 92 17:30:14 -0500
From: "Josh D. Tenenberg" <josh@cs.rochester.edu>
Status: RO


I heard from Tony Barrett.  He sends the following list of domains.
Perhaps we can all look them over in the next week and see if there
is anything worth working with here.

Josh

------- Forwarded Message

Replied: Mon, 03 Feb 92 17:29:21 -0500
Replied: "barrett@cs.washington.edu "
Return-Path: barrett@cs.washington.edu
Received: from cayuga.cs.rochester.edu by sol.cs.rochester.edu (4.1/w) id AA07155; Sun, 2 Feb 92 18:33:22 EST
Received: from hake.cs.washington.edu by cayuga.cs.rochester.edu (5.61/w) id AA06493; Sun, 2 Feb 92 18:33:10 -0500
Received: by hake.cs.washington.edu (5.64a/7.0cr)
	id AA09990; Sun, 2 Feb 92 15:33:08 -0800
Date: Sun, 2 Feb 92 15:33:08 -0800
From: barrett@cs.washington.edu
Return-Path: <barrett@cs.washington.edu>
Message-Id: <9202022333.AA09990@hake.cs.washington.edu>
To: josh@cs.rochester.edu

Josh,

Here are copies of all of the domains that I have worked with.  Thanks for
your comments on our TR.  Right now I am clearing up my understanding of how
Korf's paper applies to regression planning.  It is interesting that with the
correct redefinition of "state", "subgoal", and "operator" we can map all of
Korf's work into our framework.  I think we finally have good definitions of
what independence, serializability, nonserializablilty... means in the context
of regression planning.  Would you like to see our working definitions?

- -Tony

Domains-follow-----------------------------------------------------------
(in-package 'snlp)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; The following code defines some artificial domains for evaluating
;;; partial and total order planners.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun PERMUTE (list)
  (let ((l (copy-list list))
        (ret nil))
    (do ()
        ((null l) ret)
      (let ((i (random (length l))))
        (push (nth i l) ret)
        (setf l (delete (nth i l) l))))))

(defun RAND-ART (cycles)
  (setq *old-stats* *stats*)
  (setq *stats* nil)
  (format t "~%~%~%Randomized Artificial World Test on ~a~%" (today))
  (let ((is '((a i x) (b i x) (c i x) (d i x) (e i x) (f i x) (g i x)
              (h i x) (i i x) (j i x)
              (a1 i x) (a2 i x) (a3 i x) (a4 i x) (a5 i x)
              ))
        (gs '((j g x) (i g x) (h g x) (g g x) (f g x) (e g x)
	      (d g x) (c g x) (b g x) (a g x)
              (a1 g x) (a2 g x) (a3 g x) (a4 g x) (a5 g x))))
    (dotimes (c cycles)
      (setq is (permute is))
      (dotimes (i 15)                              ; was: (length gs)
        (let ((goals (permute (subseq  gs 0 (1+ i))))
              (test (+ 1 i (* c (length gs)))))
          (format t "~%~%;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;")
          (format t "~%Goal     : ~a ~%" goals)
          (format t "~%SNLP (~a):~%" test)
          (system::gc t)
          (multiple-value-bind (plan-t mct-stat)
              (plan is goals)
            (print-snlp plan-t)
            (print-stat mct-stat)))))))

;;; This test uses a domain of totally non-interacting steps.  The plans
;;; produced consist of 2 clink long causal chains.  None of the clinks
;;; ever get threatened.

(defun ART0D (cycles)
  (reset-domain)
  (let ((symbols '(a7 a6 a5 a4 a3 a2 a1 a b c d e f g h i j)))
    (do ((a symbols (cdr a)))
	((null a) nil)
      (let ((b (car a)))
	(defstep :action `(,b ?x)
	  :precond `((,b i ?x))
	  :add `((,b g ?x))))))
  (rand-art cycles))

;;; The goals in this test are serializable.  Not only are they serializable,
;;; but all subsets are serializable too.  The plans once again consist of
;;; 2 clink long causal chains, but now the (* i ?x) clinks get threatened.

(defun ARTMD (cycles)
  (reset-domain)
  (let ((symbols '(a7 a6 a5 a4 a3 a2 a1 a b c d e f g h i j)))
    (do ((a symbols (cdr a)))
	((null a) nil)
      (let ((b (car a)))
	(defstep :action `(,b ?x)
	  :precond `((,b i ?x))
	  :add `((,b g ?x))
	  :dele (mapcar #'(lambda (x) `(,x i ?x)) (cdr a))))))
  (rand-art cycles))

;;; The goals in this test are nonserializable.  Also, each subset is 
;;; nonserializable too.  The plans now consist of 3 clink long causal
;;; chains.

(defun ARTMDns (cycles)
  (reset-domain)
  (let ((symbols '(a7 a6 a5 a4 a3 a2 a1 a b c d e f g h i j)))
    (do ((a symbols (cdr a)))
	((null a) nil)
      (let ((b (car a)))
	(defstep :action `(,b 1 ?x)
	  :precond `((,b i ?x))
	  :add `((,b - ?x))
	  :dele (mapcar #'(lambda (x) `(,x i ?x)) (cdr a)))
	(defstep :action `(,b 2 ?x)
	  :precond `((,b - ?x))
	  :add `((,b g ?x))
	  :dele (append (mapcar #'(lambda (x) `(,x - ?x)) (cdr a))
			(mapcar #'(lambda (x) `(,x i ?x)) symbols))))))
  (rand-art cycles))

;;; The goals in this test are serializable like in ARDMD, but now it is 
;;; possible for subsets to be independent.  The plans once again consist of
;;; 2 clink long causal chains, but now each (* i ?x) clink gets threatened
;;; by exactly one step.

(defun ART1D (cycles)
  (reset-domain)
  (let ((symbols '(a7 a6 a5 a4 a3 a2 a1 a b c d e f g h i j)))
    (do ((a symbols (cdr a)))
	((null a) nil)
      (let ((b (car a))
	    (c (if (cdr a) (cadr a) nil)))
	(defstep :action `(,b ?x)
	  :precond `((,b i ?x))
	  :add `((,b g ?x))
	  :dele (if c `((,c i ?x)) nil)))))
  (rand-art cycles))

;;; The goals in this test are nonserializable like in ARDMDNS, but now it is 
;;; possible for subsets to be independent.  The plans once again consist of
;;; 3 clink long causal chains.

(defun ART1Dns (cycles)
  (reset-domain)
  (let ((symbols '(a7 a6 a5 a4 a3 a2 a1 a b c d e f g h i j)))
    (do ((a symbols  (cdr a)))
	((null a) nil)
      (let ((b (car a))
	    (c (if (cdr a) (cadr a) nil)))
	(defstep :action `(,b 1 ?x)
	  :precond `((,b i ?x))
	  :add `((,b - ?x))
	  :dele (if c `((,c i ?x)) nil))
	(defstep :action `(,b 2 ?x)
	  :precond `((,b - ?x))
	  :add `((,b g ?x))
	  :dele (if c `((,c - ?x))
		   (mapcar #'(lambda (x) `(,x i ?x)) symbols))))))
  (rand-art cycles))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Ratinsulin problem (molecular genetics)
;;;   References: Stefik's AIJ paper
;;;               Science 196 (June 1977) pg 1313
;;;               Scientific American (April 1980) pg 74
;;;
;;;   Comments:   Note how the planning problem contains variables.  
;;;
;;;               The planner produces the appropriate plan, but the
;;;               representation of how molecules get cleaved and ligated
;;;               is simplistic.  The use of a "pure" predicate
;;;               to denote the purity of a culture is another simplification.
;;;               Finally, the number of domain facts (initial conditions)
;;;               is rather impoverished.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun test7 ()
  (reset-domain)
  (defstep :action '(reverse-transcribe ?x)    ; make cDNA
    :precond '((mRNA ?x))
    :add     '((cDNA ?x) (connected-cDNA-mRNA ?x))
    :dele    nil)
  (defstep :action '(separate ?x)              ; Separate cDNA from mRNA
    :precond '((cDNA ?x)(connected-cDNA-mRNA ?x))
    :add     '((single-strand ?x))
    :dele    '((connected-cDNA-mRNA ?x)))
  (defstep :action '(polymerize ?x)            ; Turn cDNA into a double strand
    :precond '((cDNA ?x)(single-strand ?x))
    :add     '((hair-pin ?x))
    :dele    '((single-strand ?x)))
  (defstep :action '(digest ?x)    ; make cDNA ; Get rid of the hairpin end
    :precond '((cDNA ?x)(hair-pin ?x))         ; This makes a gene
    :add     '((double-strand ?x))
    :dele    '((hair-pin ?x)))
  (defstep :action '(ligate LINKER ?y)         ; prep a gene for linking
    :precond '((cDNA ?y) (double-strand ?y))
    :add     '((cleavable ?y))
    :dele    nil)
  (defstep :action '(cleave ?x)                ; prep molecule ?x for splicing
    :precond '((cleavable ?x))
    :add     '((cleaved ?x))
    :dele    '((cleavable ?x)))
  (defstep :action '(ligate ?x ?y)             ; put gene ?x into DNA ?y
    :precond '((cleaved ?x) (cleaved ?y))
    :add     '((contains ?x ?y)(cleavable ?y))
    :dele    '((cleaved ?x) (cleaved ?y))
    :equals  '((not (?x ?y))))
  (defstep :action '(screen ?x ?z)             ; purify germ ?x antibiotic ?z
    :precond '((contains ?y ?x)                ;   Dna strand ?y confers
               (resists ?z ?y))                ;   resistence to ?z
    :add     '((pure ?x))
    :dele    nil
    :equals  '((not (?x ?y))(not (?y ?z))(not (?x ?z))))
  (defstep :action '(transform ?x ?y) ; add DNA molecule ?x to organism ?y
    :precond '((accepts ?x ?y) ; Is molecule accepted?
               (bacterium ?y)  ; must be a bacterium
               (cleavable ?x)) ; molecule must be whole
    :add     '((contains ?x ?y))
    :dele    '((cleavable ?x))   ; cannot cleave ?x when in cell
    :equals  '((not (?x ?y))))
;;; Code for experimenting with goal priorities (Knoblock predicate dropping
;;; abstraction techninques).
;  (dolist (l '((gene 0) (resists 0) (accepts 0) (bacterium 0)
;              (cleaved 1) (cleavable 0) (contains 2) (pure 2)))
;    (setf (getf (symbol-plist (car l)) 'priority) (cadr l)))
  (plan '((mRNA insulin-gene)
          (cleavable e-coli-exosome)
          (cleavable junk-exosome)
          (accepts junk-exosome junk)
          (accepts e-coli-exosome e-coli)
          (bacterium e-coli)
          (bacterium junk)
          (resists antibiotic-1 e-coli-exosome))
        '((contains insulin-gene ?x)
          (contains ?x ?y)
          (bacterium ?y)
          (pure ?y))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; The tower of hanoi problem.  
;;; SNLP really has problems solving this one!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun init (numdisks)
  (let* ((disks (subseq '(d1 d2 d3 d4 d5 d6 d7 d8 d9) 0 numdisks))
         (sizes (nconc (mapcar #'(lambda (d) `(smaller ,d p1)) disks)
                       (mapcar #'(lambda (d) `(smaller ,d p2)) disks)
                       (mapcar #'(lambda (d) `(smaller ,d p3)) disks)
                       (mapcon
                        #'(lambda (d)
                            (mapcar #'(lambda (d2)
                                        `(smaller ,(car d) ,d2))
                                    (cdr d)))
                        disks)))
         (initial (append '((clear p1)(clear p2)(clear d1))
                          (maplist
                           #'(lambda (d)
                               (if (cdr d)
                                   `(on ,(car d) ,(cadr d))
                                   `(on ,(car d) p3)))
                           disks))))
    (nconc sizes initial)))

(defun goal (numdisks)
  (let* ((disks (subseq '(d1 d2 d3 d4 d5 d6 d7 d8 d9) 0 numdisks)))
    (maplist #'(lambda (d)
                  (if (cdr d)
                      `(on ,(car d) ,(cadr d))
                      `(on ,(car d) p1)))
              disks)))

(defun hanoi (n)
  (reset-domain)
  (defstep :action '(move-disk ?disk ?below-disk ?new-below-disk)
    :precond '((on ?disk ?below-disk)
               (clear ?disk)
               (clear ?new-below-disk)
               (smaller ?disk ?new-below-disk)  ;handles pegs!
               )
    :add '((clear ?below-disk)
           (on ?disk ?new-below-disk))
    :dele '((on ?disk ?below-disk)
            (clear ?new-below-disk))
    :equals '((not (?new-below-disk ?below-disk))
              (not (?new-below-disk ?disk))
              (not (?below-disk ?disk))
              ))
  (plan (init n) (goal n) #'rank1))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Sussman Anomally
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun blocks-world-domain ()
  ;; purge old domain prior to defining a new domain
  (reset-domain)
  
  ;; Define step for putting a block on the table.
  (defstep :action '(newtower ?x)
    :precond  '((on ?X ?Z) (clear ?X))
    :add    '((on ?X Table) (clear ?Z))
    :dele   '((on ?X ?Z))
    :equals '((not (?X ?Z)) (not (?X Table)) (not (?Z Table))))

  ;; Define step for placing one block on another.
  (defstep :action '(move ?X ?Y)
    :precond '((on ?X ?Z) (clear ?X) (clear ?Y))
    :add     '((on ?X ?Y) (clear ?Z))
    :dele    '((on ?X ?Z) (clear ?Y))
    :equals  '((not (?X ?Y)) (not (?X ?Z)) (not (?Y ?Z))
	       (not (?X Table)) (not (?Y Table)))))

(defun sussman-anomally ()
  (blocks-world-domain)
  (plan '((on C A) (on A Table) (on B Table) (clear C) (clear B))
	'((on A B) (on B C))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Scheduling world
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun scheduling-world-domain ()
  ;; purge old domain prior to defining a new domain
  (reset-domain)
  
  (defstep
      :action '(POLISH ?x ?t)
    :precond '((temperature ?x cold)
	       (last-scheduled ?x ?prev)
	       (later ?t ?prev)
	       (idle polisher ?t)
	       (surface-condition ?x ?oldsurf))
    :add '((surface-condition ?x polished)
	   (last-scheduled ?x ?t)
	   (scheduled ?x polisher ?t))
    :dele '((surface-condition ?x ?oldsurf)
	    (idle polisher ?t)
	    (last-scheduled ?x ?prev)))
  
  (defstep
      :action '(ROLL ?x ?t)
    :precond '((last-scheduled ?x ?prev)
	       (later ?t ?prev)
	       (idle roller ?t)
	       (shape ?x ?oldshape)
	       (temperature ?x ?oldtemp)
	       (surface-condition ?x ?oldsurf)
	       (painted ?x oldpaint)
	       (has-hole ?x ?oldwidth ?old-orient))
    :add '((temperature ?x hot)
	   (shape ?x cylindrical)
	   (last-scheduled ?x ?t)
	   (scheduled ?x roller ?t))
    :dele '((shape ?x ?oldshape)
	    (temperature ?x ?oldtemp)
	    (surface-condition ?x ?oldsurf)
	    (painted ?x oldpaint)
	    (has-hole ?x ?oldwidth ?old-orient)
	    (idle roller ?t)
	    (last-scheduled ?x ?prev)))
  
  (defstep
      :action '(LATHE ?x ?t)
    :precond '((last-scheduled ?x ?prev)
	       (later ?t ?prev)
	       (idle lathe ?t)
	       (shape ?x ?oldshape))
    :add '((surface-condition ?x rough)
	   (shape ?x cylindrical)
	   (last-scheduled ?x ?t)
	   (scheduled ?x lathe ?t))
    :dele '((shape ?x ?oldshape)
	    (surface-condition ?x ?oldsurf)
	    (painted ?x ?oldpaint)
	    (idle lathe ?t)
	    (last-scheduled ?x ?prev)))
  
  (defstep
      :action '(GRIND ?x ?t)
    :precond '((last-scheduled ?x ?prev)
	       (later ?t ?prev)
	       (idle grinder ?t)
	       (surface-condition ?x ?oldsurf)
	       (painted ?x ?oldpaint))
    :add '((surface-condition ?x smooth)
	   (last-scheduled ?x ?t)
	   (scheduled ?x grinder ?t))
    :dele '((surface-condition ?x ?oldsurf)
	    (painted ?x ?oldpaint)
	    (idle grinder ?t)
	    (last-scheduled ?x ?prev)))
  
  (defstep
      :action '(PUNCH ?x ?t ?width ?orient)
    :precond '((last-scheduled ?x ?prev)
	       (later ?t ?prev)
	       (idle punch ?t)
	       (temperature ?x cold)
	       (surface-condition ?x ?oldsurf))
    :add '((has-hole ?x ?width ?orient)
	   (surface-condition ?x rough)
	   (last-scheduled ?x ?t)
	   (scheduled ?x punch ?t))
    :dele '((surface-condition ?x ?oldsurf)
	    (idle grinder ?t)
	    (last-scheduled ?x ?prev)))
  
  (defstep
      :action '(DRILL-PRESS ?x ?t ?width ?orient)
    :precond '((last-scheduled ?x ?prev)
	       (later ?t ?prev)
	       (idle drill-press ?t)
	       (temperature ?x cold)
	       (have-bit ?width))
    :add '((has-hole ?x ?width ?orient)
	   (last-scheduled ?x ?t)
	   (scheduled ?x drill-press ?t))
    :dele '((idle drill-press ?t)
	    (last-scheduled ?x ?prev)))
  
  (defstep
      :action '(SPRAY-PAINT ?x ?t ?paint)
    :precond '((last-scheduled ?x ?prev)
	       (later ?t ?prev)
	       (idle spray-painter ?t)
	       (temperature ?x cold)
	       (sprayable ?paint)
	       (surface-condition ?x ?oldsurf))
    :add '((painted ?x ?paint)
	   (last-scheduled ?x ?t)
	   (scheduled ?x spray-painter ?t))
    :dele '((surface-condition ?x ?oldsurf)
	    (idle spray-painter ?t)
	    (last-scheduled ?x ?prev)))
  
  (defstep
      :action '(IMMERSION-PAINT ?x ?t ?paint)
    :precond '((last-scheduled ?x ?prev)
	       (later ?t ?prev)
	       (idle immersion-painter ?t)
	       (have-paint-for-immersion ?paint))
    :add '((painted ?x ?paint)
	   (last-scheduled ?x ?t)
	   (scheduled ?x immersion-painter ?t))
    :dele '((idle immersion-painter ?t)
	    (last-scheduled ?x ?prev))))

(defun init-sched (&aux ret)
  (setf ret nil)
  (dolist (x '(polisher roller lathe grinder punch drill-press 
	       spray-painter immersion-painter))
    (dolist (y '(time-1 time-2 time-3 time-4 time-5))
      (push (list 'idle x y) ret)))
  
  (dolist (x '(.1 .2 .3))
    (push (list 'has-bit x) ret))
  
  (dolist (x '(have-paint-for-immersion sprayable))
    (dolist (y '(red black))
      (push (list x y) ret)))
  
  (do ((x '(time-0 time-1 time-2 time-3 time-4 time-5) (cdr x)))
      ((null (cdr x)))
    (do ((y (cdr x) (cdr y)))
	((null y))
      (push (list 'later (car y) (car x)) ret)))
  
  ret)

(defun sched-test ()
  (scheduling-world-domain)
  (plan (append (init-sched)
		'((shape obj-A oblong)
		  (temperature obj-A cold)
		  (surface-condition obj-A rough)
		  (painted obj-A none)
		  (has-hole obj-A 0 nil)
		  (last-scheduled obj-A Time-0)
		  
		  (shape obj-B cylindrical)
		  (temperature obj-B cold)
		  (surface-condition obj-B smooth)
		  (painted obj-B red)
		  (has-hole obj-B 0 nil)
		  (last-scheduled obj-B Time-0)))
	'((shape Obj-A cylindrical)
	  (surface-condition Obj-B polished))))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; A robot domain (contributed by Hank Wan to illustrate a bug)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun robot-domain ()
  (reset-domain)

  (defstep
   :action '(pickup ?x)
   :precond '((at ?x ?loc) (at robot ?loc) (empty-handed))
   :add '((grasping robot ?x))
   :dele '((empty-handed))
   :equals '((not (?x robot))))
  
  (defstep
   :action '(drop ?x)
   :precond '((grasping robot ?x))
   :add '((empty-handed))
   :dele '((grasping robot ?x))
   :equals '((not (?x robot))))

  (defstep
   :action '(empty-handed-move ?from ?to)
   :precond '((connected ?from ?to) (at robot ?from) (empty-handed))
   :add '((at robot ?to))
   :dele '((at robot ?from)))

  (defstep
   :action '(loaded-move ?from ?to)
   :precond '((connected ?from ?to) (at robot ?from) (grasping robot ?x))
   :add '((at ?x ?to)
	  (at robot ?to))
   :dele '((at robot ?from)
	   (at ?x ?from))
   :equals '((not (?x robot)))))

(defun r-test1 ()
  (robot-domain)
  (plan '((connected rm1 rm2)
	  (connected rm2 rm1)
	  (at box1 rm2) (at box2 rm2)
	  (empty-handed) (at robot rm1))
	'((at box1 rm1) (at box2 rm1))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; A driving navigation domain (contributed by Mark Peot to illustrate a bug)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun road-operators ()
  (reset-domain)
  (defstep :action '(drive ?vehicle ?location1 ?location2)
    :precond '((at ?vehicle ?location1) (road ?location1 ?location2))
    :dele '((at ?vehicle ?location1))
    :add '((at ?vehicle ?location2)))
  (defstep :action '(cross ?vehicle ?location1 ?location2)
    :precond '((at ?vehicle ?location1) (bridge ?location1 ?location2))
    :dele '((at ?vehicle ?location1))
    :add '((at ?vehicle ?location2))))

(defvar *roads* nil)

(defun add-road (a b)
  (push `(road ,a ,b) *roads*)
  (push `(road ,b ,a) *roads*))

(defun add-bridge (a b)
  (push `(bridge ,a ,b) *roads*)
  (push `(bridge ,b ,a) *roads*))

(defun road-map () *roads*)

(defun find-path (starting-location goal)
  (plan `(,@(road-map) ,@starting-location)
	goal))

(defun test3 ()
  (road-operators)
  (setf *roads* nil)
  (add-bridge 'a 'd)
  (add-road 'd 'g)
  (time (find-path '((at jack a) (at mark a))
                   '((at jack g) (at mark g)))))


------- End of Forwarded Message



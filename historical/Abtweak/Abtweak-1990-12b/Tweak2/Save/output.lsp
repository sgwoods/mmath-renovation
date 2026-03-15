(defvar *ofile* nil)

(defun run ()

(if (eq *mode* 'tweak) (toggle))
(load-hanoi3)
(msp 'weak)
(prune t)

; loop through 6 input files
; write output to 6 output files

(setq *test*
  '(
    ( ("/u/sgwoods/Plan/Tweak2/Examples/hanoi-3/ibms")
      ("/u/sgwoods/Plan/Tweak2/Examples/hanoi-3/ibms-out") )
    ( ("/u/sgwoods/Plan/Tweak2/Examples/hanoi-3/ibsm")
      ("/u/sgwoods/Plan/Tweak2/Examples/hanoi-3/ibsm-out") )
    ( ("/u/sgwoods/Plan/Tweak2/Examples/hanoi-3/imbs")
      ("/u/sgwoods/Plan/Tweak2/Examples/hanoi-3/imbs-out") )
    ( ("/u/sgwoods/Plan/Tweak2/Examples/hanoi-3/imsb")
      ("/u/sgwoods/Plan/Tweak2/Examples/hanoi-3/imsb-out") )
    ( ("/u/sgwoods/Plan/Tweak2/Examples/hanoi-3/isbm")
      ("/u/sgwoods/Plan/Tweak2/Examples/hanoi-3/isbm-out") )
    ( ("/u/sgwoods/Plan/Tweak2/Examples/hanoi-3/ismb")
      ("/u/sgwoods/Plan/Tweak2/Examples/hanoi-3/ismb-out") )
   ))

; 1-ok  2-ok 3-ok 4-fail 5-? 6-?

(setq *test* (cdr (cdr (cdr (cdr *test*))))) ; skip first 4 tests
;(break "Before Starting Loop")

(dolist (file-set *test*)
   (let ( (input-file  (car (first file-set)))
          (output-file (car (second file-set))) )

          (setq *ofile* (open output-file :direction :output))
          (setq *trace-output* *ofile*)

	  (print-title *ofile* *critical-loaded*)

          (load input-file)    ; load criticalities from this loop run

          (time (abtweak initial goal))   ; test actual problem

          (print-results *ofile* 
                                 *mode*
                                 *domain*
                                 *critical-loaded*
                                 *search*
                                 *SP-property*
                                 *debug*
                                 (find-initial-k-val)
                                 *top-down-flag*
                                 *msp-flag*
                                 *prune-flag*
                                 *w-msp-pruned*
                                 *s-msp-pruned*
                                 *ab-count*
                                 numexpanded 
                                 numgenerated 
                                 goal-plan )

      (close *ofile*)

    )) )
   
(defun print-title (stream crit-test)
  "print-title"
  (format stream "~&AbTweak Criticality Test = ~A" crit-test)
  (format stream "~& ~& ")
 )

(defun print-results (stream mo do cr se sp de k td ms pr w s ab ex ge gp)
  (format stream "~& ")
  (format stream "~& Planner Mode: ~A" mo)
  (format stream "~& Search Mode: ~A" se)
  (format stream "~& Domain: ~A" do)
  (format stream "~& K Levels: ~A" k)
  (format stream "~& Critical Setting: ~A" cr)
  (format stream "~& Single Producer Property: ~A" sp)
  (format stream "~& Top Down Property: ~A" td)
  (format stream "~& MSP Setting: ~A" ms)
  (format stream "~& Prune Flag: ~A" pr)
  (format stream "~& Debug Flag: ~A" de)
  (format stream "~& ")
  (format stream "~& Weak MSP prune Count: ~A" w)
  (format stream "~& Strong MSP prune Count: ~A" s)
  (format stream "~& Abstract Nodes Generated: ~A" ab)
  (format stream "~& Nodes Expanded: ~A" ex)
  (format stream "~& Nodes Generated: ~A" ge)
  (format stream "~& ")
  (format stream "~& Goal Plan: ~A" gp)
  (format stream "~& ")

)

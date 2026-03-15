; Compile ALL ABTWEAK related functions

(defun compile-ab ()
   ; ABTWEAK
                      (compile-ab-init)
                      (compile-ab-mtc)
                      (compile-ab-structs)
                      (compile-ab-abtweak)  
                      (compile-ab-succ)
                      (compile-ab-msp)
                      (compile-ab-mono)
                      (compile-ab-causal)
                     )

(defun compile-ab-init ()
                 (compile-file "/u/sgwoods/Plan/AbTweak2/init") 
  )

(defun compile-ab-mtc ()
                 (compile-file "/u/sgwoods/Plan/AbTweak2/ab-mtc") 
  )

(defun compile-ab-structs ()
                 (compile-file "/u/sgwoods/Plan/AbTweak2/ab-structs") 
  )

(defun compile-ab-abtweak ()
                 (compile-file "/u/sgwoods/Plan/AbTweak2/abtweak") 
  )

(defun compile-ab-msp ()
                 (compile-file "/u/sgwoods/Plan/AbTweak2/ab-msp") 
  )

(defun compile-ab-mono ()
                 (compile-file "/u/sgwoods/Plan/AbTweak2/ab-mono") 
  )

(defun compile-ab-succ ()
                 (compile-file "/u/sgwoods/Plan/AbTweak2/ab-succ") 
 ) 

(defun compile-ab-causal ()
                 (compile-file "/u/sgwoods/Plan/AbTweak2/ab-causal")
 )




 

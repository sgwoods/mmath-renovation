; /Tweak/structs.lsp

;***************************************************************************
; structure definitions
;
;    plan
;    operator
;    operator instance
;***************************************************************************

(defstruct plan  
  "/tweak/structs.lsp
   a plan under construction"
 (id  nil)           ; unique identifier
 (cost 0)          ; cost of this plan
 (kval 0)          ; abtweak:: abstraction depth of plan
 (cr   nil)          ; abtweak:: existing causal relations to be preserved
                     ;           from abstraction level kval + 1
 (a   nil)           ; operator structure list
 (b   nil)           ; operator orderings
 (nc  nil)           ; non-codesignations
 (var nil)           ; variables used in plan codes/ncodes
 (conflicts nil)     ; list of conflicts in plan
 (op-count nil)      ; list (by criticality level) of ops added at each level
 (invalid nil)
)

(defstruct operator 
  "/tweak/structs.lsp
   general operator template - in *operators*"
  (opid nil)
  (name  'none)
  (preconditions nil)
  (effects       nil)
  (cost 0)
  (primary-effects nil)
 )     

;***************************************************************************
; global variable definitions
;  *operators*
;***************************************************************************

(defvar *operators* nil
 "/tweak/structs.lsp
   unordered list of all operators templates that exists")

(defvar initial  nil
 "/tweak/structs.lsp
   initial state ")

(defvar goal     nil
 "/tweak/structs.lsp
   goal state ")


;*********** user interface routines **********************

(defun create-operator-instance ( &key opid
				  name preconditions effects cost 
				  primary-effects)
  "/tweak/structs.lsp
   creates an operator instance using op_instance structure"
  (make-operator :opid opid
		 :name name 
		 :preconditions preconditions
		 :effects effects
		 :cost cost
		 :primary-effects primary-effects))

(defun create-plan (id &key a b nc (tree nil) (kval 0) (cost 0))
  "/tweak/structs.lsp
   create a plan "
  (make-plan 
   :id id
   :a  a   
   :cost cost
   :b b
   :nc nc
   :conflicts nil
   :op-count  nil
   :kval kval))

; note: every plan should have a initial state i and a goal state
; g, so that i is before every other ops, and g is after.


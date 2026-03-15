; /tweak/structs.lsp

; written by steve woods,  june 1990
; modified by qiang yang,  sept 1990
;             steve woods, oct 1990

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
 (cost nil)          ; cost of this plan
 (kval nil)          ; abtweak:: abstraction depth of plan
 (cr   nil)          ; abtweak:: existing causal relations to be preserved
                     ;           from abstraction level kval + 1
 (tree nil)          ; nec est opid tree
 (a   nil)           ; operator list
 (b   nil)           ; operator ordering
 (nc  nil)           ; non codesignations
 (var nil)           ; variables in use in plan codes/ncodes
 (conflicts nil)     ; list of operator problems that exist
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
 )     

;***************************************************************************
; global variable definitions
;  *operators*
;  *cost-...
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

; cost values

(defvar *cost-rde-exist*  0
 "/tweak/structs.lsp
   cost of performing rde exist operation")

(defvar *cost-rde-add*     0
 "/tweak/structs.lsp
   cost of performing rde add operation")

(defvar *cost-separation*  0
  "/tweak/structs.lsp
   cost of performing separation operation")

(defvar *cost-promotion*   0
  "/tweak/structs.lsp
   cost of performing promotion operation" )

(defvar *cost-demotion*    0
  "/tweak/structs.lsp
   cost of performing demotion operation")

(defvar *cost-en-intermediate* 0
  "/tweak/structs.lsp
   cost of using an existing necessary establisher in creating an
   intermediate node" ) 

(defvar *cost-ep-intermediate* 0
  "/tweak/structs.lsp
   cost of using an existing possible establisher in creating an
   intermediate node" ) 

(defvar *cost-n-intermediate* 0
  "/tweak/structs.lsp
   cost of using a  new establisher in creating an
   intermediate node" ) 


;*********** user interface routines **********************

(defun create-operator-instance ( &key opid
				  name preconditions effects)
  "/tweak/structs.lsp
   creates an operator instance using op_instance structure"
  (make-operator :opid opid
		 :name name 
		 :preconditions preconditions
		 :effects effects))

(defun create-plan (id &key a b nc (tree nil) (kval 0))
  "/tweak/structs.lsp
   create a plan "
  (make-plan 
   :id id
   :a  a                                ; was (mapcar 'eval a), sgw for CL
   :cost 0
					; a is a list of ids for operators
   :b b
   :nc nc
   :tree tree
   :conflicts nil
   :op-count  nil
   :kval kval))

; note: every plan should have a initial state i and a goal state
; g, so that i is before every other ops, and g is after.

; functions that deal with i and g are in initial/initial.lsp.


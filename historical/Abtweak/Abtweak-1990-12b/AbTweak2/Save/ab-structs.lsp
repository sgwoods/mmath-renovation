; ABTWEAK variables *********************************************************

(defvar *critical-list* nil
  "/AbTweak/ab-structs.lsp
   List of AbTweak Domain criticality levels of preconditions")

(defvar *top-down-levels* nil
  "/AbTweak/ab-structs.lsp
   List of AbTweak Domain levels indicated as applicable to enforcement
   of the top-down pruning method when flagged as pruning for this -
   ie these levels listed will never have > 1 solution subtree explored")

(defvar *ab-count* 0
  "/AbTweak/ab-structs.lsp
   Global count of ABSTRACTIONS from level k to levl k-1 that occur")

(defvar *MSP-FLAG*      nil
  "/AbTweak/ab-structs.lsp
   Control application of Monotonic Solution Prop")   

(defvar *W-MSP-PRUNED* 0
  "/AbTweak/ab-structs.lsp
   The number of nodes pruned via the W-MSP method of pruning")

(defvar *S-MSP-PRUNED* 0
  "/AbTweak/ab-structs.lsp
   The number of nodes pruned via the S-MSP method of pruning")

(defvar *PRUNE-FLAG*    nil
  "/AbTweak/ab-structs.lsp
   Control pruning of successors via flag")     

(defvar *TOP-DOWN-FLAG*    nil
  "/AbTweak/ab-structs.lsp
   Control pruning of all level K plans when 1 solution is found at level K -
   ie if flag is set, never allow multiple correct abstract plans to be
   generated")

(defvar *TOP-DOWN-NUM*    0
  "/AbTweak/ab-structs.lsp
   The number of nodes pruned via the top-down method of pruning")

;***************************************************************

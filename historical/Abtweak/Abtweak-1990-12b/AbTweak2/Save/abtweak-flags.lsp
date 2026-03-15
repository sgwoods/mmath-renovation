;***************************************************************************
; ABTWEAK PLANNER CONTROL DEFAULT FLAG SETTINGS
;***************************************************************************

(setq *MODE* 'ABTWEAK)
(setq *SEARCH*   '4)              ; 1 - DFS w   Closed List (?)
                                  ; 2 - DFS w/o Closed List
                                  ; 3 - A*
                                  ; 4 - BFS w/o  Closed List
                                  ; 5 - IDA* w   Closed List (?)
                                  ; 6 - IDA* w/o Closed List

(setq *MSP-FLAG* nil)             ; Monotonic Solution Property (one of)
                                  ;        Weak/Strong/nil
                                  ;  used to prune expansion
                                  ;  by maintaining causal relationships


(setq *PRUNE-FLAG* t)             ; Set when pruning via MSP desired
                                  ;  (ie can dynamically change)


(setq *k-mode* nil)

(setq *TOP-DOWN-FLAG* nil)        ; Set when desire to turn on/off multiple
                                  ; abstraction at same level checking as
                                  ; defined in the Abstract Domain

(setq *DEBUG* nil)       ; Turns on Search tree output, planning notations


; Global Counters

(setq *exp-count* 0)    ; Count of total nodes expanded
(setq *gen-count* 0)    ; Count of total nodes generated
(setq *ab-count* 0)     ; Count of ABTWEAK k level change nodes
(setq *w-msp-pruned* 0) ; Count of Weak MSP violation nodes discarded
(setq *s-msp-pruned* 0) ; Count of Strong MSP violation nodes discarded
(setq *top-down-num* 0) ; Count of TOP-DOWN nodes purged from open list

;***************************************************************************


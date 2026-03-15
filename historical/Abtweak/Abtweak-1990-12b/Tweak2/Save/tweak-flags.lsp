;***************************************************************************
; TWEAK PLANNER CONTROL DEFAULT FLAG SETTINGS
;***************************************************************************

(setq *MODE* 'TWEAK)
(setq *SEARCH*   '4)              ; 1 - DFS w   Closed List (?)
                                  ; 2 - DFS w/o Closed List
                                  ; 3 - A*
                                  ; 4 - BFS w/o  Closed List
                                  ; 5 - IDA* w   Closed List (?)
                                  ; 6 - IDA* w/o Closed List

(setq *DEBUG* nil)       ; Turns on Search tree output, planning notations

(setq *SP-property* nil) ; Turns on/off Single Producter Property

; Global Counters

(setq *exp-count* 0)    ; Count of total nodes expanded
(setq *gen-count* 0)    ; Count of total nodes generated

;***************************************************************************


; /tweak/conf-infer/intermed-access.lsp

; written by steve woods, june 1990
; modified by qiang yang, sept 1990
;             steve woods oct  1990

;***************************************************************************
; access intermediate node
;
; (est plan)
;

(defun get-inter-estid (intermediate)
   (declare 
        (type list intermediate))
   (first intermediate))

(defun get-inter-plan (intermediate)
   (declare 
       (type list intermediate))
   (second intermediate))





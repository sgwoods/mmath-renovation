; /tweak/conf-infer/intermed-access.lsp

; written by steve woods and qiang yang 1990


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





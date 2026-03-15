; /tweak/conf-infer/classify.lsp

; written by steve woods, qiang yang, 1990


;***************************************************************************
; classifing routine - 
;   all conflicts are 1 of 4 types:
;      ln  - linear
;      lf  - left fork
;      rf  - right fork
;      p   - parallel
;                       refer to qiang's aaai paper - algebraic approach ...
;

(defun classify (conflict plan)
 "/tweak/conf-infer/classify.lsp
  classify a conflict as one of ln, lf, rf, p, ne"
 (declare
     (type list conflict)
     (type plan plan) )
 (let ( 
        (u     (get-conflict-u conflict))
        (pro   (get-conflict-pro   conflict))
        (n     (get-conflict-n  conflict)) )
	
  (declare
           (type atom u)                     ;user      op id
           (type atom pro)                   ;provider  op id
           (type atom n) )                   ;clobberer op id

 (cond ((and (eq pro '?) (eq n 'i))
					;if (p=? and n=i)
					; no establisher identified
	'no-establisher)

       ((and  (nece-before-p pro n plan)   ; p < n
	      (nece-before-p n u plan))    ; n < u

                                ; linear conflict - ln
	'ln)
       ((and (nece-before-p pro u plan)    ; p < u
	     (nece-before-p n u plan))     ; n < u

          ; left fork - lf
          'lf)
        ((and (nece-before-p pro u plan)   ; p < u
	      (nece-before-p pro n plan))  ; p < n

					; right fork
               'rf)
	((and (nece-before-p pro u plan)   ; p < u
	      (poss-before-p n pro plan)   ; possibly n < p
	      (poss-before-p pro n plan)   ;          p < n
	      (poss-before-p u n plan)     ;          u < n
	      (poss-before-p n u plan))    ;          n < u
                    ; parallel - p
                    'p)
	(t (progn
	     (princ "error - classification of problem") (terpri)
             (setq *error-plan* plan)       ; global error variables
             (setq *err-conflict* conflict) ;   for later debugging
             (princ "errant information stored in global vars") (terpri)
             (cur)
              (princ *error-plan*)
              (princ *err-conflict*)
             (break "stopped at error")
	     nil)))))

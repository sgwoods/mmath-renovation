; /planner/init.lsp

; planner implemented 1990
; code written by steve woods & qiang yang
; university of waterloo
; waterloo, ontario canada
; sgwoods@watdragon.uwaterloo.ca   qyang@watdragon.uwaterloo.ca

; load object code files or lisp code files

(defun read-input (readit)
      (clear-input)
      (princ "load lisp instead of object code?  (default = n) : ") 
      (setq read-it (read)))

(defun start ()
    (setq read-it nil) (setq load-val 'n)
    (setq load-val (read-input read-it))
    (if (eq load-val 'y)
        (progn 
          (setq *loaded* 'lisp)
          (load "init-lsp.lsp") )
        (progn 
          (load "init-o.lsp")
          (setq *loaded* 'object) )))

(progn
      (terpri) (terpri)
      (princ "type  (start) to re-load planner")
      (terpri) (terpri)
      nil)

(setq *loaded* 'object)

;(setq sys:*source-file-types* '("lsp" "lisp"))   ; CL defaults to look for

(load "init-o.lsp")


(setq excl:*global-gc-behavior* ':auto)      ; cause garbage collection to trigger 
                                             ; automatically, without prompt

(defun bye () (exit))                        ; mimic KCL exit

(setq sys:*source-file-types* '( "lsp" "lisp" ))

(setq sys:*load-search-list*
     '(*DEFAULT-PATHNAME-DEFAULTS* 
       #p(:TYPE "fasl")
       #p(:TYPE "lsp")  
       #p(:TYPE "lisp") 
       EXCL::*LIBRARY-CODE-FASL-PATHNAME* 
       EXCL::*LIBRARY-CODE-CL-PATHNAME* 
       EXCL::*LIBRARY-CODE-BIN-PATHNAME*)  )

(load "init.lsp")    ; load PLANNER

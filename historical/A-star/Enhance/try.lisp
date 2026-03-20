(defun try (dfs-depth-limit
                &key
                    (success-p nil) 
                    (done-depth-p nil)
            )
    (do 
       ( (depth    1   (1+ depth) )
         (finish-p nil (or success-p done-depth-p))  ; local variables
       )                
       ( 
         (eq finish-p t)                          ; exit do when?
         (if success-p t nil)
       )
       (if (eval_fn depth)
           (setq success-p t)                        ; solution found
           (progn 
             (princ "IDA* - depth = ") (princ depth) (terpri) 
             (princ "       limit = ") (princ dfs-depth-limit) (terpri)
             (if (eq depth dfs-depth-limit)           
                 (setq done-depth-p t)                 ;depth limit done
                 (setq done-depth-p nil))              ;depth limit not done
           ))
      ))

(defun eval_fn (d)
   (eq d 10))

; /tweak/succ/find-nec-exist-ests.lsp

; written by steve woods,  june 1990
; modified by qiang yang,  sept 1990
;             steve woods, oct 1990

;*********************** exist - nec establishers ************************

(defun find-nec-exist-ests (plan u p)
  "/tweak/succ/find-nec-exist-ests.lsp  (oct 11)
   returns ( (est1 plan-with-cost-added) ...) "
   (declare
       (type plan plan)
       (type list u)
       (type list p))
   (mapcar #'(lambda (nec-est)
                (list nec-est (make-copy-of-plan plan)))
          (find_establishers plan u p)) )


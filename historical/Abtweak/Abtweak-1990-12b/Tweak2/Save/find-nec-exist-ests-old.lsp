; /Tweak/Succ/find-nec-exist-ests.lsp

; Written by Steve Woods,  June 1990
; Modified by Qiang Yang,  Sept 1990
;             Steve Woods, Oct 1990

;*********************** exist - nec establishers ************************

(defun find-nec-exist-ests (plan u p)
  "/Tweak/Succ/find-nec-exist-ests.lsp
   returns ( (est1 plan-with-cost-added) ...) "

  (declare 
     (type plan plan)
     (type atom u)
     (type list p) )

  (let* (
         (nec-ests (find_establishers plan u p)))

     (declare 
         (type (list atom) nec-ests))

; for each of these, return (est-op u- int-plan) where u- nec achieves p

     (make-intermediates nec-ests p plan)))

(defun make-intermediates (nec-ests p plan)
  "/Tweak/Succ/find-nec-exist-ests.lsp  
   create list of (est p plan 'en) "

  (declare 
      (type (list) nec-ests)
      (type plan plan) )

   (if (null nec-ests)
       nil
       (let (
             (new-plan (make-copy-of-plan plan) ))
          (declare 
              (type plan new-plan))
          (cons (list
        	      (first nec-ests)
        	      (add-cost-to-plan new-plan 0))

; indicate origin of intermediate node
	   (make-intermediates (cdr nec-ests) p plan)) )))







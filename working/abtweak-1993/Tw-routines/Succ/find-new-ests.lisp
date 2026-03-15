; /Tweak/Succ/find-new-ests.lsp

; find new establishers to create intermediate nodes with.

(defun find-new-ests (plan u p)
  "tweak/succ/find-new-ests.lsp
   return a list of (est-op intermediate-plan) containing all
   new establishers est-op of u p, s.t. the intermediate plan contains
   est-op necessarily before u, and an effect necessarily codesignates 
   with p" 
   (declare 
         (type plan plan)
         (type atom u)
         (type list p))
   (let (
         (pos-ests-and-mappings (select-ops *operators* p)))
  
     (declare
         (type (list list) pos-ests-and-mappings) )

; pos-ests-and-mappings are pairs, 
; the first element is operator instance with var replaced,
; the second element is the mapping used to substitute the operator.

     (mapcar #'(lambda (est-and-mapping) 
		 (let* (
                        (est (first est-and-mapping))
			(estid (get-operator-opid est))
			(mapping (second est-and-mapping))
			(new-plan (find-new-plan plan u est mapping)))

                   (declare
                        (type operator est)
                        (type atom estid)
                        (type (or list (eql t)) mapping)
                        (type plan new-plan) )

		   (list
		    estid  
					; note: cost is not added.
					;       conflict is not added.
		    new-plan)))
	     pos-ests-and-mappings)))


(defun find-new-plan (plan u est mapping)
  "tweak/succ/find-new-ests.lsp
   returns a new plan with est as establisher for u."
  (declare 
      (type plan plan)
      (type atom u)
      (type operator est)
      (type (or list (eql t)) mapping) )

  (let* (
          ; make a copy of this plan
         (copy-plan (make-copy-of-plan plan))

          ; insert operator and op param non codes to plan
         (opplan   (add-operator-to-plan est copy-plan))
         (opid      (get-operator-opid est))
          ; add ordering of opid before user to plan
         (ord-plan  (add-order-to-plan opid u opplan)) )

    (declare
        (type plan copy-plan)
        (type plan opplan)
        (type atom opid)
        (type plan ord-plan) )
    (add-cost-to-plan (get-operator-cost est)
		      (apply-mapping-to-plan mapping ord-plan))
    ))

	 



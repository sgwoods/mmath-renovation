; /tweak/succ/find-exist-ests.lsp

; written by steve woods and qiang yang, 1990


; find existing establishers to create intermediate nodes.


(defun find-exist-ests (plan u p-) 
  "/tweak/succ/est-exist.lsp
   returns a list of (establisher p-
   intermediate-plan flag), where establisher is an operator in
   intermediate-plan that is necessarily before u, and an effect of it 
   necessarily codesignates with p-.  flag=en if the before relation 
   is already in plan, ep otherwise."

(declare (type plan plan)
	 (type atom u) (type list p-) ) 

(append (find-pos-exist-ests plan u p-)
	(find-nec-exist-ests plan u p-) ) )

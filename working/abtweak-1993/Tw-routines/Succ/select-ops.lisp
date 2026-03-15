; /tweak/succ/select-ops.lsp

; selects operator templates that can possibly co-designate with precond

(defun select-ops (templates  precond)
  "/tweak/succ/select-ops.lsp
   select applicable operator templates, instantiate with new vars, opids"
  (declare 
      (type list templates)
      (type list precond) )
  (apply 'append 
	 (mapcar #'(lambda (op-template) 
		     (find-list-of-op-instances 
		      op-template precond))
		 templates)))

(defun find-list-of-op-instances (op-template precond)
  "/tweak/succ/select-ops.lsp
   returns a list of operator instances of op-template that can possibly 
   assert precond"
  (let (
        (effects 
	 (if *use-primary-effect-p* 
	     (get-operator-primary-effects op-template)
	   (get-operator-effects op-template))))
    (declare
        (type list effects) )
    (do ((rem-effects effects (cdr rem-effects))
	 (index 0 (1+ index))
	 (results nil))
	((null rem-effects) results) 
	(let* (
               (effect (car rem-effects))
  	       (mapping (poss-codesignates effect precond)))
          (declare 
              (type list effect) )
	  (if mapping 
	      (let* (
                     (new-op (create-new-op-instance op-template))
		     ;; Caution:  don't use (copy-operator ..),
		     ;; Because, it won't change var names!
		     
		     (new-effect 
			  (get-ith-op-effect new-op index 
					     :primary 
					     *use-primary-effect-p*))
		     (new-mapping (poss-codesignates new-effect precond)))
                (declare
                     (type operator new-op)
                     (type list new-effect) )
		(setq results (cons 
		      (list 
		       (apply-mapping-to-op-instance
			new-op new-mapping)
		       new-mapping)
		      results))))))))

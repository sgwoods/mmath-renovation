; /tweak/succ/select-ops.lsp

; written by steve woods,  june 1990
; modified by qiang yang,  sept 1990
;             steve woods, oct 1990

; selects operator templates that can possibly co-designate with precond

(defun select-ops (templates  precond)
  "/tweak/succ/select-ops.lsp
   select applicable operator templates, instantiate with new vars, opids"
  (declare 
      (type (list operator) templates)
      (type list precond) )
  (apply 'append 
	 (mapcar #'(lambda (op-template) 
		     (find-list-of-op-instances 
		      op-template precond))
		 templates)))

(defun find-list-of-op-instances (op-template precond)
  "/tweak/succ/select-ops.lsp
   returns a list of operator instances of op-template that can possibly 
   codesgnate with precond"
  (let (
        (effects (get-operator-effects op-template)))
    (declare
        (type (list list) effects) )
    (do ((rem-effects effects (cdr rem-effects))
	 (index 0 (1+ index))
	 (results nil))
	((null rem-effects) results) 
	(let* (
               (effect (car rem-effects))
  	       (mapping (poss-codesignates effect precond)))
          (declare 
              (type list effect)
              (type list mapping) )
	  (if mapping 
	      (let* (
                     (new-op (create-new-op-instance op-template))
		     (new-effect (get-ith-op-effect new-op index))
		     (new-mapping (poss-codesignates new-effect precond)))
                (declare
                     (type operator new-op)
                     (type list new-effect)
                     (type list new-mapping) )
		(setq results (cons 
		      (list 
		       (apply-mapping-to-op-instance
			new-op new-mapping)
		       new-mapping)
		      results))))))))


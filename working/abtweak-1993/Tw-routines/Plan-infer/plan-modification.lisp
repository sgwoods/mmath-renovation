; /tweak/plan-infer/plan-modification.lsp

; written by steve woods and qiang yang, 1990


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;                 plan modification
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;**************************************************
;                non codesignation
;
;**************************************************
(defun add-prop-nc-to-plan (prop1 prop2 plan)
  "/tweak/plan-infer/plan-modification.lsp
   add to plan non codesignation of the parameters of
   prop1 prop2 to plan."
  (declare
      (type list prop1)
      (type list prop2)
      (type plan plan) )
  (cond 
   ((null plan) nil)
   ((equal prop1 prop2) (mark-invalid-plan plan))
   (t
    (let (
          (params1 (get-proposition-params prop1))
	  (params2 (get-proposition-params prop2)))
      (declare
          (type list params1)
          (type list params2) )
      (mapcar #'(lambda (x y)
		  (add-nc-to-plan x y plan))
	      params1 params2)
      plan))))



;********** co-designation

(defun apply-mapping-to-plan (mapping plan)
  "/tweak/plan-infer/plan-modification.lsp
   apply mapping to each variable of plan."
  (declare
      (type (or list (eql t)) mapping)
      (type plan plan) )

  (cond 
   ((null plan) nil)
   ((equal mapping t) plan)
   (t (dolist (pair mapping plan)
	      (cond 
	       ((non-codesignate-p (car pair)
				   (second pair) plan)
		(return (mark-invalid-plan plan)))
	       (t (add-co-to-plan (car pair) (second pair) plan)))))))


;******** add-co-to-plan (x y plan)

(defun add-co-to-plan (x y plan)
 "/tweak/plan-infer/plan-modification.lsp
   add to plan codesignation constraint that x = y."
 (declare
     (type atom x)
     (type atom y)
     (type plan plan) )
 (cond
  ((null plan) nil)
  ((non-codesignate-p x y plan)
   (mark-invalid-plan plan))
  (t (cond ((and (constant-p x)
		 (constant-p y))
	    plan)
	   ((constant-p x)
	    (substitute-this-by-that y x plan))
	   ((constant-p y)
	    (substitute-this-by-that x y plan))
	   (t (substitute-this-by-that x y plan)))
     (remove-constant-nonco plan))))

 
(defun substitute-this-by-that (x y plan)
  "/tweak/plan-infer/plan-modification.lsp
   y is a variable.  returns plan with all occurrences of 
   x replaced by y in plan."
 (declare
     (type atom x)
     (type atom y)
     (type plan plan) )
  (cond 
   ((null plan) nil)
   (t (replace-cr x y
         (replace-a x y 
	     (replace-nc x y
			 (replace-conflicts x y plan))))))) 

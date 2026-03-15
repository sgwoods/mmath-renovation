; /ai-programs/tweak/general.lsp

; general use routines
;
; written by steve woods, 1990
; modified by qiang yang, 1990
;

(defun random-element (list)
   "tweak/general.lsp
    select a random element from list"
   (declare (type list list))
   (ith (random (length list)) list) )

(defun my-delete (e list)
  "/tweak/general.lsp  old
   remove a list or atom from a list"
  (declare
          (type atom e)
          (type list list)
   )
  (if (eq (car list) nil)
      nil
      (if (equal e (car list))   ; e found in list      
          (my-delete e (cdr list)) 
          (append (list (car list))
                  (my-delete e (cdr list))))))

(defun memb (e list)
  "/tweak/general.lsp
   acts like member, but is general over list structures"
  (declare
          (type atom e)
          (type list list)
   )
  (member e list 
     :test #'(lambda (e element) (equal element e))))

;************* substitute-one-condition (condition mapping)**********

(defun substitute-one-list (alist mapping)
  "/tweak/general.lsp
   if alist= (p $x $y i), mapping= (($x a) ($y b)) then return
   (p a b i)."
  (declare (type list alist)
           (type (list list) alist))
  (let ( (lis nil) )
       (declare (type list lis))
   (mapcar #'(lambda (element)
		 (if (setq lis (member element
				       mapping 
				       :test 
				       #'(lambda (element pair)
					   (equal element (car pair)))))
		     (second (car lis))
		   element))
	  alist)))

		   
(defun substitute-all-lists (lists mapping)
"/tweak/general.lsp
   if lists= ((p x y)...), mapping= ((x a) (y b)) then return
   ((p a b)....)"			   
  (declare (type (list list) lists)
           (type (list list) mapping) )
  (mapcar #'(lambda (list)
	      (substitute-one-list list mapping))
	  lists))

;************************ clean-up mapping *********************

(defun clean-up-mapping (substitution-list old-variables)
"/tweak/general.lsp
 if substitution-list= (($x a)($z u)), and 
  old-variables= ( $x a $z $w), then return (($x a) ($z $z') ($w $w')).
  "
   (declare (type (list list) substitution-list)
            (type list old-variables) )
   (let ()
     (setq substitution-list
	   (remove-all-var-pairs substitution-list))
     (append
      substitution-list
      (mapcar #'(lambda (old-var)
		  (list old-var (create-var)))
	      (remove-if 'constant-p
			 (set-difference 
			  old-variables
			   (mapcar 'car substitution-list)
			   :test 'equal))))))

(defun remove-all-var-pairs (substitution-list)
  "/tweak/general.lsp
   if substitution-list= ((x a) (y b) (z u)), return ((x a) (y b)), 
   since the last one is a pair of variables"
 (declare (type (list list) substitution-list))
 (remove-if
  #'(lambda (pair)
      (and (var-p (first pair))
	   (var-p (second pair))))
      substitution-list))

			     
(defmacro create-var ()
  "/tweak/general.lsp
   create a variable"
  `(gentemp "$"))


(defmacro create-opid ()
  "/tweak/general.lsp
   create a new operator instance id"
  `(gentemp "op"))


(defmacro create-planid ()
  "/tweak/general.lsp
   create a new operator instance id"
  `(gentemp "plan"))

(defun var-p (x)
  "/tweak/general.lsp
   return t iff x is variable, =$y."
  (string-equal "$" (string x) :end2 1))


(defun constant-p (x)
  "/tweak/general.lsp
   return t iff x is constant."
  (not (var-p x)))


; macro for the above function.
(defun negate-condition (p)
  "/tweak/general.lsp
   return the negation of p, cleaned so (not not ..) is ( ..)."
  (if (equal 'not (car p))
      (cdr p)
    (cons 'not p)))

(defun get-proposition-params (p)
  "/tweak/general.lsp
   returns the list of parameters of p"
  (if (equal (car p) 'not) (cddr p) (cdr p)))




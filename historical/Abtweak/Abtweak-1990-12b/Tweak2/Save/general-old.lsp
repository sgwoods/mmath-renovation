; /AI-programs/Tweak/general.lsp

; GENERAL USE ROUTINES
;
; Written by Steve Woods, 1990
; Modified by Qiang Yang, 1990
;

(defun uappend(list1 list2)
  "/Tweak/general.lsp
   Return the result of appending both lists, discarding duplicate elements"
  (declare
          (type list list1)
          (type list list2)
   )
  (if (eq (car list1) nil) 
      list2
      (if (member (car list1) list2)
          (uappend (cdr list1) list2) 
          (uappend (cdr list1) (cons (car list1) list2))  )))

(defun memb (e list)
  "/Tweak/general.lsp
   Acts like member, but is general over list structures"
  (declare
          (type atom e)
          (type list list)
   )
  (member e list 
     :test #'(lambda (e element) (equal element e))))

(defun intersection (list1 list2)
  "/Tweak/general.lsp
   Returns the intersection of two lists"
  (declare
          (type list list1)
          (type list list2)
   )
   (if (or (eq list1 nil) (eq list2 nil))
       nil
       (if (memb   (car list1) list2)
           (append (list (car list1))
                   (intersection (cdr list1) list2))
           (intersection (cdr list1) list2))))

(defun difference (list1 list2)
  "/Tweak/general.lsp
   Returns the difference of two lists"
  (declare
          (type list list1)
          (type list list2)
   )
   (if (eq list1 nil)
       list2
       (if (eq list2 nil)
           list1
           (if (memb (car list1) list2)
               (difference (cdr list1) (delete (car list1) list2) )
               (append (list (car list1))
                       (difference (cdr list1) list2) )))))

;************* substitute-one-condition (condition mapping)**********

(defun substitute-one-list (alist mapping)
  "/Tweak/general.lsp
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
"/Tweak/general.lsp
   if lists= ((p x y)...), mapping= ((x a) (y b)) then return
   ((p a b)....)"			   
  (declare (type (list list) lists)
           (type (list list) mapping) )
  (mapcar #'(lambda (list)
	      (substitute-one-list list mapping))
	  lists))

;************************ clean-up mapping *********************

(defun clean-up-mapping (substitution-list old-variables)
"/Tweak/general.lsp
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
  "/Tweak/general.lsp
   if substitution-list= ((x a) (y b) (z u)), return ((x a) (y b)), 
   since the last one is a pair of variables"
 (declare (type (list list) substitution-list))
 (remove-if
  #'(lambda (pair)
      (and (var-p (first pair))
	   (var-p (second pair))))
      substitution-list))

			     
(defmacro create-var ()
  "/Tweak/general.lsp
   create a variable"
  `(gentemp "$"))


(defmacro create-opid ()
  "/Tweak/general.lsp
   create a new operator instance id"
  `(gentemp "op"))


(defmacro create-planid ()
  "/Tweak/general.lsp
   create a new operator instance id"
  `(gentemp "plan"))



(defun var-p (x)
  "/Tweak/general.lsp
   return t iff x is variable, =$y."
  (string-equal "$" (string x) :end2 1))


(defun constant-p (x)
  "/Tweak/general.lsp
   return t iff x is constant."
  (not (var-p x)))


; macro for the above function.
(defun negate-condition (p)
  "/Tweak/general.lsp
   return the negation of p, cleaned so (not not ..) is ( ..)."
  (if (equal 'not (car p))
      (cdr p)
    (cons 'not p)))


(defun get-proposition-params (p)
  "/Tweak/general.lsp  
   returns the list of parameters of p"
  (if (equal (car p) 'not) (cddr p) (cdr p)))

(defun my-delete (e list)
  "/Tweak/general.lsp  OLD
   Remove a list or atom from a list"
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

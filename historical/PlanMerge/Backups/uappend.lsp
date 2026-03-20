
;UAPPEND (list1 list2)
;  Return the result of appending both lists, discarding unique elements
(defun uappend( list1 list2)
  (if (eq (car list1) nil) 
      list2
      (if (member (car list1) list2)
          (uappend (cdr list1) list2) 
          (uappend (cdr list1) (cons (car list1) list2))  )))

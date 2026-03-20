;;; -*- Mode: LISP; Syntax: Common-lisp; Package: MVL; Base: 10 -*-

(in-package "MVL")

;; The MVL theorem prover maintains a list of unexpanded nodes in the
;; form of an agenda.  In order to allow maximum flexibility when
;; ordering the agenda nodes, the elements are labelled with priorities.
;; The form of these priorities is a list of integers (i ... k).  Lower
;; integers are better and the lists are ordered lexicographically.

;; The format of the agenda can best be described by an example.
;; Suppose that we have four nodes, A B C D, labelled by (1), (1 2),
;; (2 3) and (1) respectively.  The form of the agenda would be:
;;   ((1 A D (2 B)) (2 (3 C)))
;; The idea here is that the 1 at the beginning starts a list of all
;; agenda elements labelled by (1 ...)  Now any element labelled simply
;; by '(1) appears on the list begun by the one; any element labelled by
;; something after the 1 as well appears on a sublist that is treated
;; recursively.  (So that the reason B above appears under the "2" is
;; that there are no additional elements on B's label.)  Note that the
;; agenda is kept in "order".

;; The macros push-agenda and pushs-agenda take a node or list of nodes
;; occuring at a fixed agenda position and add them to an agenda.

(defmacro push-agenda (node position agenda)
  `(setf ,agenda (push-agenda1 ,node ,position ,agenda)))

(defmacro pushs-agenda (nodes position agenda)
  `(dolist (node ,nodes)
     (setf ,agenda (push-agenda1 node ,position ,agenda))))

;; Add a node to an agenda.  It works recursively, by finding the agenda
;; element associated with the car of the position (creating it if
;; necessary) until the position is "used up" (i.e., NIL).  Then the
;; node is just pushed onto the agenda.  There are the following
;; cases:
;;  1.  If position is NIL, then just push the node onto the agenda.
;;  2.  Walk along the agenda.
;;   2a.  If you find an agenda element labelled with the same thing as
;;   (car position), then call push-agenda1 recursively.  The use of
;;   rplacd simultaneously adjusts this agenda element and returns the
;;   entire agenda.
;;   2b.  If you get to an agenda element labelled with something bigger
;;   than (car position), you know that there is no suitable item on the
;;   agenda.  In this case, "trailer" is what was left of the agenda
;;   before the last item was popped off, or NIL if nothing has been
;;   popped off yet.  Call push-agenda2 to insert a new entry at the
;;   front of the trailer.  (This is also done if you use up the whole
;;   agenda without finding a suitable element.)

(defun push-agenda1 (node position agenda)
  (cond ((null position) (cons node agenda))
	((atom position) agenda)
	(t (do ((l agenda (cdr l)) (trailer nil l))
	       ((null l) (push-agenda2 node position agenda trailer))
	     (when (consp (car l))
	       (cond ((= (car position) (caar l))
		      (rplacd (car l) 
			      (push-agenda1 node (cdr position) (cdar l)))
		      (return agenda))
		     ((< (car position) (caar l))
		      (return (push-agenda2 node position agenda
					    trailer)))))))))

;; Add a new entry to an agenda.  The arguments are the node, the
;; position, the complete agenda, and the trailer of the agenda, which
;; has the property that the new element should go between the first and
;; second elements of the trailer.  If the trailer is NIL, the new
;; element should go at the front of the agenda.

;; The first thing we do is construct the agenda element corresponding
;; to the position itself.  Thus if the position is (1 2 3) and the node
;; is A, we produce the list (1 (2 (3 A))).  The is done via the call to
;; reduce below; the result is then consed onto the tail of trailer.

;; There are now two cases:
;;  1.  If trailer is NIL, then the node is now (new-element . NIL) and
;;  since this is supposed to be at the front of the agenda, we need
;;  simply (rplacd node agenda).
;;  2.  If trailer is not NIL, then node is (new-element . right-place),
;;  where right-place is (cdr trailer) and is where the node belongs.
;;  So all we need do is (rplacd trailer node) and then return the
;;  agenda itself.

(defun push-agenda2 (node position agenda trailer)
  (setq node (cons (reduce #'list position :from-end t :initial-value node)
		   (cdr trailer)))
  (cond (trailer (rplacd trailer node) agenda)
	(t (rplacd node agenda))))

;; pop-agenda finds the first element from an agenda, pops it off and
;; returns it.  The agenda is modified by the macro.  The work is
;; actually done by pop-agenda1.

(defmacro pop-agenda (agenda) 
  `(let (agenda-answer)
     (declare (special agenda-answer))
     (setf ,agenda (pop-agenda1 ,agenda))
     agenda-answer))

;; Set agenda-answer to the first element of an agenda, and return the
;; modified agenda.  There are two cases:
;;  1.  If (car agenda) is a list, then we call pop-agenda1 on the cdr
;;  of this list to set agenda-answer to the right value, and store the
;;  result back in (cdar agenda).  The only subtlety is that if the
;;  result stored back into (cdar agenda) is NIL, then we might as well
;;  just return (cdr agenda), since the entry corresponding to this
;;  particular position has been wiped out.
;;  2.  If (car agenda) is not a list, then its car is the desired
;;  answer.

(defun pop-agenda1 (agenda)
  (declare (special agenda-answer))
  (cond ((consp (car agenda))
	 (rplacd (car agenda) (pop-agenda1 (cdar agenda)))
	 (if (cdar agenda) agenda (cdr agenda)))
	(t (setq agenda-answer (car agenda))
	   (cdr agenda))))
     
;; Removes an arbitrary element or elements from an agenda.  The agenda
;; is modified by the macro; the work is done by del-agenda1.  A flag is
;; maintained to indicate that the node has actually been found and
;; deleted (i.e., there is an implicit :count 1 argument).

(defmacro del-agenda (node agenda)
  `(let (agenda-doneflg)
     (declare (special agenda-doneflg))
     (setf ,agenda (del-agenda1 ,node ,agenda))))

(defmacro dels-agenda (nodes agenda)
  `(let (agenda-doneflg)
     (declare (special agenda-doneflg))
     (dolist (node ,nodes)
       (setq agenda-doneflg nil)
       (setf ,agenda (del-agenda1 node ,agenda)))))

;; Delete an element from an agenda and return the resulting agenda.
;; Essentially, the routine simply walks down the agenda, looking for
;; the given node.  If it is found, then splice it out of the list in
;; which it appears.  So if a particular agenda element is:
;;  1.  Equal to the given node, then mark that you've found it, and
;;  splice it out of this agenda element.
;;  2.  A list, then you are out of nodes at this level.  So splice it
;;  out of the next level, if possible, and then:
;;   2a.  If the next level becomes empty, call del-agenda2 to delete it
;;   from the current position.
;;   2b.  If the next level isn't empty but the flag indicates that you
;;   found the element in question, return the agenda (which has been
;;   destructively modified by now).

(defun del-agenda1 (node agenda)
  (declare (special agenda-doneflg))
  (do ((l agenda (cdr l)) (trailer nil l))
      ((null l) agenda)
    (cond ((eql node (car l))
	   (setq agenda-doneflg t)
	   (return (del-agenda2 agenda trailer)))
	  ((consp (car l))
	   (rplacd (car l) (del-agenda1 node (cdar l)))
	   (cond ((null (cdar l))
		  (return (del-agenda2 agenda trailer)))
		 (agenda-doneflg (return agenda)))))))

;; Remove from agenda the first element of trailer.  If trailer is NIL,
;; just remove the first element of the agenda by returning (cdr agenda).

(defun del-agenda2 (agenda trailer)
  (cond (trailer (pop (cdr trailer)) agenda)
	(t (cdr agenda))))

;; delete from an agenda all nodes satisfying a given predicate.
;; del-if-agenda assumes that its arg is a list of lists (as an agenda
;; is), while del-if-agenda-1 does basically the same thing for a list
;; that begins with an integer and then has either lists or single
;; entries following it.

(defun del-if-agenda (predicate agenda)
  (delete-if #'(lambda (x) (not (del-if-agenda-1 predicate x)))
	     agenda))

;; Here the arg is a list whose first element is ok and whose tail
;; consists of either conses or single elements.  We delete from the
;; tail anything that satisfies the predicate (if not a cons), or any
;; cons for which del-if-agenda-1 returns nil.  In order to make it all
;; work, del-if-agenda-1 returns the tail itself.

(defun del-if-agenda-1 (predicate agenda)
  (setf (cdr agenda)
	(delete-if #'(lambda (x)
		       (if (consp x) (not (del-if-agenda-1 predicate x))
			   (funcall predicate x)))
		   (cdr agenda))))

;; map over agenda items with a function

(defun mapc-agenda (fn agenda)
  (mapc #'(lambda (x) (if (atom x) (funcall fn x)
			(mapc-agenda fn (cdr x))))
	agenda))
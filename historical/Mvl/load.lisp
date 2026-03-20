;;; -*- Mode: LISP; Syntax: Common-lisp; Package: MVL; Base: 10 -*-

(in-package "MVL")

;; Global variables defined:
;; 
;; *bilattices*		list of available bilattices
;; true			true in current bilattice
;; false		false in current bilattice
;; unknown		unknown in current bilattice
;; bottom		bottom in current bilattice
;; monotonic-cutoff	splitting point below true in current bilattice
;; std-cutoffs		std-cutoffs in current bilattice
;; *active-bilattice*	current bilattice
;; 
;; Functions defined:
;; 
;; load-logic (&optional b)	loads a new bilattice.  If supplied, b can be a
;; 				bilattice character designator or an element 
;;				of *bilattice*.  If absent, prompts user.
;; 
;; choose-bilattice		Returns bilattice from *bilattices* selected
;;				by user.
;; 
;; bilattice (b)		Adds a new bilattice to *bilattices*
;; 

(defvar *bilattices* nil)
(defvar true)
(defvar false)
(defvar unknown)
(defvar bottom)
(defvar *success-test*)
(defvar *knowledge-test*)
(defvar monotonic-cutoff)
(defvar std-cutoffs)
(defvar *active-bilattice*)

(defvar binding-dag)
(defvar bdg-to-truth-val)
(defvar *modal-ops* nil)

(defconstant *never-succeeds* '(nil))
(defconstant *always-succeeds* nil)

;; definition of the bilattice structure

(defstruct (bilattice (:print-function print-bilattice))
  true false unknown bottom		;four distinguished elements
  cutoff-val				;lookup succeeds if t-gt this
  stash-val				;default stashing function
  unstash-val				;default unstashing function
  plus dot and or not			;bilattice operations
  eq					;equality check
  (kle nil) (tle nil)			;optional fast comparison checks
  (dws #'def-dws)			;dot with star
  (simplicity nil)			;how "simple" is a truth
					;value?  used to control prover
  (vars nil)				;what variables are in a truth value?
  (plug nil)				;plug a binding list into a
					;truth value
  (absorb nil)				;absorption function (described below)
  (modal-ops nil)			;standard modal operators need
					;to be constructed separately
  (print-fn nil)			;how to print a truth value
  long-desc short-desc			;long and short descriptions
  char					;one character identifier
  (type 'basic)				;what sort of a bilattice?
  (components nil)			;how was it constructed?
  )

(defun print-bilattice (b stream print-depth)
  (declare (ignore print-depth))
  (format stream "~a bilattice" (bilattice-short-desc b)))

;; a modal operator is described using a name (e.g., L), a bilattice
;; function, a list of n flags indicating whether or not the nth
;; argument is a parameter

(defstruct modal-operator
  name function (parameters nil))

;; A particularly simple modal operator is the identity function.  This
;; can be used as a semantic marker for a point to break the proof
;; process.

(defparameter idn (make-modal-operator :name 'idn :function #'identity))

;; quantifiers are also handled modally.  The function isn't really the
;; identity, but is established when the special bilattice
;; bdg-to-truth-val is constructed.  It *is* identity for the base
;; bilattice.

(defparameter forall
	      (make-modal-operator :name 'forall :function #'identity
				   :parameters '(t)))

(defparameter exists
	      (make-modal-operator :name 'exists :function #'identity
				   :parameters '(t)))

(defparameter *std-modal-ops* (list idn forall exists))

(defun make-standard-modal-ops (bilattice)
  (dolist (op *std-modal-ops* bilattice)
    (bilattice-has-modal-operator bilattice op)))

(defun nonstandard-modal-ops (bilattice)
  (set-difference (bilattice-modal-ops bilattice) *std-modal-ops*
		  :key #'modal-operator-name))

;; Record that a given bilattice has a particular modal operator.  First
;; delete any existing copy of the modal operator, and then push the
;; modal operator back onto the list of operators for this particular
;; bilattice.  Everything is keyed off the name of the modal operator.

(defun bilattice-has-modal-operator (bilattice modal-op)
  (popf (bilattice-modal-ops bilattice) (modal-operator-name modal-op)
	:key #'modal-operator-name)
  (push modal-op (bilattice-modal-ops bilattice)))

;; Load a given bilattice, querying if necessary.  This is the normal
;; way to change logics without reloading MVL.  Also called when
;; performing a load-system or compile-system.  Also sets
;; bdg-to-truth-val as the bilattice of functions from bindings into
;; truth values and establishes the quantifier modal opearators on this
;; bilattice.  Returns a description of the bilattice just loaded.

#+Genera (defvar zwei:*zweimvl-stash-value*)
#+Genera (defvar zwei:*zweimvl-stash-function*)

#+Allegro (defvar *fi-stash-value*)
#+Allegro (defvar *fi-stash-function*)

(defun load-logic (&optional (b (choose-bilattice)))
  (when (characterp b)
    (setq b (or (bilattice-with-char b) (choose-bilattice))))
  (if b (load-logic-1 b))
  (setq bdg-to-truth-val (dag-bilattice binding-dag *active-bilattice*))
  (create-quantifier-modalities)
  #+Genera (setq zwei:*zweimvl-stash-value* nil		;reset editor interface
		 zwei:*zweimvl-stash-function* nil)
  #+Allegro (setq *fi-stash-value* nil *fi-stash-function* nil)
  (bilattice-long-desc *active-bilattice*))

;; The grunt work of loading a new bilattice is done here.  First do an
;; (empty) if there was already a bilattice loaded or a (dinit)
;; otherwise and remove any modal operators.  Then:
;;  1.  Set *active-bilattice* to the new value
;;  2.  Establish the truth values true, false, unknown, bottom,
;;      *success-test* (used to terminate the prover), *knowledge-test*
;;      (used in contents) and monotonic-cutoff
;;  3.  Establish the std cutoffs value
;;  4.  Set up the list of new modal operators
;;  5.  Define the modal operators themselves by importing them into the
;;  current package
;;  6.  For each modal operator,
;;   6a.  Associate the modal operator itself to its name
;;   6b.  Record that expressions involving this modal operator cannot
;;   be stashed.

(defun load-logic-1 (b)
  (if (and (boundp '*active-bilattice*) *active-bilattice* (fboundp 'empty))
      (empty) (dinit))
  (dolist (item *modal-ops*) (rem-mvl item 'modal-op) (rem-mvl item 'stash))
  (setq *active-bilattice* b
	true (bilattice-true b)
	false (bilattice-false b)
	unknown (bilattice-unknown b)
	bottom (bilattice-bottom b)
	*success-test* `((,(make-test :value true :tag 't-ge)))
	*knowledge-test* `((,(make-test :value unknown :tag 'k-not-le)))
	monotonic-cutoff (splitting-point-below true)
	std-cutoffs `((,(make-test :value (bilattice-cutoff-val b) 
				   :tag 't-not-le)))
	*modal-ops* (mapcar #'modal-operator-name (bilattice-modal-ops b)))
  (import *modal-ops*)
  (dolist (op (bilattice-modal-ops b))
    (setf (get-mvl (modal-operator-name op) 'modal-op) op)
    (setf (get-mvl (modal-operator-name op) 'stash) #'stash-modal-exp)))

;; You can't stash a modal expression.

(defun stash-modal-exp (p &key &allow-other-keys)
  (cerror "Continue without stashing ~a."
	  "~a involves a modal operator.~%Cannot stash." p))

;; A variety of functions are defined in terms of bilattice parameters.
;; They are:
;;  stash-value, unstash-value -- default values for stashing and
;;    unstashing sentences
;;  mvl-plus etc -- bilattice functions themselves
;;  dot-with-star -- bilattice function that defaults to unknown
;;  mvl-simplicity, vars, plug -- bilattice functions for plugging, etc.
;;  display-value -- how to print out a truth value
;; All of these functions accept an optional bilattice argument that
;; defaults to the currently active bilattice.

(defmacro bilattice-fn (fn args defining-fn)
  `(defun ,fn (,@args &optional (b *active-bilattice*))
     (funcall (,defining-fn b) . ,args)))

(bilattice-fn stash-value (x) bilattice-stash-val)
(bilattice-fn unstash-value (x) bilattice-unstash-val)
(bilattice-fn mvl-plus (x y) bilattice-plus)
(bilattice-fn mvl-dot (x y) bilattice-dot)
(bilattice-fn mvl-and (x y) bilattice-and)
(bilattice-fn mvl-or (x y) bilattice-or)
(bilattice-fn mvl-not (x) bilattice-not)
(bilattice-fn mvl-eq (x y) bilattice-eq)
(bilattice-fn dot-with-star (x y) bilattice-dws)

;; by default, simplicity is just (0) and vars-in is NIL

(defun mvl-simplicity (x &optional (b *active-bilattice*)
		       &aux (fn (bilattice-simplicity b)))
  (if fn (funcall fn x) '(0)))

(defun mvl-vars (x &optional (b *active-bilattice*)
		 &aux (fn (bilattice-vars b)))
  (if fn (funcall fn x)))

;; plugging: if bdg is NIL or the plugging function is the default, just
;; return the value.  The exceptions are things like the first-order atms
;; bilattice, where the truth value reflects the choice for instantiation
;; of a database sentence.

(defun mvl-plug (x y &optional (b *active-bilattice*)
		 &aux (fn (bilattice-plug b)))
  (if (and y fn) (funcall fn x y) x))

;; absorption.  Suppose that multiple proof paths have returned multiple
;; answers to a query, one with binding list b1 and answer v1 and another
;; with binding list b2 and answer v2.  Now, b1 and b2 may bind variables
;; that appear not in the query, but only in v1 and v2.  How are we to
;; construct a single answer to return? Consider a situation in which the
;; apparent answer for a query involving no variables is:
;;  b1=NIL v1=the dag-list taking NIL to U and (? x) to T
;;  b2=(? = a) v2=U
;; Now the real answer should take values:
;;  NIL -> U
;;  (? x) -> T
;;  (a x) -> U
;; where we've "plugged in" the potential binding of ? to a.

;; If non-NIL, the absorption function is expected to handle this.  The
;; "local" part of the computation accepts a current val (such as v1 above),
;; an incremental binding (b2 above), and a new val (v2 above).  It returns
;; v1 modified to incorporate the contribution from v2.  This function
;; should in fact only be called with bilattices with nontrivial absorption
;; functions, but we handle that also just in case ...

(defun mvl-absorb (current incremental-bdgs new 
		   &optional (b *active-bilattice*)
		   &aux (f (bilattice-absorb b)))
  (if f (funcall f current incremental-bdgs new) (mvl-plus current new b)))

(defun def-dws (x y)
  (declare (ignore x y)) unknown)

;; is x unknown in this bilattice?

(defun mvl-unk (x &optional (b *active-bilattice*))
  (mvl-eq x (bilattice-unknown b) b))

;; compute t-grounded and f-grounded parts

(defun mvl-t-ground (x &optional (b *active-bilattice*))
  (mvl-or x (bilattice-unknown b) b))

(defun mvl-f-ground (x &optional (b *active-bilattice*))
  (mvl-and x (bilattice-unknown b) b))

;; x is on the top stratification level in all components if it is k-gt
;; the splitting point below true (stored as monotonic-cutoff for the
;; active bilattice)

(defun monotonic-value (x &optional (b *active-bilattice*))
  (k-gt x (if (eql b *active-bilattice*) monotonic-cutoff
	    (splitting-point-below (bilattice-true b) b))
	b))

;; Allows the user to choose a bilattice from a menu.  The menu is
;; alphabetized first ...

(defun choose-bilattice
    (&aux (bs (sort (copy-list *bilattices*) #'char< :key #'bilattice-char)))
  (query t (:list-choices nil)
	 (mapcar #'(lambda (b) (list b (bilattice-long-desc b)
				     (string (bilattice-char b)))) bs)
	 "~%~A~%~%Select a logic by letter: "
	 (format nil "~:{~%  (~C)  ~A~}"
		 (mapcar #'(lambda (b) (list (bilattice-char b)
					     (bilattice-short-desc b)))
			 bs))))

;; Record the fact that b is a bilattice.  First remove any other
;; bilattice with the same one-character identifier from the list of
;; active bilattices.  Then push the given bilattice onto the list.

(defun bilattice (b)
  (when (find (bilattice-char b) *bilattices* :key #'bilattice-char)
    (warn "Removing old copy of bilattice for character ~a."
	  (bilattice-char b))
    (popf *bilattices* (bilattice-char b) :key #'bilattice-char :count 1))
  (push b *bilattices*))

;; Record the fact that the long/short descriptions and one-character
;; identifier for the bilattice b are as given.

(defun describe-bilattice (b long short char)
  (setf (bilattice-long-desc b) long
	(bilattice-short-desc b) short
	(bilattice-char b) char))

;; Find the bilattice identified by the character char.

(defun bilattice-with-char (char)
  (find char *bilattices* :key #'bilattice-char))

;; Return the first available character that has not yet been assigned
;; to any bilattice.  The optional argument is the character desired.

;; If the optional argument is missing, or the character is taken, just
;; find the first available character.  Otherwise, use the desired
;; character.

(defun bilattice-find-char (&optional char)
  (if (or (not char) (bilattice-with-char char))
      (find-if-not #'bilattice-with-char "abcdefghijklmnopqrstuvwxyz")
    char))

;; For printing truth values, it's sometimes useful to invoke the
;; pretty printer.  So we define a structure truth-value-to-print
;; that has as fields the truth value and the bilattice being used
;; and is printed using a special function.

(defstruct (truth-value-to-print (:print-function display-truth-value))
  x b)

(defun display-truth-value (z stream print-depth 
			    &aux (x (truth-value-to-print-x z))
				 (b (truth-value-to-print-b z)))
  (declare (ignore print-depth))
  (let ((*print-pretty* t))
    (display-value x b stream)))

;; To invoke this stuff, we simply call mvl-print on the value in question
;; (possibly with a bilattice argument).  This makes an instance of the
;; above structure, which is then printed with display-value.

(defun mvl-print (x &optional (b *active-bilattice*))
  (make-truth-value-to-print :x x :b b))

;; display-value:  The extremal points of the bilattice are easy.
;; Otherwise, we invoke the print function associated with the bilattice
;; to do the work.  If there isn't one, we just print it out.

(defun display-value (x b stream &aux fn)
  (cond ((mvl-unk x b) (format stream "U"))
	((mvl-eq x (bilattice-true b) b) (format stream "T"))
	((mvl-eq x (bilattice-false b) b) (format stream "F"))
	((mvl-eq x (bilattice-bottom b) b) (format stream "T/F"))
	((setq fn (bilattice-print-fn b)) (funcall fn x b stream))
	(t (format stream "~a" x))))
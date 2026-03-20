;; -*- Mode: LISP; Syntax: Common-lisp; Package: MVL; Base: 10 -*-

(in-package "MVL")

;; The basic aim in this file is to establish the junk needed to execute
;; cutoff tests -- mostly the functions associated with each tag.  To do
;; that, we first have to define all of the cutoff functions, and then
;; to associate them to the tags of the same name.  Dot-with-not is also
;; defined here.

;; functions defined:
;; 
;; bilattice comparison functions:
;; 
;;   k-le k-lt k-ge k-gt k-not-le k-not-lt k-not-ge k-not-gt
;;   t-le t-lt t-ge t-gt t-not-le t-not-lt t-not-ge t-not-gt
;; 
;; dot-with-not (x)		compute x.-x

(defvar unknown)
(defvar *active-bilattice*)
(defvar *always-succeeds*)
(defvar *never-succeeds*)

;; auxiliary functions k-le lt ge gt not-le not-lt not-ge not-gt etc

;; as an example, x is k-le y if x.y=x; any bilattice may also supply a
;; special (and presumably faster!) version of k-le and t-le which are
;; then used to compute all of the other comparitors.

;; If the bilattice is supplied, use that; otherwise, use the standard
;; one.

(defun k-le (x y &optional (b *active-bilattice*) &aux (fn (bilattice-kle b)))
  (if fn (funcall fn x y)
    (mvl-eq (mvl-dot x y b) x b)))

(defun k-ge (x y &optional (b *active-bilattice*))
  (k-le y x b))

(defun t-le (x y &optional (b *active-bilattice*) &aux (fn (bilattice-tle b)))
  (if fn (funcall fn x y)
    (mvl-eq (mvl-and x y b) x b)))

(defun t-ge (x y &optional (b *active-bilattice*))
  (t-le y x b))

(defun k-lt (x y &optional (b *active-bilattice*))
  (and (not (mvl-eq x y b)) (k-le x y b)))

(defun k-gt (x y &optional (b *active-bilattice*))
  (and (not (mvl-eq x y b)) (k-le y x b)))

(defun t-lt (x y &optional (b *active-bilattice*))
  (and (not (mvl-eq x y b)) (t-le x y b)))

(defun t-gt (x y &optional (b *active-bilattice*))
  (and (not (mvl-eq x y b)) (t-le y x b)))

(defun k-not-le (x y &optional (b *active-bilattice*)) (not (k-le x y b)))
(defun k-not-ge (x y &optional (b *active-bilattice*)) (not (k-le y x b)))
(defun t-not-le (x y &optional (b *active-bilattice*)) (not (t-le x y b)))
(defun t-not-ge (x y &optional (b *active-bilattice*)) (not (t-le y x b)))
(defun k-not-lt (x y &optional (b *active-bilattice*)) (not (k-lt x y b)))
(defun k-not-gt (x y &optional (b *active-bilattice*)) (not (k-gt x y b)))
(defun t-not-lt (x y &optional (b *active-bilattice*)) (not (t-lt x y b)))
(defun t-not-gt (x y &optional (b *active-bilattice*)) (not (t-gt x y b)))

(defun dot-with-not (x &optional (b *active-bilattice*))
  (mvl-dot x (mvl-not x b) b))

;; the way we associate tags with their lisp versions is simply to put
;; the lisp version on the tag's fn property.  The following macro does
;; that; then we invoke it for each tag.

(defmacro lisp-fn (fn)
  `(setf (get ',fn 'fn) #',fn))

(lisp-fn t-le)
(lisp-fn t-ge)
(lisp-fn t-lt)
(lisp-fn t-gt)
(lisp-fn t-not-le)
(lisp-fn t-not-ge)
(lisp-fn t-not-lt)
(lisp-fn t-not-gt)
(lisp-fn k-le)
(lisp-fn k-ge)
(lisp-fn k-lt)
(lisp-fn k-gt)
(lisp-fn k-not-le)
(lisp-fn k-not-ge)
(lisp-fn k-not-lt)
(lisp-fn k-not-gt)

;; on the tag's tag-not property is that tag that is the t-flip of the
;; given tag

(defun tag-not (tag) (get tag 'tag-not))

(defmacro set-tag-not (symbol tag)
  `(setf (get ',symbol 'tag-not) ',tag))

(set-tag-not t-le t-ge)
(set-tag-not t-ge t-le)
(set-tag-not t-lt t-gt)
(set-tag-not t-gt t-lt)
(set-tag-not t-not-le t-not-ge)
(set-tag-not t-not-ge t-not-le)
(set-tag-not t-not-lt t-not-gt)
(set-tag-not t-not-gt t-not-lt)
(set-tag-not k-le k-le)
(set-tag-not k-ge k-ge)
(set-tag-not k-lt k-lt)
(set-tag-not k-gt k-gt)
(set-tag-not k-not-le k-not-le)
(set-tag-not k-not-ge k-not-ge)
(set-tag-not k-not-lt k-not-lt)
(set-tag-not k-not-gt k-not-gt)

;; cutoffs are expressed in dnf, where the base-level elements are
;; tests.  A <test> is a field consisting of a truth value and a tag.
;; The story is that the truth value x has to satisfy the given property
;; with respect to the given value.

(defstruct test
  value tag)

;; logical ops on two sets of cutoff information; likely to be useful in 
;; constructing less trivial cutoff modifiers.

;; To disjoin a set of cutoffs, work through them one at a time

(defun cutoff-or (&rest args)
  (if args (reduce #'co-1 args) *never-succeeds*))

;; disjoin a pair of cutoffs.  If either is NIL, return NIL.  If not,
;; construct a list by appending each element of c1 to each element of
;; c2.

(defun co-1 (c1 c2)
  (when (and c1 c2)
    (mapcan #'(lambda (conj1)
		(mapcar #'(lambda (conj2) 
			    (append conj1 conj2)) c2)) c1)))

;; conjoining cutoffs is easy, since each is already a conjunction!

(defun cutoff-and (&rest args)
  (apply #'append args))

;; here, we take cutoffs c and produce a new cutoffs d such that x
;; satisfies d if and only if the negation of x satisfies c.  Of course,
;; we can do it one conjunct at a time ...

(defun cutoffs-not (cutoffs &optional (b *active-bilattice*))
  (mapcar #'(lambda (x) (cutoffs-not-1 x b)) cutoffs))

;; and within a conjunct, we can do it one disjunct at a time, so all we
;; really have to do is "invert" a test (value . tag), which we can do
;; simply by negating the value and finding the tag that is the
;; "tag-not" of the given one.

(defun cutoffs-not-1 (c b)
  (mapcar #'(lambda (x) (make-test :value (mvl-not (test-value x) b)
				   :tag (tag-not (test-tag x))))
	  c))

;; to test a value and a cutoffs, make sure that the test passes every
;; conjunct in the cutoffs

(defun test (value cutoffs &optional (bilattice *active-bilattice*))
  (every #'(lambda (x) (test-1 value x bilattice)) cutoffs))

;; to test a value on a disjunction, it has to pass some clause

(defun test-1 (value disj-cutoffs bilattice)
  (some #'(lambda (x) (test-2 value x bilattice)) disj-cutoffs))

(defun test-2 (value test bilattice)
  (funcall (get (test-tag test) 'fn)
	   value (test-value test)
	   bilattice))

;; compute the cutoffs that can be assigned to every term in a conjunct if 
;; the conjunction is to have a truth value satisfying some fixed test.  
;; The calculation can be done a disjunct at a time ...

(defun term-cutoffs (cutoffs &aux ans d)
  (dolist (disj cutoffs ans)
    (if (setq d (term-disj disj)) (push d ans))))

;; ... and a term at a time, although here, if it is possible to satisfy
;; one disjunct at the very end, it's possible to satisfy the whole
;; disjunction at the last minute.  So in this case, we just return nil.

(defun term-disj (disj &aux ans tt)
  (dolist (term disj ans)
    (if (setq tt (term-term term)) (push tt ans) (return nil))))

;; ... to handle a term, we see if it is of the type that will affect
;; each term in the hypothetical conjunction.  Thus, t-ge is, since if a
;; conjunction is to be t-ge a certain value, each term must be.  But
;; k-lt is not.  k-ge sort of is; if a conjunction is to be k-ge a
;; value, then each term must be k-ge the splitting point below that
;; value.  And so on.

;; The splitting point below x is gt(x).-gt(x) + gf(x).-gf(x)

(defun splitting-point-below (x &optional (b *active-bilattice*))
  (mvl-plus (dot-with-not (mvl-t-ground x b) b)
	    (dot-with-not (mvl-f-ground x b) b) b))

;; The tag's <term-tag> property, if not empty, is a function that can
;; be applied to the value of the term to get the value for the new
;; test.  The tag is assumed to be unchanged.

(defun term-term (term &aux (fn (get (test-tag term) 'term-tag)))
  (and fn (make-test :value (funcall fn (test-value term))
		     :tag (test-tag term))))

(defmacro set-term-tag (symbol tag)
  `(setf (get ',symbol 'term-tag) (function ,tag)))

(set-term-tag t-ge identity)
(set-term-tag t-gt identity)
(set-term-tag t-not-le identity)
(set-term-tag t-not-lt identity)
(set-term-tag k-ge splitting-point-below)
(set-term-tag k-gt splitting-point-below)
(set-term-tag k-not-le splitting-point-below)
(set-term-tag k-not-lt splitting-point-below)

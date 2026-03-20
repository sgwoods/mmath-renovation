;;; -*- Mode: LISP; Syntax: Common-lisp; Package: MVL; Base: 10 -*-

(in-package "MVL")

;; functions defined:
;; 
;; lookup (p &key cutoffs inv allow-procedural-attachment)
;; 			Finds all instantiations of p that satisfy cutoffs.
;;			Returns single answer, but three values: an answer,
;;			the bound proposition, and the source of the answer
;; 
;; lookups (p &key cutoffs inv allow-procedural-attachment)
;; 			Same as lookup, but returns list of answers.

;; look for a proposition in the MVL database.  There are a lot of cases:
;;  1.  If the cutoffs are hopeless, then just return failure.
;;  2.  If (car p) is a modal operator, then:
;;   2a.  If succeed-on-modal-ops is T, succeed returning values true
;;   (or false if the inversion flag is T), p and "modal" (the third
;;   value indicates the source of the match).
;;   2b.  If succeed-on-modal-ops is NIL, we have to look for it.  So we
;;   invoke modal-lookup to do that.
;;  3.  If there is an allowed procedural attachment to lookup, we
;;  invoke that.
;;  4.  If there is an allowed procudural attachment to lookups, we
;;  invoke that and singularize the result.
;;  5.  If (car p) is "not", we flip the cutoffs and the inversion flag
;;  (so that we know to negate any eventual truth values), strip off the
;;  leading not, and try again.  When we return, we invert the truth
;;  value in any answer found and negate any proposition used.
;;  6.  The real case is where we actually have to look for the
;;  proposition in the database!  lookp returns a list of possible
;;  matches; for each (and for each binding of the query), we need to
;;  do the following:
;;   6a.  Modify the truth value to incorporate the database bindings
;;   if necessary.
;;   6b.  Make sure the truth value passes the cutoff test.
;;   6c.  If the truth value is on the top stratification level, return
;;   it.  Otherwise, include any additional contributions from bindings
;;   that are generalizations of the given one, and check to see that
;;   the accumulated truth value satisfies the cutoffs.  This check is
;;   to handle cases where (foo ?x) has truth value dt but (foo fred)
;;   has truth value false.  Now looking up (foo fred) should fail.
;;   6d.  If all this works, we return two values -- an answer
;;   containing the computed binding list and value and the DB sentence
;;   that led to the match.
;;  7.  If we *still* haven't found an answer, then return (db poss
;;  cutoffs), which checks to see if unknown is good enough and returns
;;  that if p isn't in the database at all.

(defun lookup (p &key (cutoffs std-cutoffs) inv (allow-procedural-attachment t)
	       succeed-on-modal-ops)
  (cond ((equal cutoffs *never-succeeds*) nil)
	((get-mvl (car p) 'modal-op)
	 (if succeed-on-modal-ops
	     (if (test (if inv false true) cutoffs)
		 (values (make-answer :value (if inv false true)) 'modal))
	   (modal-lookup (car p) (cdr p) cutoffs allow-procedural-attachment)))
	((and allow-procedural-attachment (get-mvl (car p) 'lookup))
	 (lookup-call (get-mvl (car p) 'lookup) p :cutoffs cutoffs))
	((and allow-procedural-attachment (get-mvl (car p) 'lookups))
	 (multiple-value-bind (answers xs)
	     (lookups-call (get-mvl (car p) 'lookups) p :cutoffs cutoffs)
	   (values (car answers) (car xs))))
	((eq 'not (car p))
	 (multiple-value-bind (a x)
	     (lookup (second p) :cutoffs (cutoffs-not cutoffs) :inv (not inv)
		     :allow-procedural-attachment allow-procedural-attachment
		     :succeed-on-modal-ops succeed-on-modal-ops)
	   (if a (values (invert-answer a) x))))
	(t (let ((poss (lookp p)) tv)
	     (dolist (item poss (db poss cutoffs))
	       (dolist (bdgs (cdr item))
		 (setq tv (mvl-plug (truth-value (car item)) (cdr bdgs)))
		 (when (and (test tv cutoffs)
			    (or (monotonic-value tv)
				(test (setq tv (include-other-contributions
						 tv item poss bdgs))
				      cutoffs)))
		   (return-from lookup
		     (values (make-answer :binding (car bdgs) :value tv)
			     (denotes (car item)))))))))))

;; this function takes a truth value tv and updates it to include any
;; contributions from database lookup of more specific sentences, as
;; discussed above.  What we do is work through the list of possible
;; matches; for any that is different from the current one, if its
;; bindings are more specific than the given ones, we incorporate the
;; new truth value into the old one.

(defun include-other-contributions (tv i poss bdgs &aux (ans tv))
  (dolist (item poss ans)
    (unless (eq item i)
      (dolist (dum (cdr item))
	(when (binding-le (car bdgs) (car dum))
	  (setq ans (mvl-plus ans (mvl-plug (truth-value (car item))
					    (cdr dum)))))))))

;; here we handle the case where nothing else works.  If we never found
;; the proposition in the database and "unknown" is good enough, we
;; return that.

(defun db (poss cutoffs)
  (when (missing-from-db poss cutoffs)
    (make-answer :value unknown)))

;; lookups is basically just like lookup.  Here are the principal differences:
;;  1.  The procedural attachments are checked in the other order, and
;;  if one for lookup is used, the result has to be pluralized.
;;  2.  In the basic case, we accumulate the answers instead of
;;  returning the first one found.
;;  3.  We call the plural version dbs instead of db.

(defun lookups (p &key (cutoffs std-cutoffs) inv
		       (allow-procedural-attachment t) succeed-on-modal-ops)
  (cond	((equal cutoffs *never-succeeds*) nil)
	((get-mvl (car p) 'modal-op)
	 (if succeed-on-modal-ops
	     (if (test (if inv false true) cutoffs)
		 (values (list (make-answer :value (if inv false true)))
			 (list 'modal)))
	   (modal-lookups (car p) (cdr p) cutoffs
			  allow-procedural-attachment)))
	((and allow-procedural-attachment (get-mvl (car p) 'lookups))
	 (lookups-call (get-mvl (car p) 'lookups) p :cutoffs cutoffs))
	((and allow-procedural-attachment (get-mvl (car p) 'lookup))
	 (multiple-value-bind (ans x)
	     (lookup-call (get-mvl (car p) 'lookup) p :cutoffs cutoffs)
	   (if ans (values (list ans) (list x)))))
	((eq 'not (car p))
	 (multiple-value-bind (ansl xl)
	     (lookups (second p) :cutoffs (cutoffs-not cutoffs) :inv (not inv)
		      :allow-procedural-attachment allow-procedural-attachment
		      :succeed-on-modal-ops succeed-on-modal-ops)
	   (if ansl (values (napcar #'invert-answer ansl) xl))))
	(t (let ((poss (lookp p)) ansl pl tv)
	     (dolist (item poss (dbs poss cutoffs ansl pl))
	       (dolist (bdgs (cdr item))
		 (setq tv (mvl-plug (truth-value (car item)) (cdr bdgs)))
		 (when (and (test tv cutoffs)
			    (or (monotonic-value tv)
				(test (setq tv (include-other-contributions
						 tv item poss bdgs))
				      cutoffs)))
		   (push (make-answer :binding (car bdgs) :value tv) ansl)
		   (push (denotes (car item)) pl))))))))

;; dbs is the plural version of db

(defun dbs (poss cutoffs ansl pl)
  (when (and (not (find nil ansl :key #'answer-binding))
	     (missing-from-db poss cutoffs))
    (push (make-answer :value unknown) ansl) (push nil pl))
  (values (nreverse ansl) (nreverse pl)))

;; is the proposition missing from the database, and is "unknown" an
;; acceptable answer?  Yes if NIL isn't a possible binding, and unknown
;; passes the cutoff test.  Since NIL would be the only binding if it's
;; on the list, we need to see if (cadr poss) is non-NIL for each poss; the
;; cdr is the list of bindings.

(defun missing-from-db (poss cutoffs)
  (and (test unknown cutoffs) (every #'cadr poss)))

;; lookup a modal proposition.  It is potentially a mess, since we have
;; to worry about all the different bindings for all of the
;; propositions.  But there is an easier way to do it -- we look them up
;; normally, convert the collections of bindings returned to an element
;; of the compound bilattice bdg-to-truth-val, and then apply the modal
;; operator from *that* bilattice before unwinding everything.  The
;; function ml-1 is invoked to get the results of looking for the
;; individual propositions as an element of bdg-to-truth-val, and then
;; the modal operator is applied.  Finally, and we invoke
;; dag-list-of-answers to get a list of the actual answers in the base
;; bilattice.  Each of these is then tested to see if it passes the
;; cutoff test and if one does, it is returned.

(defvar bdg-to-truth-val)

(defun modal-lookup (modal-op props cutoffs allow)
  (dolist (item (dag-list-of-answers
		 (operate-modally props (bdg-modal-op modal-op)
				  #'(lambda (x) (ml-1 x allow)))))
    (when (test (answer-value item) cutoffs)
      (return (values item 'modal)))))

;; given a proposition, look it up and construct elements of
;; bdg-to-truth-val that contain the results.  Make sure to look up both
;; the proposition and its negation.

(defun ml-1 (prop allow-procedural-attachment)
  (mvl-plus (construct-bdg-val (lookups prop :cutoffs *always-succeeds* 
					:allow-procedural-attachment
					allow-procedural-attachment))
	    (mvl-not (construct-bdg-val
		       (lookups (negate prop) :cutoffs *always-succeeds* :inv t
				:allow-procedural-attachment
				allow-procedural-attachment))
		     bdg-to-truth-val)
	    bdg-to-truth-val))

;; modal-lookups is just the same, but we collect the answers that pass
;; the cutoff test instead of returning the first one.

(defun modal-lookups (modal-op props cutoffs allow &aux ansl xl)
  (dolist (item (dag-list-of-answers
		 (operate-modally props (bdg-modal-op modal-op)
				  #'(lambda (x) (ml-1 x allow))))
		(values (nreverse ansl) xl))
    (when (test (answer-value item) cutoffs)
      (push item ansl)
      (push 'modal xl))))

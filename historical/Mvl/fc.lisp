;;; -*- Mode: LISP; Syntax: Common-lisp; Package: MVL; Base: 10 -*-

(in-package "MVL")

;; functions defined:
;;
;; erase (prop &key value decrement-p cutoffs)
;;				Like unstash, but forward chain on result.
;; 
;; fc (p &key value increment-p cutoffs)
;; 				Like stash, but forward chain on result.

#-ANSI (proclaim '(declaration dynamic-extent))

(defparameter *fc-trace* nil)

(defun erase (prop &key (value (unstash-value prop)) decrement-p
			(cutoffs std-cutoffs))
  (fc prop :value value :increment-p decrement-p :cutoffs cutoffs))

;; A place to put auxiliary information needed by the forward chainer.
;; Meanings of the various fields:
;;
;;   increment-p	When stashing a value, should you increment an existing
;;			value or replace it?  Default = NIL (replace)
;;   fc-increment-p	When forward chaining, and information content has
;;			*fallen*, should that be propagated to apparent
;;			consequences?  Default = T
;;   cutoffs		Cutoff information to decide to foward chain.  What's
;;			actually tested is the symmetric difference between
;;			the new and old values.
;;   term-cutoffs	Used to test terms in the conjunctive premises of the
;;			rules used.
;;   include-modal	If T (the default), also forward chain on rules that
;;			fire because a modal expression changes truth value.
;;			It's expensive to find them, though, which is why this
;;			flag is allowed.  [They have to occur at the top
;;			level, as well.]

(defstruct fc-info
  increment-p fc-increment-p
  cutoffs term-cutoffs
  include-modal)

;; Place to dump the results of looking for modal expressions that may cause
;; forward chaining.  Fields:
;;
;;   prop		The modal proposition that triggers the rule.
;;   parity		Does the modal proposition appear positively or
;;			negatively?
;;   value		The current value of this modal proposition, expressed
;;			as an element of bdg-to-truth-val.
;;   implication-value	Truth value of the rule itself.
;;   conclusion		The conclusion of the rule.
;;   conjuncts		Conjuncts still to be checked in the rule.
;;   bdgs		Variable bindings in the original sentence being
;;			chained upon.

(defstruct fc-modal
  prop parity
  value implication-value
  conclusion conjuncts bdgs)

;; Forward chainer.  Just call fc-1 with the current truth value.  The
;; value is computed by lookup-with-vars, since that's the fastest way
;; to make sure we do it right if it's a conjunction.  (Even though the
;; thing has no variables!)  fc-aux-info is a global variable, so that we
;; don't have to pass it around all over the place.

(defvar fc-aux-info)

(defun fc (p &key (value (stash-value p)) increment-p (fc-increment-p t) 
		  (cutoffs std-cutoffs) (include-modal t)
	   &aux (fc-aux-info (make-fc-info :increment-p increment-p
					   :fc-increment-p fc-increment-p
					   :cutoffs cutoffs
					   :term-cutoffs (term-cutoffs cutoffs)
					   :include-modal include-modal)))
  (fc-1 p value (lookup-after-grounding p)))

(defun lookup-after-grounding (p)
  (dag-root-val (dag-fn-list (lookup-with-vars (gensymize p)))))

;; replace the variables in prop with Skolem constants

(defun gensymize (prop)
  (plug prop (gen-bdgs prop)))

;; Compute the bindings needed to "gensymize" a proposition.  For each
;; variable in the proposition, either bind it to a gentemp or, if it is
;; a * variable, bind it to a list containing a single gentemp.

(defun gen-bdgs (prop)
  (napcar #'(lambda (x)
	      (cons x (if (varp* x) (list (gentemp "G")) (gentemp "G"))))
	  (vars-in prop)))

;; The work of the forward chaining is done here.  First we see if we
;; should forward chain on the positive/negative versions of the given
;; proposition.  If either is true, we also get a list of the rules
;; involving modal expressions.  Then we change the truth value of p,
;; and then do the forward chaining on p (if appropriate), on the
;; negation of p (if appropriate), and on the modal rules.

(defun fc-1 (p value old-val &aux modals
	     (pos-test (fc-test old-val value))
	     (neg-test (fc-test (mvl-not old-val) (mvl-not value))))
  (when (and (or pos-test neg-test) (fc-info-include-modal fc-aux-info))
    (setq modals (modal-fc p)))
  (when (traced-prop p *fc-trace*)
    (format t "~%FC: Stashing ~a~:[~; with truth value ~<~%~:;~a~>~]."
	    p *show-truth-values* (mvl-print value bdg-to-truth-val))
    (unless (or pos-test neg-test)
      (format t "~% (No need to forward chain.)")))
  (stash p :value value :increment-p (fc-info-increment-p fc-aux-info))
  (when pos-test (real-fc p old-val value))
  (when neg-test (real-fc (negate p) (mvl-not old-val) (mvl-not value)))
  (when (and (or pos-test neg-test) (fc-info-include-modal fc-aux-info))
    (fc-m modals)))

(defun fc-trace (&optional (pat '(?*)))
  (add-trace '*fc-trace* pat))

(defun fc-untrace (&optional (pat '(?*)))
  (remove-trace '*fc-trace* pat))

;; Should you forward chain or not?  Yes, provided that either:
;;  1.  The new information (as computed by (dot-with-star new old))
;;  passes the cutoff test, or
;;  2.  You are going to FC on information decrease, and 
;;  (dot-with-star old new) passes the cutoff test.
;; In either case, you only care about the "true" part of old-val and
;; new-val.
  
(defun fc-test (old-val new-val)
  (setq old-val (mvl-t-ground old-val)
	new-val (mvl-t-ground new-val))
  (or (test (dot-with-star new-val old-val) (fc-info-cutoffs fc-aux-info))
      (and (fc-info-fc-increment-p fc-aux-info)
	   (test (dot-with-star old-val new-val)
		 (fc-info-cutoffs fc-aux-info)))))

;; Find the rules that might be relevant because of the appearance of
;; prop in a modal expression.  Of course, the negation might also appear
;; in the modal expression.

(defun modal-fc (prop)
  (nconc (mf-1 prop) (mf-1 (negate prop))))

(defun mf-1 (prop)
  (mapcan #'(lambda (x) (mf-2 prop x)) *modal-ops*))

;; Look for rules of the form either
;;  (=> (modal-op ?*1 prop ?*2) ... conclusion)
;; or
;;  (=> (not (modal-op ?*1 prop ?*2)) ... conclusion)
;; The way we do it is we collect all of the truth values and go through
;; them one at a time.  The value of the modal proposition is determined
;; by lookup-with-vars (which calls lookup and then puts everything into
;; an element of bdg-to-truth-val), and the rest of the stuff is gotten
;; by disassembling the bindings returned during the lookup.  Note that
;; the value is the value of the modal expression itself, even if the
;; parity is negative (i.e. NIL).

(defun mf-2 (prop modal-op)
  (nconc (mf-3 prop modal-op nil)
	 (mf-3 prop modal-op t)))

(defun mf-3 (prop modal-op parity
	     &aux (starvar '#:?*) (star1 '#:?*) (star2 '#:?*) conj ans
		  (modal-prop (list modal-op star1 prop star2)) plug-prop
		  (dummies (list starvar star1 star2)))
  (declare (dynamic-extent dummies))
  (dolist (item (lookups
		 `(=> ,(if parity modal-prop (list 'not modal-prop)) ,starvar)
		 :cutoffs (fc-info-term-cutoffs fc-aux-info))
		ans)
    (setq plug-prop (plug modal-prop (answer-binding item))
	  conj (get-bdg starvar (answer-binding item)))
    (push (make-fc-modal
	    :prop plug-prop
	    :parity parity
	    :value (lookup-with-vars plug-prop)
	    :implication-value (answer-value item)
	    :conclusion (car (last conj))
	    :conjuncts (butlast conj)
	    :bdgs (delete-bdgs dummies (answer-binding item)))
	  ans)))

;; real-fc actually does the forward chaining in the nonmodal case.
;; old-val is the value the proposition used to have, and new-val is the
;; value being passed to stash.  So the real new-val is either new-val
;; (if increment-p is NIL) or (new-val + old-val) if increment-p is T.
;; Now for each relevant rule, we disassemble it and then call real-fc-1
;; to do the actual work.

(defun real-fc (p old-val new-val &aux (starvar '#:?*) conj)
  (unless (fc-info-increment-p fc-aux-info)
    (setq new-val (mvl-plus old-val new-val) old-val unknown))
  (dolist (ans (lookups `(=> ,p ,starvar)
			:cutoffs (fc-info-term-cutoffs fc-aux-info)))
    (setq conj (get-bdg starvar (answer-binding ans)))
    (real-fc-1 (mvl-and old-val (answer-value ans))
	       (mvl-and new-val (answer-value ans))
	       (car (last conj)) (butlast conj)
	       (delete-bdg starvar (answer-binding ans)))))

;; The guts of the forward chainer.  Look up the conjunction, and for
;; each binding returned, forward chain on the conclusion.  It's
;; actually quite a pain, because we have to be so careful with all of
;; the truth values running around.  For a start, we set the new value
;; (nv) to (new-val /\ lookup-val) \/ unknown, where new-val is the
;; value from the rule itself (passed into real-fc-1) combined with the
;; value from the new term, and lookup-val is the value obtained by
;; conjoining the values for all of the remaining conjuncts.  If this
;; passes the cutoff test, we have to do something.  (Note that we do
;; not include the new value in the cutoff check, since that would
;; probably make it impossible to propagate decreases in truth values.)

;; What we do is to construct the new proposition, get its old value by
;; looking it up *exactly* in the database, and then invoke the forward
;; chainer, with new value the sum of nv and the result of removing the
;; contribution due to old-val (this is what the call to dot-with-star
;; does).

(defun real-fc-1 (old-val new-val conclusion conj bdgs &aux prop v)
  (dolist (item (dag-list-of-answers
		  (conj-lookup-with-vars
		   (plug conj bdgs)
		   :cutoffs (fc-info-term-cutoffs fc-aux-info))))
    (when (test (mvl-t-ground (answer-value item))
		(fc-info-cutoffs fc-aux-info))
      (setq prop (plug conclusion (answer-binding item))
	    v (lookup-after-grounding prop))
      (fc-1 prop
	    (mvl-plus (mvl-t-ground (mvl-and new-val (answer-value item)))
	      (dot-with-star v (mvl-t-ground (mvl-and old-val
						      (answer-value item)))))
	    v))))

;; Forward chainer for modal rules.  For each one, check out the new
;; value of the associated modal proposition, and get all of the
;; bindings that appeared in *either* the old or the new database state.
;; Negate the truth values if the parity of the expression is negative;
;; then if the change merits it, fire the rule using real-fc-1.

(defun fc-m (modals &aux new old-val new-val)
  (dolist (modal modals)
    (setq new (lookup-with-vars (fc-modal-prop modal)))
    (dolist (bdg (nunion (mapcar #'car (dag-fn-list (fc-modal-value modal)))
			 (mapcar #'car (dag-fn-list new))
			 :test #'equal-binding))
      (setq old-val (get-val bdg (fc-modal-value modal))
	    new-val (get-val bdg new))
      (unless (fc-modal-parity modal)
	(setq old-val (mvl-not old-val) new-val (mvl-not new-val)))
      (when (fc-test old-val new-val)
	(real-fc-1 (mvl-and old-val (fc-modal-implication-value modal))
		   (mvl-and new-val (fc-modal-implication-value modal))
		   (fc-modal-conclusion modal)
		   (fc-modal-conjuncts modal)
		   (append-binding-lists bdg (fc-modal-bdgs modal)))))))

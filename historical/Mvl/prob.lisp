;;; -*- Mode: LISP; Syntax: Common-lisp; Package: MVL; Base: 10 -*-

(in-package "MVL")

;; here we define a bilattice that augments the ATMS bilattice with
;; probabilistic information.  The crucial function prob computes the
;; probability associated to an arbitrary ATMS label using the algorithm
;; in "A New Algorithm for Network Reliability Computation", Grnarov,
;; Kleinrock and Gerla, cited in Pearl's probability book.  The function
;; prob accepts as arguments a list of probabilities and a modified dnf
;; expression.  To be specific, let's suppose that we are interested in
;; the probability of some sentence p, and that p is entailed by (a,b)
;; or (c,d) or (a,d,e) or (b,c,e).  Then the "vals" are the
;; probabilities of a,b,c,d,e respectively, and the dnf-exp is a list
;; whose entries are:
;;  11xxx	corresponding to ab
;;  xx11x	corresponding to cd
;;  1xx11	corresponding to ade
;;  x11x1	corresponding to bce
;; These values (probabilities and the modified dnf-exp) are computed as
;; part of the function true-prob that appears below.  The Grnarov
;; algorithm now requires us to:
;;  1.  Identify the dnf-exp (done by the ATMS and true-prob)
;;  2.  Sort the modified dnf-exp by increasing number of 1's.
;;  3.  For each entry in the dnf-exp, increment the probability of p by
;;  including a factor corresponding to that row *with any contribution
;;  from previous rows removed*.
;; To remove the contribution from previous rows, we work through the
;; rows starting at the beginning, and for each row Ri replace the given
;; row R with the result of a computation Grnarov writes as R $ Ri.
;; This produces a new row that includes 1's (has to be true), x's
;; (don't care) and 0's (has to be false because the true part was
;; included elsewhere).  We then compute the probability of the new row
;; and add that to the accumulated value.

;; The $ operation is fairly easy.  The the entry in R is 0 or 1, it's
;; already fixed and we can just return it.  If it's x, then if the
;; entry in Ri is 0 or 1, we should complement it, since this part of
;; the set has already been accounted for.  If it's x, we just return x.
;; This is what the function combine does.

;; Computing the probability is harder.  Each time the $ operator is
;; applied, some number of new 0's will be introduced.  If a *single*
;; new 0 is introduced, we will call that 0 "unique".  If multiple new
;; 0's are introduced, we will call them nonunique.  The probability of
;; the final row is obtained by keeping track, at each rewriting, of the
;; terms that become 0 at that point and computing (1-pi...pj) for these
;; terms, where the pi are the probabilities of the terms becoming 0.
;; (The product of the pi's, as it is computed, is called pp, and flag
;; is used to indicate that there has been such a 0, in which case we
;; have to adjust the overall value q -- if we were to adjust q when
;; there were no new 0s, we would set it to 0!)  Then at the end we
;; mulitply by the probabilities of all the terms still labelled with a
;; 1.  (This last step is handled by c-prob.)

(defun prob (vals dnf-exp &aux processed (ans 0) q old-item new-item flag pp)
  (dolist (item (prob-sort dnf-exp) ans)	;step 1 - sort by # of 1's
    (setq q 1 old-item item)
    (dolist (p processed)
      (setq new-item (combine item p)
	    pp 1 flag nil)
      (do ((v vals (cdr v)) (i item (cdr i)) (n new-item (cdr n)))
	  ((null i))
	(when (and (eql 0 (car n)) (not (eql 0 (car i))))	;new 0
	  (setq pp (* pp (car v))
		flag t)))
      (when flag (setq q (* q (- 1 pp))))
      (setq item new-item))
    (setq ans (+ ans (* q (c-prob vals item)))	;include new probability
	  processed (nconc processed (list old-item))	;push R onto list of
							;processed rows
	  )))

;; sort a dnf expression in order of increasing number of 1s.  The
;; number of 1s is computed by num-1

(defun prob-sort (exp)
  (napcar #'cdr 
	  (sort (mapcar #'(lambda (x) (cons (num-1 x) x)) exp) #'<
		:key #'car)))

(defun num-1 (c &aux (num 0))
  (dolist (item c num) (if (eql item 1) (incf num))))

;; adjust the probability to include any 1s that are left over.

(defun c-prob (vals conj &aux (ans 1))
  (do ((v vals (cdr v)) (c conj (cdr c)))
      ((null v) ans)
    (when (eql 1 (car c)) (setq ans (* ans (car v))))))

(defun combine (l1 l2)
  (mapcar #'c1 l1 l2))

(defun c1 (a b)
  (if (eq a 'x)
      (case b (0 1) (1 0) (x 'x))
    a))

;; given a conventional dnf expression from the atms, invoke prob above.
;; First get a list of all the atoms in the expression, then get their
;; probabilities and then rewrite each conjunct as 1s and xs depending
;; on whether the atom is in the conjunct.

(defun true-prob (dnf &aux (atoms (reduce #'union dnf :initial-value nil)))
  (prob (mapcar #'(lambda (x) (get-mvl x 'prob 0)) atoms)
	(mapcar #'(lambda (x) (rewrite-conj x atoms)) dnf)))

(defun rewrite-conj (conj atoms)
  (mapcar #'(lambda (x) (if (member x conj) 1 'x)) atoms))

;; probabilistic bilattice constructed using true-prob and atms
;; bilattice.  Given the stuff above, the only tricky part is getting
;; the probabilities entered in the first place.  This is done by
;; prob-stash-val, which gets the proposition number, prompts the user
;; for the probability and records it.  Then we have to compute the
;; simplicity, which is given simply as the probability of x.  We first
;; compute the probability of -x, since low values are supposed to be
;; better than high ones.  Then we invoke make-simp to compute the first
;; 7 digits of the binary expansion of this probability as a "decimal".

(defvar *atms-bilattice*)

(defun prob-stash-val (p &aux (pnum (index-with-negation p)) prob)
  (format t "~%Enter probability of ~a: " p)
  (setq prob (read))
  (setf (get-mvl pnum 'prob) prob)
  `((((,pnum))) . ,prob))

(defun prob-simp (x)
  (make-simp (- 1 (cdr x))))

(defun make-simp (x &aux ans)
  (dotimes (i 7 (nreverse ans))			;length of list
    (multiple-value-bind (a b) (truncate (* 2 x))
      (push a ans)
      (setq x b))))

(defparameter *probability-bilattice* 
    (append-bilattice *atms-bilattice* #'(lambda (x) (true-prob (car x)))))

(setf (bilattice-stash-val *probability-bilattice*) 'prob-stash-val)
(setf (bilattice-simplicity *probability-bilattice*) 'prob-simp)

(describe-bilattice *probability-bilattice*
		    "ATMS with probabilistic information." "Probability" #\p)

(bilattice *probability-bilattice*)

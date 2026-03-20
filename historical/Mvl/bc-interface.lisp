;;; -*- Mode: LISP; Syntax: Common-lisp; Package: MVL; Base: 10 -*-

(in-package "MVL")

;; inference using functions from binding lists to bilattice.

;; functions defined:
;; 
;; bc, bcs (prop)		provers
;; return-from-consideration	when an analysis returns an answer, this
;; 				function pulls it apart and actually
;; 				returns a list of answers

;; because of a longstanding Symbolics bug, several functions in this
;; file need to copy the keyword list passed as an argument.  This error
;; does not occur elsewhere in the MVL system.

;; backward chainer

(defun bcs (prop &rest keywords &key analysis &allow-other-keys &aux ans)
  #+Genera (setq keywords (copy-list keywords))
  (unless analysis (setq analysis (apply #'init-analysis prop keywords)))
  (multiple-value-setq (ans analysis) (cont-analysis analysis))
  (return-from-consideration ans analysis))

;; given that the proof stuff has returned a truth value (an element of
;; the bdg-to-truth-val bilattice), what should the invoking function
;; return?  If nothing (presumably a surprise), reinvoke the analyzer if
;; there is more work to be done.

(defun return-from-consideration
    (fn analysis &aux (ans (dag-list-of-answers fn)) answers
		      (returned (analysis-returned-answers analysis)))
  (dolist (item ans)
    (when (and (test (answer-value item) (analysis-cutoffs analysis))
	       (not (mvl-eq (answer-value item)
			    (get-val (answer-binding item) returned))))
      (push item answers)))
  (setf (analysis-returned-answers analysis) fn)
  (cond ((or answers (null (analysis-active-tasks analysis)))
	 (values answers analysis))
	(t (multiple-value-setq (fn analysis) (cont-analysis analysis))
	   (return-from-consideration fn analysis))))

;; singular backward chainer.  Add success test and invoke the prover.

(defun bc (prop &rest keywords &key (succeeds *success-test*)
	   &allow-other-keys)
  (declare (special *success-test*))
  #+Genera (setq keywords (copy-list keywords))
  (multiple-value-bind (answers analysis)
      (apply #'bcs prop :succeeds succeeds keywords)
    (values (car answers) analysis)))

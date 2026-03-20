;;; -*- Syntax: Common-lisp; Package: USER -*-
;;; Copyright 1987 by Henry A. Kautz
;;; No warranty as to the correctness or usefulness of this software
;;; is given or implied.
;;;
;;; The author may be contacted at the following addresses:
;;; :uucp:	allegra!kautz		
;;; :arpa: or :csnet:	kautz@research.att.com
;;; :old style csnet: 	kautz%allegra@btl.csnet
;;; :mail:	AT&T Bell Laboratories	
;;;		Room 2C-407
;;;		600 Mountain Ave.	
;;;		Murray Hill, N.J. 07974	


;;; Most Database functions take an optional final argument, which is
;;; the graph containing the relation in question.  Defaults to value
;;; of *default-graph*, which is set by use-graph.

;;;; Database addition functions

(defvar *default-graph* 'test1)

;;;; (use-graph g)
(defun use-graph (g)
   (setq *default-graph* g)
   )

;;;; (initialize-graph g)
(defun initialize-graph (g)
   (set-mapping g 'nodes nil)
   )

;;;; (add-event-descr event)
(defun add-event-descr (event &optional (g *default-graph*))
  (add-node (car event) (cadr event))
  (add-roleval-list (car event) (cddr event))
  )

;;;; (mark-as-failed node)
(defun mark-as-failed (node &optional (g *default-graph*))
  (blab "~A fails" node)
   (set-mapping node 'failed t)
   )

;;;; (new-node kind)
(defun new-node (kind)
   (gentemp  (string kind))
   )

;;;; (add-node node kind)
(defun add-node (node kind &optional (g *default-graph*))
   (augment-mapping g 'nodes node)
   (blab "creating node ~A" node)
   (set-mapping node 'kind kind)
   )

;;;; (add-abstr-node abstr-node abstr-kind)
(defun add-abstr-node (abstr-node abstr-kind &optional (g *default-graph*))
   (add-node abstr-node abstr-kind g)
   )

;;;; (add-roleval node role value)
(defun add-roleval (node role value &optional (g *default-graph*))
   (set-mapping node role value)
   )

;;;; (add-param-arc node role value)
(defun add-param-arc (node role value &optional (g *default-graph*))
   (add-roleval  node role value g)
   )
   
;;;; (add-step-arc node role value)
(defun add-step-arc (node role value &optional (g *default-graph*))
   (add-roleval  node role value g)
   )

;;;; (safe-add-roleval node role value)
(defun safe-add-roleval (node role value &optional (g *default-graph*))
   (if (typep value 'sequence)
      (add-roleval node role (copy-seq value) g)
      (add-roleval node role value g)
      )
   )

;;;; (add-roleval-list node roleval-list)
;;;      Adds copies of any times that appear in roleval list,
;;;      to prevent any conflicts from destructive modifications
(defun add-roleval-list (node roleval-list &optional (g *default-graph*))
   (dolist (rv roleval-list)
      (safe-add-roleval node (roleval-descr-role rv)
	 (roleval-descr-value rv) g)
      )
   )

;;;; (add-alternative base-node abstr-node)
;;;      base-node is an alternative for (below) abstr-node
(defun add-alternative (base-node abstr-node &optional (g *default-graph*))
   (augment-mapping abstr-node 'alternatives base-node)
   (augment-mapping base-node 'inverse-alternatives abstr-node)
   )

;;;; (add-match n1 g1 n2 g2 n3)
(defun add-match (n1 g1 n2 g2 n3 &optional (g *default-graph*))
   (set-mapping (list* n1 n2 g) 'matches n3)
   )
   
;;;; (add-fact fact)
;;;    facts are not associated with a particular graph, but are true
;;;    universally.  facts are of the form
;;;       (pred {time} arg1 arg2 ... )  
;;;    where time is optional, depending on the particular predicate.
;;;    all facts are added to the fact list, retrieved by 
;;;       (roleval 'facts 'known)
;;;    facts are also indexed under the predicate, retrieved
;;;    by 
;;;       (roleval 'pred 'holds) yields list, each element of the form 
;;;           ({time} arg1 ... ) 
;;;    finally all facts are hashed in toto for fast checking.
;;;       (roleval fact 'truth) yields t or nil
(defun add-fact (fact)
   (augment-mapping 'facts 'known fact)
   (augment-mapping (car fact) 'holds (cdr fact))
   (set-mapping fact 'truth t)
   )

;;;; (add-facts fact-list)
;;;      used to record observed facts (as opposed to observed events)
;;;      facts are used by provably-false?
(defun add-facts (fact-list)
   (dolist (fact fact-list)
      (add-fact fact)
      )
   )

;;;; Database retrevial functions

(defun active-nodes (&optional (g *default-graph*))
   (remove-if #'failed? (get-mapping g 'nodes)))

;;;; (end-node-of g)
(defun end-node-of (&optional (g *default-graph*))
   (dolist (node (get-mapping g 'nodes))
      (if (eql (kind-of node g) 'end)
	 (return-from end-node-of node)
	 )
      )
   )
   
;;;; (kind-of node)
(defun kind-of (node &optional (g *default-graph*))
   (get-mapping node 'kind)
   )

;;;; (all-alternatives-for node)
;;;     node must be equal to one of the nodes in the list returned
(defun all-alternatives-for (node &optional (g *default-graph*))
   (get-mapping node 'alternatives)
   )

;;;; (alternatives-for node)
;;;     node must be equal to one of the nodes in the list returned
;;;     don't consider failed nodes
(defun alternatives-for (node &optional (g *default-graph*))
   (remove-if #'failed? (get-mapping node 'alternatives))
   )


;;;; (failed? node)
(defun failed? (node &optional (g *default-graph*))
   (get-mapping node 'failed)
   )

;;; (roleval node role)
(defun roleval (node role &optional (g *default-graph*))
   (get-mapping node role)
   )

(defun accumulate (node rolelist input)
   (let (value)
      (dolist (r rolelist)
	 (setq value (get-mapping node r))
	 (if value
	    (setq input
	       (cons (make-roleval-descr :role r :value value) input)))
	 )
      input
      ))

;;;; (known-rolevals node kind)
;;;    returns list of role/value pairs for node, limited to the 
;;;    roles that are defined for kind.  Roles which do not have
;;;    a known value are not included in the list.  Elements are of
;;;    type roleval-descr.
;;;    rolevals are subdivided into params, times, and steps (exclusive).
;;;    following functions only retrieve designated set of rolevals.
(defun known-rolevals (node kind &optional (g *default-graph*))
   (accumulate node (steps-of kind)
      (accumulate node (params-of kind) 
	 (accumulate node (times-of kind) nil)
	 )
      )
   )

;;;; (known-param-rolevals node kind)
(defun known-param-rolevals (node kind &optional (g *default-graph*))
   (accumulate node (params-of kind) nil)
   )

;;;; (known-time-rolevals node kind)
(defun known-time-rolevals (node kind &optional (g *default-graph*))
   (accumulate node (times-of kind) nil)
   )
   
;;;; (known-step-rolevals node kind)
(defun known-step-rolevals (node kind &optional (g *default-graph*))
   (accumulate node (steps-of kind) nil)
   )
   
;;;; (known-param&time-rolevals node kind)
(defun known-param&time-rolevals (node kind &optional (g *default-graph*))
   (accumulate node (params-of kind) 
      (accumulate node (times-of kind) nil)
      )
   )
   
;;;; (match-of n1 g1 n2 g2)
;;;     return nil if no match of n1 and 2 known
(defun match-of (n1 g1 n2 g2 &optional (g *default-graph*))
   (or (get-mapping (list* n1 n2 g) 'matches)
      (get-mapping (list* n2 n1 g) 'matches)
      )
   )
   
;;;; (matching-abstr-node abstr-kind roleval-list) 
;;;     returns abstract node of the kind which has exactly the roleval- 
;;;     list of roles (and no others).  Will match on failed nodes.
;;;     must use equalp so that it works with times
(defun matching-abstr-node (abstr-kind roleval-list
			      &optional (g *default-graph*))
   (dolist (candidate (get-mapping g 'nodes))
      (if (eql abstr-kind (get-mapping candidate 'kind))
	 (if (equalp roleval-list
		(known-rolevals candidate abstr-kind g))
	    (return-from matching-abstr-node candidate)
	    )
	 )
      )
   )

;;;; negation-by-failure (predicate)
(defun negation-by-failure (predicate)
  (set-mapping predicate 'disprove t)
  )


;;;;  to-disprove (predicate method)
(defun to-disprove (predicate method)
  (set-mapping predicate 'disprove method)
  )

;;;; (provably-false? fact)
;;;     Try to disprove fact, by calling function stored
;;;     under (roleval (car prop) 'disprove), or by negation as
;;;     failure if the method is t.  (If method is null then this
;;;     function always returns false.)
(defun provably-false? (fact)
   (let* ((method (get-mapping (car fact) 'disprove)))
      (and method
	 (if (eql method t)
	    (then (not (get-mapping fact 'truth)))
	    (else (apply method (cdr fact)))
	    )
	 )
      )
   )


;;;; (provably-unequal-values? val1 val2)
;;;   unique names assumption for values
(defun provably-unequal-values? (val1 val2)
   (not (equalp val1 val2))
   )



(defun disprove-never (time predicate &rest args)
  (dolist (f (roleval predicate 'holds))
    (if (and (equalp args (cdr f))
	    (times-intersect? time (car f)))
	(return-from disprove-never  t)
	)
    (return-from disprove-never nil)
    )
  )



;;;; Hierarchy description functions


(defun all-kinds ()
   "Returns a lists of all the event types defined for current database"
   (get-mapping 'hierarchy 'kinds))


;;;; (kind-is-end? kind)
(defun kind-is-end? (kind)
   (eql kind 'end)
   )

;;;; (has-new-abstr-uses? base-kind)
(defun has-new-abstr-uses? (base-kind)
   (get-mapping base-kind 'has-new-abstr-uses)
   )

;;;; (direct-abstr-of base-kind)
(defun direct-abstr-of (base-kind)
   (get-mapping base-kind 'direct-abstr)
   )

;;;; (direct-specs-of kind)
(defun direct-specs-of (kind)
   (get-mapping kind 'direct-specs)
   )
   
;;;; (direct-specs-with-new-uses-of base-kind)
(defun direct-specs-with-new-uses-of (base-kind)
   (get-mapping base-kind 'direct-specs-with-new-uses)
   )
   
;;;; (eq-constraints kind)
;;;     returns list of eq-constr
(defun eq-constraints (kind)
   (get-mapping kind 'eq-constraints)
   )

;;;; (time-constraints kind)
;;;     returns list of time-constr
(defun time-constraints (kind)
   (get-mapping kind 'time-constraints)
   )
   
;;;; (fact-constraints kind)
;;;     returns list of fact-constr
(defun fact-constraints (kind)
   (get-mapping kind 'fact-constraints)
   )

;;;; (steps-of kind)
;;;     list of roles of kind which are steps
;;;     Note that the kinds of the steps are not included
(defun steps-of (kind)
   (get-mapping kind 'steps)
   )

;;;; (params-of kind)
;;;     list of roles of kind which are parameters
(defun params-of (kind)
   (get-mapping kind 'params)
   )

;;;; (times-of kind)
;;;     list of roles of kind which are times
(defun times-of (kind)
   (get-mapping kind 'times)
   )

;;;; (direct-uses-of base-kind)
;;;     returns list of use-descr
(defun direct-uses-of (base-kind)
   (get-mapping base-kind 'direct-uses)
   )
   
;;;; (abstracts* base-kind abstr-kind)
(defun abstracts* (base-kind abstr-kind)
   (and  base-kind abstr-kind
      (or
	 (eql base-kind abstr-kind)
	 (abstracts* (direct-abstr-of base-kind)  abstr-kind)
	 )
      )
   )

;;;; (lower-bound-kind n1-kind n2-kind)
;;;     most general kind abstracted* by n1-kind and n2-kind
;;;     (for now, must be one of n1-kind or n2-kind); if none, nil.
(defun lower-bound-kind (n1-kind n2-kind)
   (cond
      ((abstracts* n1-kind n2-kind) n1-kind)
      ((abstracts* n2-kind n1-kind) n2-kind)
      )
   )

;;;
;;;  Hierarchy Creation Routines
;;;
;;;  This version now automatically computes:
;;;         direct-specs
;;;         direct-uses
;;;  direct-uses is simply the inverse of steps; the additional
;;;  direct-uses are not computed here (see below).
;;;  Following are eliminated:
;;;      direct-specs-with-new-uses
;;;      has-new-abstr-uses
;;;
;;;  Other future work:  allow for multiple direct abstractions
;;;
;;; (frame frame)
(defun frame (frame &optional no-inherit)
   (let ((kind (car frame)))
      (augment-mapping 'hierarchy 'kinds kind)
      (dolist (stuff (cdr frame))
	 (case (car stuff)
	    ((direct-abstr)
	       (set-mapping kind  'direct-abstr (cadr stuff))
	       (augment-mapping (cadr stuff) 'direct-specs kind)
	       )
	    ((steps)
	       (set-mapping kind 'steps
		  (mapcar #'cadr (cdr stuff)))
	       (dolist (step-descr (cdr stuff))
		  (augment-mapping (car step-descr) 'direct-uses 
		     (list (cadr step-descr) kind)))
	       )
	    (otherwise
	       (set-mapping kind (car stuff) (cdr stuff))
	       )
	    )
	 )
      (unless no-inherit (inherit (car frame) (direct-abstr-of (car frame))))
      )
   )

(defun inherit (base-kind abstr-kind)
  (set-mapping base-kind 'steps
      (union (steps-of base-kind) (steps-of abstr-kind) :test #'equal))
  (set-mapping base-kind 'params
      (union (params-of base-kind) (params-of abstr-kind) :test #'equal))
  (set-mapping base-kind 'times
      (union (times-of base-kind) (times-of abstr-kind) :test #'equal))
  (set-mapping base-kind 'eq-constraints
      (union (eq-constraints base-kind) (eq-constraints abstr-kind) :test #'equal))
  (set-mapping base-kind 'time-constraints
      (union (time-constraints base-kind) (time-constraints abstr-kind) :test #'equal))
  (set-mapping base-kind 'fact-constraints
      (union (fact-constraints base-kind) (fact-constraints abstr-kind) :test #'equal))
  ) 

;;; This function calulates the "extra" direct-uses which must be
;;; declared in order to guarantee completeness of the algorithm.  It
;;; should be called after all frames for the current hierarchy have
;;; been read in.  See page 97 (section 7.3) of TR 215 for a
;;; description of what this algorithm should compute.  It has not yet
;;; been implemented, however, since for all of the examples we've
;;; done so far it suffices to take direct-uses to be the inverse of
;;; the "steps" relation.
;;; It may also be preferrable to compute all of direct-uses in this
;;; step, and do none of it "on the fly", as is done above; this could
;;; avoid problems if redundant step links are specified in the
;;; hierarchy.
(defun calculate-uses ()
   "Compute direct-uses for current database"
   (dolist (k (get-mapping 'hierarchy 'kinds))
      ;; assert additional direct-uses relns (if any) for k
      )
   )

;;;;
;;;;  Display routines
;;;;

(defun dump-database ()
  (maphash #'(lambda (key val) (format t "~A => ~A~%" key val)) *mapping-table*)
   )

(defun display-node (node &optional all)
   (let ((kind (kind-of node)))
      (format t "~% ~A : ~A" node kind)
      (if (failed? node) (format t "  * failed *"))
      (format t "~%    Steps~%" )
      (dolist (rv (known-step-rolevals node kind))
	 (format t "       ~A => ~A~%" (car rv) (cadr rv))
	 )
      (format t "    Parameters~%")
      (dolist (rv (known-param-rolevals node kind))
	 (format t "       ~A => ~A~%" (car rv) (cadr rv))
	 )
      (format t "    Times~%")			
      (dolist (rv (known-time-rolevals node kind))
	 (format t "       ~A => ~A~%" (car rv) (cadr rv))
	 )
      (format t "    Alternatives~%      ")
      (dolist (a (if all (all-alternatives-for node) (alternatives-for node)))
	 (format t "~A  " a)
	 )
      (format t "~%")
      )
   )

(defun display-graph (&optional all (g *default-graph*))
  (format t "~%Graph ~A~%" g)
   (dolist (node (get-mapping g 'nodes))
      (if (or all (not (failed? node)))
	 (display-node node all)
	 )
      )
   )

(defun draw-graph (&optional  long (g *default-graph*))
  (format t "~%graph ~A~%" g)
  (draw-node 1 (end-node-of g) nil long)
  )

(defun draw-node (level node visited &optional long)
  (format t "~A " node )
  (if long (format t "~A" (known-param&time-rolevals node (kind-of node))))
  (if (member node visited)
      (then (format t "  ^"))
      (else
	  (setq visited (cons node visited))
	  (dolist (s (known-step-rolevals node (kind-of node)))
	    (format t "~% ~v@T~A -> " (* level 5) (car s))
	    (setq visited (draw-node (+ level 1) (cadr s) visited long))
	    )
	  (dolist (a (alternatives-for node ))
	    (format t "~% ~v@T?= " (* level 5))
	    (setq visited (draw-node (+ level 1) a visited long))
	    )
	  )
      )
  (return-from draw-node visited)
  )

;;;;
;;;;  Lowest Level Database Routines
;;;;
;;;;  Database is stored in a hash table, keyed on both relation name
;;;;  and a single parameter (usually a node name).
;;;;  Because each node appears in no more than one graph, we can
;;;;  safely use a single hash table for all information.  The lowest
;;;;  level routines can easily be modified to use a different hash
;;;;  table for each graph.

(defparameter *mapping-table* (make-hash-table :test #'equal :size 400))

(defun clear-all-mappings ()
   "Initialize database"
   (clrhash *mapping-table*)
   (to-disprove 'never 'disprove-never)
   (to-disprove 'not-same 'equalp)
   )

(defun set-mapping (parameter relation value)
   (setf (gethash (cons parameter relation) *mapping-table*) value)
   )

(defun get-mapping (parameter relation)
   (values (gethash (cons parameter relation) *mapping-table*))
   )

(defun augment-mapping (parameter relation value)
   (push value (gethash (cons parameter relation) *mapping-table*))
   )
   

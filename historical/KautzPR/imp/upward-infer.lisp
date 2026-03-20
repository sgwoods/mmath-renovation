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

;;;; explain-observation (start-descr g)
;;;   Set the graph associated with g to the primary explanation
;;;   structure for event described by start-descr.  
;;;  returns
;;;     success -- true if some explanation found
;;;     obs-node -- name of node assigned to the observation
(defun explain-observation (etype-and-edescr g)
   (let ((etype (car etype-and-edescr)) success obs-node visited)
      (initialize-graph g)
      (use-graph g)
      (msetq (obs-node success visited)
	 (explain etype (cdr etype-and-edescr) nil t etype))
      (return-from explain-observation (values success obs-node))
      )
   )

;;;; explain
;;;    returns
;;;      node
;;;      pathToEndFound
;;;      allvisited
;;
(defun explain (etype edescr visited consider-spec primary)
   (let (explained merge-node n r utype unode foundpath uvisited 
	   atype adescr anode snode svisited stype
	   n-known-rolevals)
      (setq visited (cons etype visited))
      ; merge search paths if possible
      (setq merge-node (matching-abstr-node etype edescr))
      (if merge-node
	 (then 
	    (blab "merging graph at ~A" merge-node)
	    (return-from explain 
	       (values merge-node (not (failed? merge-node)) visited))))
      ; can't merge, must create a new node
      (setq n (new-node etype))
      (add-node n etype)
      (add-roleval-list n edescr)
      (blab "creating new node ~A" n)
      (if (kind-is-end? etype)
	 (then
	    (blab "path to End from ~A found" primary)
	    (return-from explain (values n t visited))))
      ; propagate constraints
      (check-constraints n etype)
      (if (failed? n)
	 (return-from explain (values n nil visited)))
      ; consider explicit Uses of etype
      (blab "explicit uses")
      (dolist (use-descr (direct-uses-of etype))
	 (setq utype (use-descr-kind use-descr))
	 (setq r (use-descr-role use-descr))
	 (if (not (redundant etype r utype visited primary))
	    (then
	       (blab "considering ~A as ~A of ~A" n r utype)
	       (msetq (unode foundpath uvisited) 
		  (explain utype (list (list r n)) nil t utype))
	       (setq explained (or explained foundpath)))))
      ; consider abstraction of etype
      ; NOTE: we assume NO multiple inheritance.  To modify, must
      ; add loop and change way direct-abstr is stored.
      (setq atype (direct-abstr-of etype))
      (if (not (or (null atype) (member atype visited)))
	 (then
	    (blab "abstracting ~A as ~A" n atype)
	    (setq adescr (known-param&time-rolevals n atype))
	    (msetq (anode foundpath visited)
	       (explain atype adescr visited nil primary))
	    (add-alternative n anode)
	    (setq explained (or explained foundpath))))
      ; consider specializations of etype
      (if consider-spec
	 (then
	    (setq n-known-rolevals (known-rolevals n etype))
	    (dolist (stype (direct-specs-of etype))
	       (blab "specializing ~A as ~A" n stype)
	       (msetq (snode foundpath svisited)
		  (explain stype n-known-rolevals visited t primary))
	       (setq explained (or explained foundpath)))))
      ; fail if no explanations were found
      (if (not explained)
	 (then
	    (blab "no explanations of ~A found" n)
	    (mark-as-failed n))
	 (else
	    (blab "~A explained" n)))
      (return-from explain (values n explained visited))))

;; use-abstracts
;;  see thesis page 97
(defun use-abstracts (etype r utype ab-etype ab-r ab-utype)
   (and
      (eql r ab-r)
      (not (eql etype ab-etype))
      (not (eql utype ab-utype))
      (abstracts* etype ab-etype)
      (abstracts* utype ab-utype)))

;;; redundant 
;;; see thesis page 107
;;; tree version (doesn't work properly for multiple inheritance)
;;
(defun redundant (etype r utype visited primary)
   (let (vuse-r vuse-type)
      (dolist (vtype visited)
	 (dolist (vuse-descr (direct-uses-of vtype))
	    (setq vuse-r (use-descr-role vuse-descr))
	    (setq vuse-type (use-descr-kind vuse-descr))
	    (if (or 
		   (use-abstracts etype r utype vtype vuse-r vuse-type)
		   (use-abstracts vtype vuse-r vuse-type etype r utype))
	       (then
		  (blab "Use ~A as ~A of ~A is redundant by ~A and ~A"
		     etype r utype vtype vuse-type)
		  (return-from redundant t)))))
      (return-from redundant nil)))

